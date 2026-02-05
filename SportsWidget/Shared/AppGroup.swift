//
//  AppGroup.swift
//  SportsWidget
//
//  Created by Jason Davison on 1/29/26.
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
        nonisolated static let widgetBackgroundColor = "widgetBackgroundColor"
        nonisolated static let smallWidgetTeamId = "smallWidgetTeamId"
    }
}

// MARK: - Widget Background Color Presets
extension AppGroup {
    /// Available background color presets for the widget
    enum WidgetBackgroundPreset: String, CaseIterable, Sendable {
        case system = "System Default"
        case darkBlue = "Dark Blue"
        case darkGreen = "Dark Green"
        case darkPurple = "Dark Purple"
        case darkRed = "Dark Red"
        case darkOrange = "Dark Orange"
        case black = "Black"
        case charcoal = "Charcoal"
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

    /// Widget background color preset
    static var widgetBackgroundPreset: WidgetBackgroundPreset {
        get {
            guard let rawValue = userDefaults.string(forKey: Keys.widgetBackgroundColor),
                  let preset = WidgetBackgroundPreset(rawValue: rawValue) else {
                return .system
            }
            return preset
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: Keys.widgetBackgroundColor)
        }
    }

    /// Team ID for small widget display (format: "teamId|league")
    /// Returns nil to show "next game" across all teams
    static var smallWidgetTeamId: String? {
        get {
            userDefaults.string(forKey: Keys.smallWidgetTeamId)
        }
        set {
            if let value = newValue {
                userDefaults.set(value, forKey: Keys.smallWidgetTeamId)
            } else {
                userDefaults.removeObject(forKey: Keys.smallWidgetTeamId)
            }
        }
    }

    /// Gets the selected team for small widget from the My Teams list
    static var smallWidgetTeam: Team? {
        get {
            guard let teamId = smallWidgetTeamId else { return nil }
            return selectedTeams.first { "\($0.id)|\($0.league)" == teamId }
        }
        set {
            if let team = newValue {
                smallWidgetTeamId = "\(team.id)|\(team.league)"
            } else {
                smallWidgetTeamId = nil
            }
        }
    }
}
