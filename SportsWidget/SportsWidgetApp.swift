//
//  SportsWidgetApp.swift
//  SportsWidget
//
//  Created by Jason Davison on 1/29/26.
//

import SwiftUI

@main
struct SportsWidgetApp: App {
    @State private var navigationPath = NavigationPath()
    @State private var selectedGameID: String?

    var body: some Scene {
        WindowGroup {
            ContentView(selectedGameID: $selectedGameID)
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
    }

    private func handleDeepLink(_ url: URL) {
        // URL format: sportswidget://game/{gameID}
        // or: sportswidget://team/{teamAbbreviation}/{league}
        guard url.scheme == "sportswidget" else { return }

        let pathComponents = url.pathComponents.filter { $0 != "/" }

        switch url.host {
        case "game":
            if let gameID = pathComponents.first {
                selectedGameID = gameID
            }
        case "team":
            // Future: navigate to team details
            break
        case "refresh":
            // Trigger a refresh
            NotificationCenter.default.post(name: .refreshGames, object: nil)
        default:
            break
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let refreshGames = Notification.Name("refreshGames")
}
