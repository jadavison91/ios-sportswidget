//
//  AppGroup.swift
//  SportsWidgetExtension
//
//  Shared - keep in sync with SportsWidget/Shared/AppGroup.swift
//

import Foundation

/// Manages shared data between the main app and widget extension using App Groups
/// Note: Properties use nonisolated(unsafe) as UserDefaults and FileManager are thread-safe
enum AppGroup: Sendable {
    /// The App Group identifier - must match the identifier in entitlements
    nonisolated static let identifier = "group.com.jdavison91.sportswidget"

    /// Shared UserDefaults for the app group
    nonisolated(unsafe) static var userDefaults: UserDefaults {
        UserDefaults(suiteName: identifier) ?? .standard
    }

    /// Shared container URL for file storage
    nonisolated(unsafe) static var containerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier)
    }
}

// MARK: - UserDefaults Keys
extension AppGroup {
    enum Keys: Sendable {
        nonisolated static let selectedTeams = "selectedTeams"
        nonisolated static let cachedGames = "cachedGames"
        nonisolated static let lastFetchDate = "lastFetchDate"
        nonisolated static let use24HourTime = "use24HourTime"
        nonisolated static let maxGamesToShow = "maxGamesToShow"
        nonisolated static let scrollInterval = "scrollInterval"
    }
}

// MARK: - Selected Teams Management
extension AppGroup {
    static var selectedTeams: [Team] {
        get {
            guard let data = userDefaults.data(forKey: Keys.selectedTeams),
                  let teams = try? JSONDecoder().decode([Team].self, from: data) else {
                return []
            }
            return teams
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                userDefaults.set(data, forKey: Keys.selectedTeams)
            }
        }
    }

    static func addTeam(_ team: Team) {
        var teams = selectedTeams
        if !teams.contains(where: { $0.id == team.id && $0.league == team.league }) {
            teams.append(team)
            selectedTeams = teams
        }
    }

    static func removeTeam(_ team: Team) {
        var teams = selectedTeams
        teams.removeAll { $0.id == team.id && $0.league == team.league }
        selectedTeams = teams
    }

    static func isTeamSelected(_ team: Team) -> Bool {
        selectedTeams.contains { $0.id == team.id && $0.league == team.league }
    }
}

// MARK: - Settings
extension AppGroup {
    static var use24HourTime: Bool {
        get { userDefaults.bool(forKey: Keys.use24HourTime) }
        set { userDefaults.set(newValue, forKey: Keys.use24HourTime) }
    }

    static var maxGamesToShow: Int {
        get {
            let value = userDefaults.integer(forKey: Keys.maxGamesToShow)
            return value > 0 ? value : 5 // Default to 5
        }
        set { userDefaults.set(newValue, forKey: Keys.maxGamesToShow) }
    }

    /// Scroll interval in seconds for auto-rotating between game pages
    static var scrollInterval: Int {
        get {
            let value = userDefaults.integer(forKey: Keys.scrollInterval)
            return value > 0 ? value : 10 // Default to 10 seconds
        }
        set { userDefaults.set(newValue, forKey: Keys.scrollInterval) }
    }
}
