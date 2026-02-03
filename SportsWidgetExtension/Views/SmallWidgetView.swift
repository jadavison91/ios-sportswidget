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

    private var colorPalette: AppGroup.WidgetBackgroundPreset {
        AppGroup.widgetBackgroundPreset
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Header
            HStack {
                Image(systemName: "sportscourt.fill")
                    .font(.caption)
                    .foregroundStyle(colorPalette.accentColor)
                Text("Gametime")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(colorPalette.foregroundColor)
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
                .font(.system(size: 9, design: .rounded))
                .foregroundStyle(colorPalette.secondaryForegroundColor)
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
                .foregroundStyle(colorPalette.secondaryForegroundColor)

            Text(error.rawValue)
                .font(.caption)
                .foregroundStyle(colorPalette.secondaryForegroundColor)
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
                .foregroundStyle(colorPalette.secondaryForegroundColor)

            Text("No upcoming games")
                .font(.caption)
                .foregroundStyle(colorPalette.secondaryForegroundColor)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Small Widget Game Row View
struct SmallGameRowView: View {
    let game: Game

    private var colorPalette: AppGroup.WidgetBackgroundPreset {
        AppGroup.widgetBackgroundPreset
    }

    /// Color for away team score - green if winning and game is final, otherwise uses palette
    private var awayScoreColor: Color {
        guard game.status == .completed,
              let awayScore = game.awayScore,
              let homeScore = game.homeScore,
              awayScore > homeScore else {
            return colorPalette.foregroundColor
        }
        return .green
    }

    /// Color for home team score - green if winning and game is final, otherwise uses palette
    private var homeScoreColor: Color {
        guard game.status == .completed,
              let awayScore = game.awayScore,
              let homeScore = game.homeScore,
              homeScore > awayScore else {
            return colorPalette.foregroundColor
        }
        return .green
    }

    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            // League badge (centered above game)
            Text(game.leagueBadge)
                .font(.system(size: 8, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(game.leagueColor)
                .clipShape(RoundedRectangle(cornerRadius: 3))

            // Teams and score (centered)
            HStack(spacing: 4) {
                Text(game.awayTeamAbbreviation)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(colorPalette.foregroundColor)

                if game.shouldShowScore {
                    if let away = game.awayScore, let home = game.homeScore {
                        HStack(spacing: 2) {
                            Text("\(away)")
                                .foregroundStyle(awayScoreColor)
                            Text("-")
                                .foregroundStyle(colorPalette.secondaryForegroundColor)
                            Text("\(home)")
                                .foregroundStyle(homeScoreColor)
                        }
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                    }
                } else {
                    Text("@")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(colorPalette.secondaryForegroundColor)
                }

                Text(game.homeTeamAbbreviation)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(colorPalette.foregroundColor)
            }

            // Status (centered)
            Text(game.statusDisplay)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(statusColor)
        }
        .frame(maxWidth: .infinity)
        .contentTransition(.numericText())
    }

    private var statusColor: Color {
        switch game.status {
        case .completed:
            return colorPalette.foregroundColor
        case .inProgress:
            return colorPalette.accentColor
        case .postponed, .canceled:
            return .orange
        case .scheduled:
            return colorPalette.foregroundColor
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
