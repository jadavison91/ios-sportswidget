//
//  Game.swift
//  SportsWidgetExtension
//
//  Shared model - keep in sync with SportsWidget/Models/Game.swift
//

import Foundation
import SwiftUI

struct Game: Codable, Identifiable, Hashable {
    let id: String
    let homeTeam: String
    let homeTeamAbbreviation: String
    let homeTeamLogoUrl: String?  // Team logo URL from ESPN API
    let awayTeam: String
    let awayTeamAbbreviation: String
    let awayTeamLogoUrl: String?  // Team logo URL from ESPN API
    let startTime: Date
    let isHomeGame: Bool    // Is user's team at home?
    let venue: String?
    let status: GameStatus
    let userTeamAbbreviation: String // The user's team in this game
    let league: String       // League identifier (e.g., "nba", "nfl", "mlb", "nhl", "eng.1")

    // Score fields (nil if game hasn't started)
    let homeScore: Int?
    let awayScore: Int?
    let periodNumber: Int?   // Raw period/quarter/inning number
    let periodHalf: String?  // For baseball: "top" or "bottom"
    let clock: String?       // Game clock (stored but not displayed)

    enum GameStatus: String, Codable {
        case scheduled = "scheduled"
        case postponed = "postponed"
        case canceled = "canceled"
        case inProgress = "in_progress"
        case completed = "completed"
    }

    var opponent: String {
        isHomeGame ? awayTeamAbbreviation : homeTeamAbbreviation
    }

    var opponentFullName: String {
        isHomeGame ? awayTeam : homeTeam
    }

    var gameDescription: String {
        if isHomeGame {
            return "\(userTeamAbbreviation) vs \(awayTeamAbbreviation)"
        } else {
            return "\(userTeamAbbreviation) @ \(homeTeamAbbreviation)"
        }
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: startTime)
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        let calendar = Calendar.current

        if calendar.isDateInToday(startTime) {
            return "Today"
        } else if calendar.isDateInTomorrow(startTime) {
            return "Tomorrow"
        } else {
            formatter.dateFormat = "EEE, MMM d"
            return formatter.string(from: startTime)
        }
    }

    var formattedDateTime: String {
        "\(formattedDate) • \(formattedTime)"
    }

    // MARK: - Score Display

    /// Returns true if the game has score data available
    var hasScore: Bool {
        homeScore != nil && awayScore != nil
    }

    /// User's team score (if available)
    var userTeamScore: Int? {
        isHomeGame ? homeScore : awayScore
    }

    /// Opponent's score (if available)
    var opponentScore: Int? {
        isHomeGame ? awayScore : homeScore
    }

    /// Formatted score string (e.g., "102 - 98")
    var scoreDisplay: String? {
        guard let home = homeScore, let away = awayScore else { return nil }
        return "\(home) - \(away)"
    }

    /// Status display for widget (e.g., "FINAL", "Q3", "Fri 7:30P")
    var statusDisplay: String {
        switch status {
        case .completed:
            return "FINAL"
        case .inProgress:
            return formattedPeriod ?? "LIVE"
        case .postponed:
            return "PPD"
        case .canceled:
            return "CAN"
        case .scheduled:
            return compactDateTime
        }
    }

    /// Compact date/time for scheduled games (e.g., "7:30P", "2/1 7:30P")
    private var compactDateTime: String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = Locale.current

        // Time portion (compact: "7:30P" instead of "7:30 PM")
        formatter.dateFormat = "h:mma"
        let timeString = formatter.string(from: startTime)
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "AM", with: "A")
            .replacingOccurrences(of: "PM", with: "P")

        // Today: just time. Future: MM/DD + time
        if calendar.isDateInToday(startTime) {
            return timeString
        } else {
            formatter.dateFormat = "M/d"
            let dateString = formatter.string(from: startTime)
            return "\(dateString) \(timeString)"
        }
    }

    /// Formats the period based on sport type
    var formattedPeriod: String? {
        guard let period = periodNumber else { return nil }

        switch league.lowercased() {
        case "nba", "nfl":
            // Basketball & Football: Q1, Q2, Q3, Q4, OT
            if period <= 4 {
                return "Q\(period)"
            } else {
                return "OT"
            }

        case "nhl":
            // Hockey: 1st, 2nd, 3rd, OT
            switch period {
            case 1: return "1st"
            case 2: return "2nd"
            case 3: return "3rd"
            default: return "OT"
            }

        case "mlb":
            // Baseball: ↑7, ↓7 (arrows for top/bottom)
            let arrow = periodHalf?.lowercased() == "top" ? "↑" : "↓"
            return "\(arrow)\(period)"

        case "eng.1", "eng.2", "usa.usl.c":
            // Soccer: 1st, 2nd, ET
            switch period {
            case 1: return "1st"
            case 2: return "2nd"
            default: return "ET"
            }

        default:
            // Generic fallback
            return "P\(period)"
        }
    }

    /// Whether this game should show a score (in progress or completed)
    var shouldShowScore: Bool {
        hasScore && (status == .inProgress || status == .completed)
    }

    /// League logo URL from ESPN CDN
    var leagueLogoUrl: String {
        switch league.lowercased() {
        // US Sports - use league name pattern
        case "nba":
            return "https://a.espncdn.com/i/teamlogos/leagues/500/nba.png"
        case "nfl":
            return "https://a.espncdn.com/i/teamlogos/leagues/500/nfl.png"
        case "mlb":
            return "https://a.espncdn.com/i/teamlogos/leagues/500/mlb.png"
        case "nhl":
            return "https://a.espncdn.com/i/teamlogos/leagues/500/nhl.png"
        // Soccer - use league ID pattern
        case "eng.1":  // Premier League
            return "https://a.espncdn.com/i/leaguelogos/soccer/500/23.png"
        case "eng.2":  // EFL Championship
            return "https://a.espncdn.com/i/leaguelogos/soccer/500/24.png"
        case "usa.usl.1", "usl":  // USL Championship
            return "https://a.espncdn.com/i/leaguelogos/soccer/500/2292.png"
        case "usa.1":  // MLS
            return "https://a.espncdn.com/i/leaguelogos/soccer/500/19.png"
        default:
            return "https://a.espncdn.com/i/teamlogos/leagues/500/nba.png"
        }
    }

    /// Short badge text for league
    var leagueBadge: String {
        switch league.lowercased() {
        case "nba": return "NBA"
        case "nfl": return "NFL"
        case "mlb": return "MLB"
        case "nhl": return "NHL"
        case "eng.1": return "EPL"
        case "eng.2": return "EFL"
        case "usa.usl.1", "usl": return "USL"
        case "usa.1": return "MLS"
        default: return league.prefix(3).uppercased()
        }
    }

    /// Color for league badge
    var leagueColor: Color {
        switch league.lowercased() {
        case "nba": return Color(red: 0.77, green: 0.11, blue: 0.19)  // NBA red
        case "nfl": return Color(red: 0.0, green: 0.21, blue: 0.47)   // NFL blue
        case "mlb": return Color(red: 0.75, green: 0.0, blue: 0.17)   // MLB red
        case "nhl": return Color(red: 0.0, green: 0.0, blue: 0.0)     // NHL black
        case "eng.1": return Color(red: 0.22, green: 0.0, blue: 0.47) // EPL purple
        case "eng.2": return Color(red: 0.91, green: 0.44, blue: 0.13) // EFL orange
        case "usa.usl.1", "usl": return Color(red: 0.0, green: 0.31, blue: 0.56) // USL blue
        case "usa.1": return Color(red: 0.0, green: 0.24, blue: 0.45) // MLS blue
        default: return Color.gray
        }
    }
}
