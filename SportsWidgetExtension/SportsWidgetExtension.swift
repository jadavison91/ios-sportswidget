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

        // Limit to what the widget can display
        let maxGames = maxGamesForWidget(family)
        let games = Array(allGames.prefix(maxGames))

        return ScheduleEntry(
            date: Date(),
            games: games,
            lastUpdated: lastUpdated
        )
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
}
