//
//  SmallWidgetView.swift
//  SportsWidgetExtension
//
//  Created by Jason Davison on 1/29/26.
//

import SwiftUI
import WidgetKit

struct SmallWidgetView: View {
    let entry: ScheduleEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Header
            HStack {
                Image(systemName: "sportscourt.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("Games")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                Spacer()
            }

            Spacer(minLength: 4)

            // Content
            if let error = entry.error {
                errorView(for: error)
            } else if entry.games.isEmpty {
                emptyView
            } else {
                gamesListView
            }

            Spacer(minLength: 4)

            // Footer
            Text(entry.formattedLastUpdated)
                .font(.system(size: 9))
                .foregroundStyle(.tertiary)
        }
        .padding(12)
        .widgetURL(widgetDeepLink)
    }

    /// Deep link URL for the first game, or app root
    private var widgetDeepLink: URL {
        if let firstGame = entry.games.first {
            return URL(string: "sportswidget://game/\(firstGame.id)")!
        }
        return URL(string: "sportswidget://")!
    }

    // MARK: - Games List View
    @ViewBuilder
    private var gamesListView: some View {
        if let game = entry.games.first {
            SmallGameRowView(game: game)
        }
    }

    // MARK: - Error View
    @ViewBuilder
    private func errorView(for error: ScheduleEntry.WidgetError) -> some View {
        VStack(spacing: 8) {
            Image(systemName: errorIcon(for: error))
                .font(.title2)
                .foregroundStyle(.secondary)

            Text(error.rawValue)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        VStack(spacing: 8) {
            Image(systemName: "calendar.badge.minus")
                .font(.title2)
                .foregroundStyle(.secondary)

            Text("No upcoming games")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Small Widget Game Row View
struct SmallGameRowView: View {
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
        VStack(alignment: .leading, spacing: 2) {
            // Teams and score
            HStack(spacing: 4) {
                Text(game.awayTeamAbbreviation)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))

                if game.shouldShowScore {
                    if let away = game.awayScore, let home = game.homeScore {
                        HStack(spacing: 1) {
                            Text("\(away)")
                                .foregroundStyle(awayScoreColor)
                            Text("-")
                            Text("\(home)")
                                .foregroundStyle(homeScoreColor)
                        }
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                    }
                } else {
                    Text(game.isHomeGame ? "vs" : "@")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }

                Text(game.homeTeamAbbreviation)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))

                Spacer()
            }

            // Status line
            HStack(spacing: 4) {
                Text(game.statusDisplay)
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(statusColor)
                Spacer()
            }
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
#Preview(as: .systemSmall) {
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
