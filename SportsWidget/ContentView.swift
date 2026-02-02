//
//  ContentView.swift
//  SportsWidget
//
//  Created by Jason Davison on 1/29/26.
//

import SwiftUI
import WidgetKit

// MARK: - Main Tab View Container
struct ContentView: View {
    @Binding var selectedGameID: String?
    @State private var selectedTab: Tab = .myTeams

    enum Tab {
        case myTeams
        case scores
    }

    init(selectedGameID: Binding<String?> = .constant(nil)) {
        self._selectedGameID = selectedGameID
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            MyTeamsView(selectedGameID: $selectedGameID)
                .tabItem {
                    Label("My Teams", systemImage: "star.fill")
                }
                .tag(Tab.myTeams)

            ScoreboardView()
                .tabItem {
                    Label("Scores", systemImage: "sportscourt.fill")
                }
                .tag(Tab.scores)
        }
    }
}

// MARK: - My Teams View
struct MyTeamsView: View {
    @Binding var selectedGameID: String?
    @State private var selectedTeams: [Team] = AppGroup.selectedTeams
    @State private var showingTeamPicker = false
    @State private var isRefreshing = false
    @State private var upcomingGames: [Game] = []
    @State private var lastRefreshError: String?
    @State private var highlightedGameID: String?

    var body: some View {
        NavigationStack {
            List {
                // Upcoming Games Section (first)
                if !selectedTeams.isEmpty {
                    Section("Upcoming Games") {
                        if isRefreshing {
                            HStack {
                                ProgressView()
                                    .padding(.trailing, 8)
                                Text("Loading games...")
                                    .foregroundStyle(.secondary)
                            }
                        } else if upcomingGames.isEmpty {
                            HStack {
                                Image(systemName: "calendar.badge.minus")
                                    .foregroundStyle(.secondary)
                                Text("No upcoming games scheduled")
                                    .foregroundStyle(.secondary)
                            }
                        } else {
                            ForEach(upcomingGames.prefix(10)) { game in
                                GameRowView(
                                    game: game,
                                    selectedTeams: selectedTeams,
                                    isHighlighted: highlightedGameID == game.id
                                )
                            }
                        }
                    }
                }

                // Your Teams Section (second)
                Section {
                    if selectedTeams.isEmpty {
                        ContentUnavailableView {
                            Label("No Teams Selected", systemImage: "sportscourt")
                        } description: {
                            Text("Add your favorite teams to see their upcoming games.")
                        } actions: {
                            Button("Add Teams") {
                                showingTeamPicker = true
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    } else {
                        ForEach(selectedTeams) { team in
                            TeamRowView(team: team)
                        }
                        .onDelete(perform: deleteTeams)
                    }
                } header: {
                    HStack {
                        Text("Your Teams")
                        Spacer()
                        if !selectedTeams.isEmpty {
                            Button("Add") {
                                showingTeamPicker = true
                            }
                            .font(.caption)
                        }
                    }
                }

                // Error Section
                if let error = lastRefreshError {
                    Section {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.yellow)
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("My Teams")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Task {
                            await refreshGames()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(isRefreshing || selectedTeams.isEmpty)
                }
            }
            .sheet(isPresented: $showingTeamPicker) {
                TeamPickerView(selectedTeams: $selectedTeams)
            }
            .onChange(of: selectedTeams) { _, newValue in
                AppGroup.selectedTeams = newValue
                WidgetCenter.shared.reloadAllTimelines()
                Task {
                    await refreshGames()
                }
            }
            .task {
                await refreshGames()
            }
            .refreshable {
                await refreshGames()
            }
            .onChange(of: selectedGameID) { _, newValue in
                if let gameID = newValue {
                    highlightedGameID = gameID
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            highlightedGameID = nil
                        }
                    }
                    selectedGameID = nil
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .refreshGames)) { _ in
                Task {
                    await refreshGames()
                }
            }
        }
    }

    private func deleteTeams(at offsets: IndexSet) {
        selectedTeams.remove(atOffsets: offsets)
    }

    private func refreshGames() async {
        guard !selectedTeams.isEmpty else {
            upcomingGames = []
            return
        }

        isRefreshing = true
        lastRefreshError = nil

        do {
            let games = try await ESPNAPIClient.shared.fetchGames(for: selectedTeams)
            await DataCache.shared.saveGames(games)
            upcomingGames = games
        } catch {
            lastRefreshError = error.localizedDescription
            upcomingGames = await DataCache.shared.loadGames()
        }

        isRefreshing = false
    }
}

// MARK: - Scoreboard View
struct ScoreboardView: View {
    @State private var selectedLeague: String = "nba"
    @State private var games: [Game] = []
    @State private var isLoading = false
    @State private var lastError: String?

    private let leagues = ["nba", "nfl", "mlb", "nhl", "eng.1", "eng.2", "usa.usl.1"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // League Picker
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(leagues, id: \.self) { league in
                            Button {
                                selectedLeague = league
                            } label: {
                                Text(leagueDisplayName(league))
                                    .font(.subheadline)
                                    .fontWeight(selectedLeague == league ? .semibold : .regular)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(selectedLeague == league ? Color.accentColor : Color.secondary.opacity(0.15))
                                    .foregroundStyle(selectedLeague == league ? .white : .primary)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                .background(Color(.systemBackground))

                // Games List
                List {
                    if isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                                .padding()
                            Spacer()
                        }
                    } else if games.isEmpty {
                        ContentUnavailableView {
                            Label("No Games Today", systemImage: "calendar.badge.minus")
                        } description: {
                            Text("There are no \(leagueDisplayName(selectedLeague)) games scheduled for today.")
                        }
                    } else {
                        ForEach(games) { game in
                            ScoreboardGameRow(game: game)
                        }
                    }

                    if let error = lastError {
                        Section {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.yellow)
                                Text(error)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Scores")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Task {
                            await fetchLeagueGames()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(isLoading)
                }
            }
            .onChange(of: selectedLeague) { _, _ in
                Task {
                    await fetchLeagueGames()
                }
            }
            .task {
                await fetchLeagueGames()
            }
            .refreshable {
                await fetchLeagueGames()
            }
        }
    }

    private func fetchLeagueGames() async {
        isLoading = true
        lastError = nil

        let sport = sportForLeague(selectedLeague)

        do {
            games = try await ESPNAPIClient.shared.fetchLeagueGames(sport: sport, league: selectedLeague)
        } catch {
            lastError = error.localizedDescription
            games = []
        }

        isLoading = false
    }

    private func sportForLeague(_ league: String) -> String {
        switch league.lowercased() {
        case "nba": return "basketball"
        case "nfl": return "football"
        case "mlb": return "baseball"
        case "nhl": return "hockey"
        case "eng.1", "eng.2", "usa.usl.1": return "soccer"
        default: return "basketball"
        }
    }

    private func leagueDisplayName(_ league: String) -> String {
        switch league.lowercased() {
        case "eng.1": return "EPL"
        case "eng.2": return "EFL"
        case "usa.usl.1": return "USL"
        default: return league.uppercased()
        }
    }
}

// MARK: - Scoreboard Game Row
struct ScoreboardGameRow: View {
    let game: Game

    var body: some View {
        VStack(spacing: 8) {
            // Teams and scores
            HStack {
                // Away team
                VStack(spacing: 4) {
                    ScoreboardTeamLogo(
                        abbreviation: game.awayTeamAbbreviation,
                        logoUrl: game.awayTeamLogoUrl,
                        league: game.league,
                        size: 44
                    )
                    Text(game.awayTeamAbbreviation)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .frame(width: 70)

                Spacer()

                // Score or vs
                if game.shouldShowScore {
                    HStack(spacing: 16) {
                        Text("\(game.awayScore ?? 0)")
                            .font(.title)
                            .fontWeight(.bold)
                            .monospacedDigit()

                        Text("-")
                            .font(.title2)
                            .foregroundStyle(.secondary)

                        Text("\(game.homeScore ?? 0)")
                            .font(.title)
                            .fontWeight(.bold)
                            .monospacedDigit()
                    }
                } else {
                    VStack(spacing: 2) {
                        Text(game.formattedTime)
                            .font(.headline)
                        Text(game.formattedDate)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                // Home team
                VStack(spacing: 4) {
                    ScoreboardTeamLogo(
                        abbreviation: game.homeTeamAbbreviation,
                        logoUrl: game.homeTeamLogoUrl,
                        league: game.league,
                        size: 44
                    )
                    Text(game.homeTeamAbbreviation)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .frame(width: 70)
            }

            // Status
            Text(game.statusDisplay)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(statusColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(statusColor.opacity(0.15))
                .clipShape(Capsule())

            // Venue
            if let venue = game.venue {
                Text(venue)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 8)
    }

    private var statusColor: Color {
        switch game.status {
        case .completed:
            return .secondary
        case .inProgress:
            return .green
        case .postponed, .canceled:
            return .orange
        case .scheduled:
            return .blue
        }
    }
}

// MARK: - Scoreboard Team Logo (loads from ESPN API logo URL or falls back to CDN)
struct ScoreboardTeamLogo: View {
    let abbreviation: String
    let logoUrl: String?  // Logo URL from ESPN API (preferred)
    let league: String
    var size: CGFloat = 40

    /// Primary logo URL - use the ESPN API URL if available, otherwise fall back to CDN pattern
    private var logoURL: URL? {
        // First, try the logo URL from the API (works for all sports including soccer)
        if let apiLogoUrl = logoUrl, let url = URL(string: apiLogoUrl) {
            return url
        }

        // Fallback: Construct URL from CDN pattern (works reliably for American leagues)
        let sport: String
        switch league.lowercased() {
        case "nba": sport = "nba"
        case "nfl": sport = "nfl"
        case "mlb": sport = "mlb"
        case "nhl": sport = "nhl"
        default: return nil  // Don't try CDN fallback for soccer (needs team IDs)
        }

        let urlString = "https://a.espncdn.com/i/teamlogos/\(sport)/500/\(abbreviation.lowercased()).png"
        return URL(string: urlString)
    }

    var body: some View {
        if let url = logoURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    placeholderView
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: size, height: size)
                case .failure:
                    placeholderView
                @unknown default:
                    placeholderView
                }
            }
        } else {
            placeholderView
        }
    }

    private var placeholderView: some View {
        Circle()
            .fill(leagueColor.opacity(0.2))
            .frame(width: size, height: size)
            .overlay {
                Text(abbreviation.prefix(3))
                    .font(.system(size: size * 0.3, weight: .bold))
                    .foregroundStyle(leagueColor)
            }
    }

    private var leagueColor: Color {
        switch league.lowercased() {
        case "nba": return .orange
        case "nfl": return .green
        case "mlb": return .red
        case "nhl": return .blue
        case "eng.1": return .purple
        case "eng.2": return .indigo
        case "usa.usl.1": return .teal
        default: return .gray
        }
    }
}

// MARK: - Game Row View (with User's Team Badge)
struct GameRowView: View {
    let game: Game
    let selectedTeams: [Team]
    var isHighlighted: Bool = false

    /// Find the user's team for this game
    private var userTeam: Team? {
        selectedTeams.first { team in
            team.abbreviation.lowercased() == game.userTeamAbbreviation.lowercased()
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            // User's team badge
            if let team = userTeam {
                TeamLogoView(team: team, size: 44)
            } else {
                // Fallback badge if team not found
                GameTeamBadge(
                    abbreviation: game.userTeamAbbreviation,
                    league: game.league,
                    size: 44
                )
            }

            VStack(alignment: .leading, spacing: 4) {
                // Teams
                Text(game.gameDescription)
                    .font(.headline)

                // Score or time
                if game.shouldShowScore {
                    HStack(spacing: 4) {
                        Text("\(game.awayScore ?? 0) - \(game.homeScore ?? 0)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .monospacedDigit()
                        Text("•")
                            .foregroundStyle(.tertiary)
                        Text(game.statusDisplay)
                            .font(.subheadline)
                            .foregroundStyle(statusColor)
                    }
                } else {
                    HStack(spacing: 4) {
                        Text(game.formattedDate)
                        Text("•")
                            .foregroundStyle(.tertiary)
                        Text(game.formattedTime)
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }

                // Venue
                if let venue = game.venue {
                    Text(venue)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isHighlighted ? Color.accentColor.opacity(0.15) : Color.clear)
                .animation(.easeInOut(duration: 0.3), value: isHighlighted)
        )
    }

    private var statusColor: Color {
        switch game.status {
        case .completed:
            return .secondary
        case .inProgress:
            return .green
        case .postponed, .canceled:
            return .orange
        case .scheduled:
            return .secondary
        }
    }
}

// MARK: - Game Team Badge
struct GameTeamBadge: View {
    let abbreviation: String
    let league: String
    var size: CGFloat = 40

    var body: some View {
        Circle()
            .fill(leagueColor.opacity(0.2))
            .frame(width: size, height: size)
            .overlay {
                Text(abbreviation.prefix(3))
                    .font(.system(size: size * 0.3, weight: .bold))
                    .foregroundStyle(leagueColor)
            }
    }

    private var leagueColor: Color {
        switch league.lowercased() {
        case "nba": return .orange
        case "nfl": return .green
        case "mlb": return .red
        case "nhl": return .blue
        case "eng.1": return .purple
        case "eng.2": return .indigo
        case "usa.usl.1": return .teal
        default: return .gray
        }
    }
}

// MARK: - Team Logo View
struct TeamLogoView: View {
    let team: Team
    let size: CGFloat

    init(team: Team, size: CGFloat = 40) {
        self.team = team
        self.size = size
    }

    var body: some View {
        if let logoURL = team.logoURL {
            AsyncImage(url: logoURL) { phase in
                switch phase {
                case .empty:
                    placeholderView
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: size, height: size)
                case .failure:
                    placeholderView
                @unknown default:
                    placeholderView
                }
            }
        } else {
            placeholderView
        }
    }

    private var placeholderView: some View {
        Circle()
            .fill(leagueColor.opacity(0.2))
            .frame(width: size, height: size)
            .overlay {
                Text(team.abbreviation.prefix(2))
                    .font(.system(size: size * 0.35, weight: .bold))
                    .foregroundStyle(leagueColor)
            }
    }

    private var leagueColor: Color {
        switch team.league.lowercased() {
        case "nba": return .orange
        case "nfl": return .green
        case "mlb": return .red
        case "nhl": return .blue
        case "eng.1": return .purple
        case "eng.2": return .indigo
        case "usa.usl.1": return .teal
        default: return .gray
        }
    }
}

// MARK: - Team Row View
struct TeamRowView: View {
    let team: Team

    var body: some View {
        HStack(spacing: 12) {
            TeamLogoView(team: team, size: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(team.name)
                    .font(.headline)
                HStack(spacing: 4) {
                    Text(team.abbreviation)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                    Text("•")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    Text(leagueDisplayName(team.league))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Image(systemName: leagueIcon(for: team.league))
                .foregroundStyle(.secondary)
                .font(.caption)
        }
        .padding(.vertical, 4)
    }

    private func leagueDisplayName(_ league: String) -> String {
        switch league.lowercased() {
        case "eng.1": return "EPL"
        case "eng.2": return "EFL"
        case "usa.usl.1": return "USL"
        default: return league.uppercased()
        }
    }

    private func leagueIcon(for league: String) -> String {
        switch league.lowercased() {
        case "nba": return "basketball.fill"
        case "nfl": return "football.fill"
        case "mlb": return "baseball.fill"
        case "nhl": return "hockey.puck.fill"
        case "eng.1", "eng.2", "usa.usl.1": return "soccerball"
        default: return "sportscourt.fill"
        }
    }
}

// MARK: - Team Picker View
struct TeamPickerView: View {
    @Binding var selectedTeams: [Team]
    @Environment(\.dismiss) private var dismiss
    @State private var selectedLeague: String = "nba"
    @State private var searchText: String = ""

    private let leagues = ["nba", "nfl", "mlb", "nhl", "eng.1", "eng.2", "usa.usl.1"]

    private func leagueDisplayName(_ league: String) -> String {
        switch league {
        case "eng.1": return "EPL"
        case "eng.2": return "EFL"
        case "usa.usl.1": return "USL"
        default: return league.uppercased()
        }
    }

    var filteredTeams: [Team] {
        let leagueTeams = Team.teams(for: selectedLeague)
        if searchText.isEmpty {
            return leagueTeams
        }
        return leagueTeams.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.abbreviation.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // League Picker
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(leagues, id: \.self) { league in
                            Button {
                                selectedLeague = league
                            } label: {
                                Text(leagueDisplayName(league))
                                    .font(.subheadline)
                                    .fontWeight(selectedLeague == league ? .semibold : .regular)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(selectedLeague == league ? Color.accentColor : Color.secondary.opacity(0.15))
                                    .foregroundStyle(selectedLeague == league ? .white : .primary)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)

                // Teams List
                List {
                    ForEach(filteredTeams) { team in
                        TeamSelectionRow(
                            team: team,
                            isSelected: isTeamSelected(team)
                        ) {
                            toggleTeamSelection(team)
                        }
                    }
                }
                .searchable(text: $searchText, prompt: "Search teams")
            }
            .navigationTitle("Select Teams")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func isTeamSelected(_ team: Team) -> Bool {
        selectedTeams.contains { $0.id == team.id && $0.league == team.league }
    }

    private func toggleTeamSelection(_ team: Team) {
        if isTeamSelected(team) {
            selectedTeams.removeAll { $0.id == team.id && $0.league == team.league }
        } else {
            selectedTeams.append(team)
        }
    }
}

// MARK: - Team Selection Row
struct TeamSelectionRow: View {
    let team: Team
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                TeamLogoView(team: team, size: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text(team.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(team.abbreviation)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.blue)
                        .font(.title2)
                } else {
                    Image(systemName: "circle")
                        .foregroundStyle(.secondary)
                        .font(.title2)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
}
