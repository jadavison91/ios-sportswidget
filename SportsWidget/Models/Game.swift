//
//  Game.swift
//  SportsWidget
//
//  Created by Jason Davison on 1/29/26.
//

import Foundation

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
}
