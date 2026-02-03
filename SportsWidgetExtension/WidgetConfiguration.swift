//
//  WidgetConfiguration.swift
//  SportsWidgetExtension
//
//  Created by Jason Davison on 1/30/26.
//

import AppIntents
import WidgetKit
import SwiftUI

// MARK: - Team Entity for Widget Configuration
struct TeamEntity: AppEntity {
    let id: String
    let league: String
    let name: String
    let abbreviation: String

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Team"

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(abbreviation) - \(name)")
    }

    static var defaultQuery = TeamQuery()

    /// Convert from Team model
    init(from team: Team) {
        self.id = team.id
        self.league = team.league
        self.name = team.name
        self.abbreviation = team.abbreviation
    }

    init(id: String, league: String, name: String, abbreviation: String) {
        self.id = id
        self.league = league
        self.name = name
        self.abbreviation = abbreviation
    }

    /// Convert back to Team model
    func toTeam() -> Team? {
        Team.allTeams.first { $0.id == id && $0.league == league }
    }
}

// MARK: - Team Entity Query
struct TeamQuery: EntityQuery {
    func entities(for identifiers: [TeamEntity.ID]) async throws -> [TeamEntity] {
        let allTeams = Team.allTeams
        return identifiers.compactMap { identifier in
            // identifier format: "id-league"
            let parts = identifier.split(separator: "-", maxSplits: 1)
            guard parts.count == 2 else { return nil }
            let id = String(parts[0])
            let league = String(parts[1])

            if let team = allTeams.first(where: { $0.id == id && $0.league == league }) {
                return TeamEntity(from: team)
            }
            return nil
        }
    }

    func suggestedEntities() async throws -> [TeamEntity] {
        // Return user's selected teams first, then popular teams
        let selectedTeams = AppGroup.selectedTeams
        if !selectedTeams.isEmpty {
            return selectedTeams.map { TeamEntity(from: $0) }
        }

        // Return some popular teams as suggestions
        let popularTeams = [
            Team.nbaTeams.first { $0.abbreviation == "LAL" },
            Team.nflTeams.first { $0.abbreviation == "KC" },
            Team.mlbTeams.first { $0.abbreviation == "NYY" },
            Team.nhlTeams.first { $0.abbreviation == "TOR" },
            Team.eplTeams.first { $0.abbreviation == "LIV" }
        ].compactMap { $0 }

        return popularTeams.map { TeamEntity(from: $0) }
    }

    func defaultResult() async -> TeamEntity? {
        // Return first selected team or nil
        if let firstTeam = AppGroup.selectedTeams.first {
            return TeamEntity(from: firstTeam)
        }
        return nil
    }
}

extension TeamEntity {
    // Unique identifier combining id and league
    var entityIdentifier: String {
        "\(id)-\(league)"
    }
}

// MARK: - Widget Configuration Intent
struct SportsWidgetConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configure Gametime"
    static var description = IntentDescription("Choose which teams to display in your widget.")

    @Parameter(title: "Teams", description: "Select teams to track")
    var selectedTeams: [TeamEntity]?

    @Parameter(title: "Max Games", default: 5)
    var maxGames: Int

    init() {
        self.selectedTeams = nil
        self.maxGames = 5
    }

    init(selectedTeams: [TeamEntity]?, maxGames: Int = 5) {
        self.selectedTeams = selectedTeams
        self.maxGames = maxGames
    }
}

// MARK: - Configurable Timeline Provider
struct ConfigurableSportsScheduleProvider: AppIntentTimelineProvider {
    typealias Entry = ScheduleEntry
    typealias Intent = SportsWidgetConfigurationIntent

    func placeholder(in context: Context) -> ScheduleEntry {
        ScheduleEntry.placeholder
    }

    func snapshot(for configuration: SportsWidgetConfigurationIntent, in context: Context) async -> ScheduleEntry {
        if context.isPreview {
            return ScheduleEntry.placeholder
        }
        return await fetchCurrentEntry(for: configuration)
    }

    func timeline(for configuration: SportsWidgetConfigurationIntent, in context: Context) async -> Timeline<ScheduleEntry> {
        let entry = await fetchCurrentEntry(for: configuration)
        // Schedule next update in 15 minutes for timely score updates
        let nextUpdate = Date().addingTimeInterval(15 * 60) // 15 minutes
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }

    private func fetchCurrentEntry(for configuration: SportsWidgetConfigurationIntent) async -> ScheduleEntry {
        // Get teams from configuration or fall back to app-selected teams
        let teams: [Team]
        if let configTeams = configuration.selectedTeams, !configTeams.isEmpty {
            teams = configTeams.compactMap { $0.toTeam() }
        } else {
            teams = AppGroup.selectedTeams
        }

        // Check if user has selected any teams
        guard !teams.isEmpty else {
            return ScheduleEntry(
                date: Date(),
                games: [],
                lastUpdated: Date(),
                error: .noTeamsSelected
            )
        }

        // Try to fetch games
        let games = await DataCache.shared.getGames(for: teams)

        if games.isEmpty {
            return ScheduleEntry(
                date: Date(),
                games: [],
                lastUpdated: Date(),
                error: .noGames
            )
        }

        // Limit to configured max games
        let maxGames = configuration.maxGames > 0 ? configuration.maxGames : 5
        let limitedGames = Array(games.prefix(maxGames))

        return ScheduleEntry(
            date: Date(),
            games: limitedGames,
            lastUpdated: await DataCache.shared.lastFetchDate ?? Date()
        )
    }

}

// MARK: - Configurable Widget
struct ConfigurableSportsScheduleWidget: Widget {
    let kind: String = "ConfigurableSportsScheduleWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SportsWidgetConfigurationIntent.self,
            provider: ConfigurableSportsScheduleProvider()
        ) { entry in
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
