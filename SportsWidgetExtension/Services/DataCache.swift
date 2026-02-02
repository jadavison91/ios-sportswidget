//
//  DataCache.swift
//  SportsWidgetExtension
//
//  Shared - keep in sync with SportsWidget/Services/DataCache.swift
//

import Foundation

/// Manages caching of game data for offline access
actor DataCache {
    static let shared = DataCache()

    private let cacheFileName = "games_cache.json"

    /// In-memory cache for faster repeated reads within the same session
    private var memoryCache: [Game]?
    private var memoryCacheTimestamp: Date?
    private let memoryCacheMaxAge: TimeInterval = 60 // 1 minute

    private init() {}

    /// Saves games to cache
    func saveGames(_ games: [Game]) {
        // Update memory cache immediately
        memoryCache = games
        memoryCacheTimestamp = Date()

        guard let containerURL = AppGroup.containerURL else {
            // Fallback to UserDefaults if container URL is unavailable
            saveToUserDefaults(games)
            return
        }

        let fileURL = containerURL.appendingPathComponent(cacheFileName)

        do {
            let data = try JSONEncoder().encode(games)
            try data.write(to: fileURL, options: .atomic)
            AppGroup.userDefaults.set(Date(), forKey: AppGroup.Keys.lastFetchDate)
        } catch {
            saveToUserDefaults(games)
        }
    }

    /// Loads games from cache (memory -> file -> UserDefaults)
    /// Includes today's completed games for game day persistence
    func loadGames() -> [Game] {
        let startOfToday = Calendar.current.startOfDay(for: Date())

        // Check memory cache first (fastest)
        if let cached = memoryCache,
           let timestamp = memoryCacheTimestamp,
           Date().timeIntervalSince(timestamp) < memoryCacheMaxAge {
            // Keep games from today onwards (including completed games from today)
            let filtered = cached.filter { $0.startTime >= startOfToday }
            if !filtered.isEmpty {
                return filtered
            }
        }

        // Try file-based cache
        if let containerURL = AppGroup.containerURL {
            let fileURL = containerURL.appendingPathComponent(cacheFileName)

            do {
                let data = try Data(contentsOf: fileURL)
                let games = try JSONDecoder().decode([Game].self, from: data)
                // Keep games from today onwards (including completed games from today)
                let filtered = games.filter { $0.startTime >= startOfToday }
                memoryCache = filtered
                memoryCacheTimestamp = Date()
                return filtered
            } catch {
                // File cache failed, continue to UserDefaults
            }
        }

        // Fallback to UserDefaults
        let games = loadFromUserDefaults()
        if !games.isEmpty {
            memoryCache = games
            memoryCacheTimestamp = Date()
        }
        return games
    }

    /// Returns the date of the last successful fetch
    var lastFetchDate: Date? {
        AppGroup.userDefaults.object(forKey: AppGroup.Keys.lastFetchDate) as? Date
    }

    /// Clears all cached data
    func clearCache() {
        // Clear memory cache
        memoryCache = nil
        memoryCacheTimestamp = nil

        // Clear file cache
        if let containerURL = AppGroup.containerURL {
            let fileURL = containerURL.appendingPathComponent(cacheFileName)
            try? FileManager.default.removeItem(at: fileURL)
        }
        AppGroup.userDefaults.removeObject(forKey: AppGroup.Keys.cachedGames)
        AppGroup.userDefaults.removeObject(forKey: AppGroup.Keys.lastFetchDate)
    }

    /// Invalidates the memory cache, forcing next read from disk
    func invalidateMemoryCache() {
        memoryCache = nil
        memoryCacheTimestamp = nil
    }

    /// Checks if cache is stale (older than 24 hours)
    var isCacheStale: Bool {
        guard let lastFetch = lastFetchDate else { return true }
        let staleThreshold: TimeInterval = 24 * 60 * 60 // 24 hours
        return Date().timeIntervalSince(lastFetch) > staleThreshold
    }

    // MARK: - Private Methods

    private func saveToUserDefaults(_ games: [Game]) {
        if let data = try? JSONEncoder().encode(games) {
            AppGroup.userDefaults.set(data, forKey: AppGroup.Keys.cachedGames)
            AppGroup.userDefaults.set(Date(), forKey: AppGroup.Keys.lastFetchDate)
        }
    }

    private func loadFromUserDefaults() -> [Game] {
        guard let data = AppGroup.userDefaults.data(forKey: AppGroup.Keys.cachedGames),
              let games = try? JSONDecoder().decode([Game].self, from: data) else {
            return []
        }
        // Keep games from today onwards (including completed games from today)
        let startOfToday = Calendar.current.startOfDay(for: Date())
        return games.filter { $0.startTime >= startOfToday }
    }
}

// MARK: - Convenience Methods
extension DataCache {
    /// Fetches fresh data and updates cache
    func refreshGames(for teams: [Team]) async throws -> [Game] {
        let games = try await ESPNAPIClient.shared.fetchGames(for: teams)
        saveGames(games)
        return games
    }

    /// Gets games from cache or fetches fresh if stale
    /// Includes league fallback when user's teams aren't playing today
    func getGames(for teams: [Team], forceRefresh: Bool = false) async -> [Game] {
        let teamAbbreviations = Set(teams.map { $0.abbreviation.lowercased() })

        // If forced refresh or cache is stale, fetch fresh data
        if forceRefresh || isCacheStale {
            do {
                let games = try await refreshGames(for: teams)
                let userTeamGames = filterGames(games, forTeams: teamAbbreviations)

                // Apply league fallback and game day sorting
                return await applyDisplayLogic(
                    userTeamGames: userTeamGames,
                    teams: teams
                )
            } catch {
                let cached = filterGames(loadGames(), forTeams: teamAbbreviations)
                return await applyDisplayLogic(userTeamGames: cached, teams: teams)
            }
        }

        // Return cached games with display logic applied
        let cachedGames = loadGames()
        let filtered = filterGames(cachedGames, forTeams: teamAbbreviations)

        if filtered.isEmpty {
            // Try to fetch if no games for selected teams
            do {
                let games = try await refreshGames(for: teams)
                let userTeamGames = filterGames(games, forTeams: teamAbbreviations)
                return await applyDisplayLogic(userTeamGames: userTeamGames, teams: teams)
            } catch {
                return []
            }
        }

        return await applyDisplayLogic(userTeamGames: filtered, teams: teams)
    }

    /// Applies game day persistence and league fallback logic
    /// - Keeps completed games from today visible
    /// - Adds league games when user's team isn't playing today
    private func applyDisplayLogic(userTeamGames: [Game], teams: [Team]) async -> [Game] {
        var result: [Game] = []
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!

        // Separate today's games from future games
        let todayGames = userTeamGames.filter { game in
            game.startTime >= today && game.startTime < tomorrow
        }
        let futureGames = userTeamGames.filter { game in
            game.startTime >= tomorrow
        }

        // Add all of today's games (including completed - game day persistence)
        result.append(contentsOf: todayGames)

        // Check which leagues have user team games today
        let leaguesWithGamesToday = Set(todayGames.map { $0.league.lowercased() })

        // For leagues where user's team ISN'T playing today, fetch league games
        let teamsWithoutGamesToday = teams.filter { team in
            !leaguesWithGamesToday.contains(team.league.lowercased())
        }

        // Group by league to avoid duplicate fetches
        let leaguesToFetch = Dictionary(grouping: teamsWithoutGamesToday) {
            "\($0.sport)/\($0.league)"
        }

        for (_, leagueTeams) in leaguesToFetch {
            guard let firstTeam = leagueTeams.first else { continue }

            do {
                let leagueGames = try await ESPNAPIClient.shared.fetchLeagueGames(
                    sport: firstTeam.sport,
                    league: firstTeam.league
                )
                // Add league games (they're already filtered to today)
                result.append(contentsOf: leagueGames)
            } catch {
                // Silently fail - league fallback is optional
                continue
            }
        }

        // Add future games for user's teams
        result.append(contentsOf: futureGames)

        // Sort: today's games first (by status: in-progress, then completed, then scheduled)
        // Then future games by date
        return result.sorted { game1, game2 in
            let isToday1 = game1.startTime >= today && game1.startTime < tomorrow
            let isToday2 = game2.startTime >= today && game2.startTime < tomorrow

            // Today's games come first
            if isToday1 && !isToday2 { return true }
            if !isToday1 && isToday2 { return false }

            // Within today, sort by status (in-progress first, then scheduled, then completed)
            if isToday1 && isToday2 {
                let priority1 = statusPriority(game1.status)
                let priority2 = statusPriority(game2.status)
                if priority1 != priority2 {
                    return priority1 < priority2
                }
            }

            // Then by start time
            return game1.startTime < game2.startTime
        }
    }

    /// Returns priority for sorting (lower = higher priority)
    private func statusPriority(_ status: Game.GameStatus) -> Int {
        switch status {
        case .inProgress: return 0
        case .scheduled: return 1
        case .completed: return 2
        case .postponed: return 3
        case .canceled: return 4
        }
    }

    /// Filters games to only include those for the specified teams
    private func filterGames(_ games: [Game], forTeams teamAbbreviations: Set<String>) -> [Game] {
        guard !teamAbbreviations.isEmpty else { return games }

        return games.filter { game in
            teamAbbreviations.contains(game.userTeamAbbreviation.lowercased())
        }
    }

    /// Prefetches games for teams in the background (call from app when appropriate)
    func prefetchGames(for teams: [Team]) async {
        // Only prefetch if cache is getting stale (within 2 hours of expiry)
        guard let lastFetch = lastFetchDate else {
            _ = try? await refreshGames(for: teams)
            return
        }

        let timeSinceLastFetch = Date().timeIntervalSince(lastFetch)
        let prefetchThreshold: TimeInterval = 22 * 60 * 60 // 22 hours (2 hours before 24-hour expiry)

        if timeSinceLastFetch > prefetchThreshold {
            _ = try? await refreshGames(for: teams)
        }
    }
}
