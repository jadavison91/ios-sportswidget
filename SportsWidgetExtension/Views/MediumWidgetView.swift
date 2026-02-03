//
//  MediumWidgetView.swift
//  SportsWidgetExtension
//
//  Created by Jason Davison on 1/29/26.
//

import SwiftUI
import WidgetKit

struct MediumWidgetView: View {
    let entry: ScheduleEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Header
            HStack {
                Image(systemName: "sportscourt.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("Your Games")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(entry.formattedLastUpdated)
                    .font(.system(size: 9))
                    .foregroundStyle(.tertiary)
            }

            Divider()

            // Content
            if let error = entry.error {
                errorView(for: error)
            } else if entry.games.isEmpty {
                emptyView
            } else {
                gamesListView
            }
        }
        .padding(12)
    }

    // MARK: - Games List View
    @ViewBuilder
    private var gamesListView: some View {
        let displayGames = Array(entry.games.prefix(4))

        VStack(alignment: .leading, spacing: 4) {
            ForEach(displayGames) { game in
                Link(destination: URL(string: "sportswidget://game/\(game.id)")!) {
                    CompactScorebugRow(game: game)
                }
            }
        }

        Spacer(minLength: 0)
    }

    // MARK: - Error View
    @ViewBuilder
    private func errorView(for error: ScheduleEntry.WidgetError) -> some View {
        HStack {
            Spacer()
            VStack(spacing: 8) {
                Image(systemName: errorIcon(for: error))
                    .font(.title)
                    .foregroundStyle(.secondary)

                Text(error.rawValue)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                if error == .noTeamsSelected {
                    Text("Open the app to add teams")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            Spacer()
        }
        .frame(maxHeight: .infinity)
    }

    private func errorIcon(for error: ScheduleEntry.WidgetError) -> String {
        switch error {
        case .noTeamsSelected:
            return "person.badge.plus"
        case .networkError:
            return "wifi.slash"
        case .noGames:
            return "calendar.badge.minus"
        }
    }

    // MARK: - Empty View
    private var emptyView: some View {
        HStack {
            Spacer()
            VStack(spacing: 8) {
                Image(systemName: "calendar.badge.minus")
                    .font(.title)
                    .foregroundStyle(.secondary)

                Text("No upcoming games")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .frame(maxHeight: .infinity)
    }
}

// MARK: - Compact Scorebug Row View
struct CompactScorebugRow: View {
    let game: Game

    /// Color for away team score - green if winning and game is final
    private var awayScoreColor: Color {
        guard game.status == .completed,
              let awayScore = game.awayScore,
              let homeScore = game.homeScore,
              awayScore > homeScore else {
            return .primary
        }
        return .green
    }

    /// Color for home team score - green if winning and game is final
    private var homeScoreColor: Color {
        guard game.status == .completed,
              let awayScore = game.awayScore,
              let homeScore = game.homeScore,
              homeScore > awayScore else {
            return .primary
        }
        return .green
    }

    var body: some View {
        HStack(spacing: 0) {
            // Away team
            HStack(spacing: 4) {
                Text(game.awayTeamAbbreviation)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .frame(width: 36, alignment: .leading)

                if game.shouldShowScore, let score = game.awayScore {
                    Text("\(score)")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundStyle(awayScoreColor)
                        .frame(width: 28, alignment: .trailing)
                }
            }

            // Separator
            if game.shouldShowScore {
                Text("-")
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 4)
            } else {
                Text(game.isHomeGame ? "vs" : "@")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 6)
            }

            // Home team
            HStack(spacing: 4) {
                if game.shouldShowScore, let score = game.homeScore {
                    Text("\(score)")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundStyle(homeScoreColor)
                        .frame(width: 28, alignment: .leading)
                }

                Text(game.homeTeamAbbreviation)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .frame(width: 36, alignment: .trailing)
            }

            Spacer()

            // Status (FINAL, Q3, 7:30 PM, etc.)
            Text(game.statusDisplay)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundStyle(statusColor)
                .frame(minWidth: 50, alignment: .trailing)
        }
        .contentTransition(.numericText())
    }

    private var statusColor: Color {
        switch game.status {
        case .completed:
            return .secondary
        case .inProgress:
            return .green
        case .postponed, .canceled:
            return .orange
        case .scheduled:
            return .secondary
        }
    }
}

// MARK: - Preview
#Preview(as: .systemMedium) {
    SportsScheduleWidget()
} timeline: {
    ScheduleEntry.placeholder
    ScheduleEntry(
        date: Date(),
        games: [],
        lastUpdated: Date(),
        error: .noTeamsSelected
    )
    ScheduleEntry(
        date: Date(),
        games: [],
        lastUpdated: Date(),
        error: .noGames
    )
}
