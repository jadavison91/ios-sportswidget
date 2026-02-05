//
//  SmallWidgetView.swift
//  SportsWidgetExtension
//
//  Created by Jason Davison on 1/29/26.
//

import SwiftUI
import UIKit
import WidgetKit

struct SmallWidgetView: View {
    let entry: ScheduleEntry

    private var colorPalette: AppGroup.WidgetBackgroundPreset {
        AppGroup.widgetBackgroundPreset
    }

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            // Two-tone GAMETIME title
            HStack(spacing: 0) {
                Text("GAME")
                    .foregroundStyle(colorPalette.gameColor)
                Text("TIME")
                    .foregroundStyle(colorPalette.timeColor)
            }
            .font(.system(size: 12, weight: .heavy, design: .rounded))
            .padding(.top, 8)

            // Content
            if let error = entry.error {
                errorView(for: error)
            } else if entry.games.isEmpty {
                emptyView
            } else {
                gamesListView
            }
        }
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
            SmallGameRowView(game: game, logoData: entry.logoData)
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
    let logoData: [String: Data]

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

    /// Creates an Image from logo data, or falls back to abbreviation text
    @ViewBuilder
    private func teamLogo(url: String?, abbreviation: String) -> some View {
        if let urlString = url,
           let data = logoData[urlString],
           let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 44, height: 44)
        } else {
            // Fallback to abbreviation
            Text(abbreviation)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(colorPalette.foregroundColor)
                .frame(width: 44, height: 44)
        }
    }

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Spacer()

            // Teams with logos and score (centered)
            HStack(spacing: 12) {
                // Away team logo
                teamLogo(url: game.awayTeamLogoUrl, abbreviation: game.awayTeamAbbreviation)

                // Score or @ symbol
                if game.shouldShowScore {
                    if let away = game.awayScore, let home = game.homeScore {
                        HStack(spacing: 3) {
                            Text("\(away)")
                                .foregroundStyle(awayScoreColor)
                            Text("-")
                                .foregroundStyle(colorPalette.secondaryForegroundColor)
                            Text("\(home)")
                                .foregroundStyle(homeScoreColor)
                        }
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                    }
                } else {
                    Text("@")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(colorPalette.secondaryForegroundColor)
                }

                // Home team logo
                teamLogo(url: game.homeTeamLogoUrl, abbreviation: game.homeTeamAbbreviation)
            }

            Spacer()

            // League status bar (full width with league color)
            HStack(spacing: 6) {
                Text(game.leagueBadge)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                Text(game.statusDisplay)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
            .background(game.leagueColor)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
