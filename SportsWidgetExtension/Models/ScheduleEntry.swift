//
//  ScheduleEntry.swift
//  SportsWidgetExtension
//
//  Shared model - keep in sync with SportsWidget/Models/ScheduleEntry.swift
//

import Foundation
import WidgetKit

struct ScheduleEntry: TimelineEntry {
    let date: Date
    let games: [Game]
    let lastUpdated: Date
    let error: WidgetError?
    let pageIndex: Int
    let totalPages: Int
    let logoData: [String: Data]  // Maps logo URL to image data for widget display

    enum WidgetError: String, Codable {
        case noTeamsSelected = "No teams selected"
        case networkError = "Unable to fetch schedule"
        case noGames = "No upcoming games"
    }

    init(date: Date, games: [Game], lastUpdated: Date, error: WidgetError? = nil, pageIndex: Int = 0, totalPages: Int = 1, logoData: [String: Data] = [:]) {
        self.date = date
        self.games = games
        self.lastUpdated = lastUpdated
        self.error = error
        self.pageIndex = pageIndex
        self.totalPages = totalPages
        self.logoData = logoData
    }

    static var placeholder: ScheduleEntry {
        ScheduleEntry(
            date: Date(),
            games: [
                Game(
                    id: "placeholder1",
                    homeTeam: "Los Angeles Lakers",
                    homeTeamAbbreviation: "LAL",
                    homeTeamLogoUrl: nil,
                    awayTeam: "Golden State Warriors",
                    awayTeamAbbreviation: "GSW",
                    awayTeamLogoUrl: nil,
                    startTime: Date().addingTimeInterval(3600 * 3),
                    isHomeGame: true,
                    venue: "Crypto.com Arena",
                    status: .scheduled,
                    userTeamAbbreviation: "LAL",
                    league: "nba",
                    homeScore: nil,
                    awayScore: nil,
                    periodNumber: nil,
                    periodHalf: nil,
                    clock: nil
                ),
                Game(
                    id: "placeholder2",
                    homeTeam: "Boston Celtics",
                    homeTeamAbbreviation: "BOS",
                    homeTeamLogoUrl: nil,
                    awayTeam: "Los Angeles Lakers",
                    awayTeamAbbreviation: "LAL",
                    awayTeamLogoUrl: nil,
                    startTime: Date().addingTimeInterval(3600 * 48),
                    isHomeGame: false,
                    venue: "TD Garden",
                    status: .scheduled,
                    userTeamAbbreviation: "LAL",
                    league: "nba",
                    homeScore: nil,
                    awayScore: nil,
                    periodNumber: nil,
                    periodHalf: nil,
                    clock: nil
                )
            ],
            lastUpdated: Date()
        )
    }

    static var empty: ScheduleEntry {
        ScheduleEntry(
            date: Date(),
            games: [],
            lastUpdated: Date(),
            error: .noGames
        )
    }

    var formattedLastUpdated: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "Updated \(formatter.string(from: lastUpdated))"
    }
}
