//
//  ESPNAPIClient.swift
//  SportsWidgetExtension
//
//  Shared - keep in sync with SportsWidget/Services/ESPNAPIClient.swift
//

import Foundation

/// Client for fetching sports data from ESPN's unofficial API
actor ESPNAPIClient {
    static let shared = ESPNAPIClient()

    private let baseURL = "https://site.api.espn.com/apis/site/v2/sports"
    private let session: URLSession
    private let dateFormatter: DateFormatter

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: config)

        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "yyyyMMdd"
    }

    /// Fetches upcoming games for a specific team over the next 7 days
    /// - Parameter team: The team to fetch games for
    /// - Returns: Array of upcoming games for the team
    func fetchGames(for team: Team) async throws -> [Game] {
        var allGames: [Game] = []
        let dates = getNextDates(count: 7)

        for date in dates {
            let urlString = "\(baseURL)/\(team.sport)/\(team.league)/scoreboard?dates=\(date)"
            guard let url = URL(string: urlString) else { continue }

            do {
                let (data, response) = try await session.data(from: url)

                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else { continue }

                let scoreboard = try JSONDecoder().decode(ESPNScoreboard.self, from: data)
                let games = parseGames(from: scoreboard, for: team)
                allGames.append(contentsOf: games)
            } catch {
                // Continue with other dates if one fails
                print("Failed to fetch games for date \(date): \(error)")
            }
        }

        return allGames.sorted { $0.startTime < $1.startTime }
    }

    /// Fetches games for multiple teams and combines results
    /// - Parameter teams: Array of teams to fetch games for
    /// - Returns: Combined and sorted array of upcoming games
    func fetchGames(for teams: [Team]) async throws -> [Game] {
        var allGames: [Game] = []
        let dates = getNextDates(count: 7)

        // Group teams by league to minimize API calls
        let teamsByLeague = Dictionary(grouping: teams) { "\($0.sport)/\($0.league)" }

        for (_, leagueTeams) in teamsByLeague {
            guard let firstTeam = leagueTeams.first else { continue }

            // Fetch games for each date
            for date in dates {
                do {
                    let urlString = "\(baseURL)/\(firstTeam.sport)/\(firstTeam.league)/scoreboard?dates=\(date)"
                    guard let url = URL(string: urlString) else { continue }

                    let (data, response) = try await session.data(from: url)

                    guard let httpResponse = response as? HTTPURLResponse,
                          httpResponse.statusCode == 200 else { continue }

                    let scoreboard = try JSONDecoder().decode(ESPNScoreboard.self, from: data)

                    // Parse games for each team in this league
                    for team in leagueTeams {
                        let games = parseGames(from: scoreboard, for: team)
                        allGames.append(contentsOf: games)
                    }
                } catch {
                    // Continue with other dates/leagues even if one fails
                    print("Failed to fetch games for \(firstTeam.league) on \(date): \(error)")
                }
            }
        }

        // Sort by start time and remove duplicates (by game ID)
        let uniqueGames = Dictionary(grouping: allGames) { $0.id }
            .compactMap { $0.value.first }
        return uniqueGames.sorted { $0.startTime < $1.startTime }
    }

    /// Fetches all games for a league today (for league fallback when user's team isn't playing)
    /// - Parameters:
    ///   - sport: Sport identifier (e.g., "basketball")
    ///   - league: League identifier (e.g., "nba")
    /// - Returns: All games in the league for today
    func fetchLeagueGames(sport: String, league: String) async throws -> [Game] {
        let today = dateFormatter.string(from: Date())
        let urlString = "\(baseURL)/\(sport)/\(league)/scoreboard?dates=\(today)"

        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }

        let scoreboard = try JSONDecoder().decode(ESPNScoreboard.self, from: data)
        return parseAllLeagueGames(from: scoreboard, league: league)
    }

    /// Parses all games from a league scoreboard (not filtered to a specific team)
    private func parseAllLeagueGames(from scoreboard: ESPNScoreboard, league: String) -> [Game] {
        var games: [Game] = []

        for event in scoreboard.events {
            guard let competition = event.competitions.first else { continue }

            let competitors = competition.competitors
            let homeCompetitor = competitors.first { $0.homeAway == "home" }
            let awayCompetitor = competitors.first { $0.homeAway == "away" }

            guard let home = homeCompetitor, let away = awayCompetitor else { continue }
            guard let startTime = parseDate(event.date) else { continue }

            let status = parseStatus(event.status?.type)
            let homeScore = parseScore(home.score)
            let awayScore = parseScore(away.score)
            let periodNumber = status == .inProgress ? event.status?.period : nil
            let periodHalf = parseInningHalf(event.status?.type?.shortDetail, league: league)
            let clock = event.status?.displayClock

            let game = Game(
                id: event.id,
                homeTeam: home.team.displayName,
                homeTeamAbbreviation: home.team.abbreviation,
                homeTeamLogoUrl: home.team.logo,
                awayTeam: away.team.displayName,
                awayTeamAbbreviation: away.team.abbreviation,
                awayTeamLogoUrl: away.team.logo,
                startTime: startTime,
                isHomeGame: false, // Not relevant for league games
                venue: competition.venue?.fullName,
                status: status,
                userTeamAbbreviation: "", // No specific user team
                league: league,
                homeScore: homeScore,
                awayScore: awayScore,
                periodNumber: periodNumber,
                periodHalf: periodHalf,
                clock: clock
            )
            games.append(game)
        }

        return games.sorted { $0.startTime < $1.startTime }
    }

    /// Returns the next N dates in yyyyMMdd format
    private func getNextDates(count: Int) -> [String] {
        var dates: [String] = []
        let calendar = Calendar.current

        for dayOffset in 0..<count {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: Date()) {
                dates.append(dateFormatter.string(from: date))
            }
        }

        return dates
    }

    private func parseGames(from scoreboard: ESPNScoreboard, for team: Team) -> [Game] {
        var games: [Game] = []
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())

        for event in scoreboard.events {
            guard let competition = event.competitions.first else { continue }

            // Find if this game involves our team
            let competitors = competition.competitors
            guard let userTeamCompetitor = competitors.first(where: {
                $0.team.abbreviation.lowercased() == team.abbreviation.lowercased()
            }) else { continue }

            let homeCompetitor = competitors.first { $0.homeAway == "home" }
            let awayCompetitor = competitors.first { $0.homeAway == "away" }

            guard let home = homeCompetitor, let away = awayCompetitor else { continue }

            // Parse the date
            guard let startTime = parseDate(event.date) else { continue }

            // Include games from today onwards (including completed games from today)
            guard startTime >= startOfToday else { continue }

            let isHomeGame = userTeamCompetitor.homeAway == "home"
            let status = parseStatus(event.status?.type)

            // Parse scores (only if game has started)
            let homeScore = parseScore(home.score)
            let awayScore = parseScore(away.score)

            // Parse period info for in-progress games
            let periodNumber = status == .inProgress ? event.status?.period : nil
            let periodHalf = parseInningHalf(event.status?.type?.shortDetail, league: team.league)
            let clock = event.status?.displayClock

            let game = Game(
                id: event.id,
                homeTeam: home.team.displayName,
                homeTeamAbbreviation: home.team.abbreviation,
                homeTeamLogoUrl: home.team.logo,
                awayTeam: away.team.displayName,
                awayTeamAbbreviation: away.team.abbreviation,
                awayTeamLogoUrl: away.team.logo,
                startTime: startTime,
                isHomeGame: isHomeGame,
                venue: competition.venue?.fullName,
                status: status,
                userTeamAbbreviation: team.abbreviation,
                league: team.league,
                homeScore: homeScore,
                awayScore: awayScore,
                periodNumber: periodNumber,
                periodHalf: periodHalf,
                clock: clock
            )
            games.append(game)
        }

        return games.sorted { $0.startTime < $1.startTime }
    }

    private func parseScore(_ scoreString: String?) -> Int? {
        guard let scoreString = scoreString else { return nil }
        return Int(scoreString)
    }

    /// Parses inning half (top/bottom) from ESPN shortDetail for baseball
    /// ESPN returns things like "Top 5th", "Bot 7th", etc.
    private func parseInningHalf(_ shortDetail: String?, league: String) -> String? {
        guard league.lowercased() == "mlb", let detail = shortDetail?.lowercased() else { return nil }
        if detail.contains("top") {
            return "top"
        } else if detail.contains("bot") || detail.contains("bottom") {
            return "bottom"
        }
        return nil
    }

    private func parseDate(_ dateString: String) -> Date? {
        // Try ISO8601 with fractional seconds first
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: dateString) {
            return date
        }

        // Try ISO8601 without fractional seconds
        isoFormatter.formatOptions = [.withInternetDateTime]
        if let date = isoFormatter.date(from: dateString) {
            return date
        }

        // ESPN often returns dates without seconds (e.g., "2026-01-31T00:00Z")
        // Use a custom DateFormatter to handle this format
        let customFormatter = DateFormatter()
        customFormatter.locale = Locale(identifier: "en_US_POSIX")
        customFormatter.timeZone = TimeZone(identifier: "UTC")

        // Try format without seconds: "2026-01-31T00:00Z"
        customFormatter.dateFormat = "yyyy-MM-dd'T'HH:mmX"
        if let date = customFormatter.date(from: dateString) {
            return date
        }

        // Try format with seconds: "2026-01-31T00:00:00Z"
        customFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssX"
        return customFormatter.date(from: dateString)
    }

    private func parseStatus(_ statusType: ESPNStatusType?) -> Game.GameStatus {
        guard let statusType = statusType else { return .scheduled }

        // Check the completed flag first (most reliable)
        if statusType.completed == true {
            return .completed
        }

        // Check the state field (ESPN often uses "pre", "in", "post")
        if let state = statusType.state?.lowercased() {
            if state == "post" {
                return .completed
            } else if state == "in" {
                return .inProgress
            } else if state == "pre" {
                return .scheduled
            }
        }

        // Check name and shortDetail for status keywords
        let textsToCheck = [
            statusType.name?.lowercased(),
            statusType.shortDetail?.lowercased()
        ].compactMap { $0 }

        for text in textsToCheck {
            // Completed states
            if text.contains("final") || text.contains("post") ||
               text == "ft" || text.contains("full time") || text.contains("fulltime") ||
               text == "aet" || text.contains("after extra") ||
               text.contains("ended") || text.contains("complete") {
                return .completed
            }
            // In-progress states
            if text.contains("progress") || text.contains("in_progress") || text == "in" ||
               text.contains("halftime") || text.contains("half") || text == "ht" ||
               text == "1h" || text == "2h" || text.contains("live") {
                return .inProgress
            }
            // Postponed
            if text.contains("postpone") {
                return .postponed
            }
            // Canceled
            if text.contains("cancel") || text.contains("abandon") {
                return .canceled
            }
        }

        return .scheduled
    }
}

// MARK: - API Error
extension ESPNAPIClient {
    enum APIError: Error, LocalizedError {
        case invalidURL
        case invalidResponse
        case httpError(statusCode: Int)
        case decodingError(Error)
        case noData

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid API URL"
            case .invalidResponse:
                return "Invalid response from server"
            case .httpError(let statusCode):
                return "HTTP error: \(statusCode)"
            case .decodingError(let error):
                return "Failed to decode response: \(error.localizedDescription)"
            case .noData:
                return "No data received"
            }
        }
    }
}

// MARK: - ESPN API Response Models
struct ESPNScoreboard: Codable, Sendable {
    let events: [ESPNEvent]

    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.events = try container.decodeIfPresent([ESPNEvent].self, forKey: .events) ?? []
    }

    enum CodingKeys: String, CodingKey {
        case events
    }
}

struct ESPNEvent: Codable, Sendable {
    let id: String
    let name: String
    let date: String
    let competitions: [ESPNCompetition]
    let status: ESPNStatus?
}

struct ESPNCompetition: Codable, Sendable {
    let competitors: [ESPNCompetitor]
    let venue: ESPNVenue?
}

struct ESPNCompetitor: Codable, Sendable {
    let homeAway: String
    let team: ESPNTeam
    let score: String?
}

struct ESPNTeam: Codable, Sendable {
    let displayName: String
    let abbreviation: String
    let logo: String?
}

struct ESPNVenue: Codable, Sendable {
    let fullName: String?
}

struct ESPNStatus: Codable, Sendable {
    let type: ESPNStatusType?
    let period: Int?
    let displayClock: String?
}

struct ESPNStatusType: Codable, Sendable {
    let name: String?
    let state: String?        // "pre", "in", "post"
    let completed: Bool?
    let shortDetail: String?  // e.g., "Q3 5:32", "Final", "7:30 PM EST"
}
