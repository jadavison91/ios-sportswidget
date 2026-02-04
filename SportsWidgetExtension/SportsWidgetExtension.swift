//
//  SportsWidgetExtension.swift
//  SportsWidgetExtension
//
//  Created by Jason Davison on 1/29/26.
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Provider
struct SportsScheduleProvider: TimelineProvider {
    typealias Entry = ScheduleEntry

    func placeholder(in context: Context) -> ScheduleEntry {
        ScheduleEntry.placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (ScheduleEntry) -> Void) {
        if context.isPreview {
            completion(ScheduleEntry.placeholder)
            return
        }

        Task {
            let entry = await fetchCurrentEntry(for: context.family)
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ScheduleEntry>) -> Void) {
        Task {
            let entry = await fetchCurrentEntry(for: context.family)

            // Schedule next refresh in 15 minutes for timely score updates
            let nextUpdate = Date().addingTimeInterval(15 * 60) // 15 minutes
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }

    /// Determines max games to display based on widget size
    private func maxGamesForWidget(_ family: WidgetFamily) -> Int {
        switch family {
        case .systemSmall:
            return 1
        case .systemMedium:
            return 4
        default:
            return 4
        }
    }

    /// Fetches and returns prioritized games for the widget
    private func fetchCurrentEntry(for family: WidgetFamily) async -> ScheduleEntry {
        let selectedTeams = AppGroup.selectedTeams

        // Check if user has selected any teams
        guard !selectedTeams.isEmpty else {
            return ScheduleEntry(
                date: Date(),
                games: [],
                lastUpdated: Date(),
                error: .noTeamsSelected
            )
        }

        // Try to fetch games (already prioritized: in-progress → scheduled → completed)
        let allGames = await DataCache.shared.getGames(for: selectedTeams)
        let lastUpdated = await DataCache.shared.lastFetchDate ?? Date()

        if allGames.isEmpty {
            return ScheduleEntry(
                date: Date(),
                games: [],
                lastUpdated: lastUpdated,
                error: .noGames
            )
        }

        // Filter to show only the next/most relevant game per team
        let filteredGames = selectNextGamePerTeam(from: allGames)

        // Limit to what the widget can display
        let maxGames = maxGamesForWidget(family)
        let games = Array(filteredGames.prefix(maxGames))

        return ScheduleEntry(
            date: Date(),
            games: games,
            lastUpdated: lastUpdated
        )
    }

    /// Selects only the most relevant game per team for widget display
    /// Priority: in-progress → completed (within 12h) → next scheduled
    private func selectNextGamePerTeam(from games: [Game]) -> [Game] {
        let now = Date()
        let twelveHoursAgo = now.addingTimeInterval(-12 * 60 * 60)

        // Group games by user's team
        let gamesByTeam = Dictionary(grouping: games) { $0.userTeamAbbreviation.lowercased() }

        var selectedGames: [Game] = []

        for (_, teamGames) in gamesByTeam {
            if let bestGame = selectBestGame(from: teamGames, now: now, twelveHoursAgo: twelveHoursAgo) {
                selectedGames.append(bestGame)
            }
        }

        // Sort selected games: in-progress first, then by start time
        return selectedGames.sorted { game1, game2 in
            let priority1 = gamePriority(game1, now: now)
            let priority2 = gamePriority(game2, now: now)

            if priority1 != priority2 {
                return priority1 < priority2
            }

            return game1.startTime < game2.startTime
        }
    }

    /// Selects the best game for a team based on priority rules
    private func selectBestGame(from games: [Game], now: Date, twelveHoursAgo: Date) -> Game? {
        // 1. In-progress games have highest priority
        if let inProgress = games.first(where: { $0.status == .inProgress }) {
            return inProgress
        }

        // 2. Recently completed games (within 12 hours) - show the most recent
        let recentlyCompleted = games
            .filter { $0.status == .completed && $0.startTime >= twelveHoursAgo }
            .sorted { $0.startTime > $1.startTime } // Most recent first

        if let recent = recentlyCompleted.first {
            return recent
        }

        // 3. Next scheduled game
        let scheduled = games
            .filter { $0.status == .scheduled && $0.startTime >= now }
            .sorted { $0.startTime < $1.startTime } // Earliest first

        if let next = scheduled.first {
            return next
        }

        // 4. Fallback: any upcoming game (postponed games that might be rescheduled)
        let upcoming = games
            .filter { $0.startTime >= now }
            .sorted { $0.startTime < $1.startTime }

        return upcoming.first
    }

    /// Returns priority for sorting (lower = higher priority)
    private func gamePriority(_ game: Game, now: Date) -> Int {
        switch game.status {
        case .inProgress:
            return 0
        case .scheduled:
            return 1
        case .completed:
            return 2
        case .postponed:
            return 3
        case .canceled:
            return 4
        }
    }

}

// MARK: - Widget Entry View (Adaptive)
struct SportsWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily
    let entry: ScheduleEntry

    var body: some View {
        Group {
            switch widgetFamily {
            case .systemSmall:
                SmallWidgetView(entry: entry)
            case .systemMedium:
                MediumWidgetView(entry: entry)
            default:
                SmallWidgetView(entry: entry)
            }
        }
        .invalidatableContent()
    }
}

// MARK: - Widget Configuration
struct SportsScheduleWidget: Widget {
    let kind: String = "SportsScheduleWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SportsScheduleProvider()) { entry in
            SportsWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    if let customColor = AppGroup.widgetBackgroundPreset.color {
                        customColor
                    } else {
                        Color.clear.background(.fill.tertiary)
                    }
                }
        }
        .configurationDisplayName("Gametime")
        .description("Live scores and upcoming games for your favorite teams.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Previews
#Preview("Small", as: .systemSmall) {
    SportsScheduleWidget()
} timeline: {
    ScheduleEntry.placeholder
    ScheduleEntry(date: Date(), games: [], lastUpdated: Date(), error: .noTeamsSelected)
    ScheduleEntry.empty
}

#Preview("Medium", as: .systemMedium) {
    SportsScheduleWidget()
} timeline: {
    ScheduleEntry.placeholder
    ScheduleEntry(date: Date(), games: [], lastUpdated: Date(), error: .noTeamsSelected)
    ScheduleEntry.empty
}

// MARK: - Widget Background Color Extension
extension AppGroup.WidgetBackgroundPreset {
    /// Returns the SwiftUI Color for this preset
    var color: Color? {
        switch self {
        case .system:
            return nil  // Use system default
        case .darkBlue:
            return Color(red: 0.1, green: 0.2, blue: 0.4)
        case .darkGreen:
            return Color(red: 0.1, green: 0.3, blue: 0.2)
        case .darkPurple:
            return Color(red: 0.25, green: 0.1, blue: 0.35)
        case .darkRed:
            return Color(red: 0.35, green: 0.1, blue: 0.1)
        case .darkOrange:
            return Color(red: 0.4, green: 0.2, blue: 0.1)
        case .black:
            return Color.black
        case .charcoal:
            return Color(red: 0.15, green: 0.15, blue: 0.15)
        }
    }

    /// Primary foreground color for text (high contrast with background)
    var foregroundColor: Color {
        switch self {
        case .system:
            return .primary
        case .darkBlue:
            return Color(red: 0.85, green: 0.92, blue: 1.0)  // Light blue-white
        case .darkGreen:
            return Color(red: 0.85, green: 1.0, blue: 0.9)   // Light mint
        case .darkPurple:
            return Color(red: 0.95, green: 0.88, blue: 1.0)  // Light lavender
        case .darkRed:
            return Color(red: 1.0, green: 0.9, blue: 0.88)   // Light coral
        case .darkOrange:
            return Color(red: 1.0, green: 0.95, blue: 0.88)  // Light cream
        case .black, .charcoal:
            return .white
        }
    }

    /// Secondary foreground color for less prominent text
    var secondaryForegroundColor: Color {
        switch self {
        case .system:
            return .secondary
        case .darkBlue:
            return Color(red: 0.6, green: 0.75, blue: 0.9)
        case .darkGreen:
            return Color(red: 0.6, green: 0.85, blue: 0.7)
        case .darkPurple:
            return Color(red: 0.75, green: 0.65, blue: 0.85)
        case .darkRed:
            return Color(red: 0.9, green: 0.65, blue: 0.6)
        case .darkOrange:
            return Color(red: 0.9, green: 0.75, blue: 0.6)
        case .black, .charcoal:
            return Color(white: 0.7)
        }
    }

    /// Accent color that complements the background
    var accentColor: Color {
        switch self {
        case .system:
            return .green
        case .darkBlue:
            return Color(red: 0.4, green: 0.8, blue: 1.0)    // Bright cyan
        case .darkGreen:
            return Color(red: 0.4, green: 1.0, blue: 0.6)    // Bright mint
        case .darkPurple:
            return Color(red: 0.8, green: 0.5, blue: 1.0)    // Bright violet
        case .darkRed:
            return Color(red: 1.0, green: 0.6, blue: 0.5)    // Bright coral
        case .darkOrange:
            return Color(red: 1.0, green: 0.8, blue: 0.4)    // Bright gold
        case .black, .charcoal:
            return .green
        }
    }
}
