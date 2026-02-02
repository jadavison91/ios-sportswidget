//
//  Team.swift
//  SportsWidget
//
//  Created by Jason Davison on 1/29/26.
//

import Foundation

struct Team: Codable, Identifiable, Hashable {
    let id: String          // ESPN team ID
    let name: String        // "Los Angeles Lakers"
    let abbreviation: String // "LAL"
    let sport: String       // "basketball"
    let league: String      // "nba"
    let logoUrl: String?    // Team logo URL

    var displayName: String {
        "\(abbreviation) - \(name)"
    }

    var logoURL: URL? {
        guard let logoUrl = logoUrl else { return nil }
        return URL(string: logoUrl)
    }
}

// MARK: - All Teams by League
extension Team {

    // MARK: - NBA Teams (30 teams)
    static let nbaTeams: [Team] = [
        Team(id: "1", name: "Atlanta Hawks", abbreviation: "ATL", sport: "basketball", league: "nba", logoUrl: "https://a.espncdn.com/i/teamlogos/nba/500/atl.png"),
        Team(id: "2", name: "Boston Celtics", abbreviation: "BOS", sport: "basketball", league: "nba", logoUrl: "https://a.espncdn.com/i/teamlogos/nba/500/bos.png"),
        Team(id: "17", name: "Brooklyn Nets", abbreviation: "BKN", sport: "basketball", league: "nba", logoUrl: "https://a.espncdn.com/i/teamlogos/nba/500/bkn.png"),
        Team(id: "30", name: "Charlotte Hornets", abbreviation: "CHA", sport: "basketball", league: "nba", logoUrl: "https://a.espncdn.com/i/teamlogos/nba/500/cha.png"),
        Team(id: "4", name: "Chicago Bulls", abbreviation: "CHI", sport: "basketball", league: "nba", logoUrl: "https://a.espncdn.com/i/teamlogos/nba/500/chi.png"),
        Team(id: "5", name: "Cleveland Cavaliers", abbreviation: "CLE", sport: "basketball", league: "nba", logoUrl: "https://a.espncdn.com/i/teamlogos/nba/500/cle.png"),
        Team(id: "6", name: "Dallas Mavericks", abbreviation: "DAL", sport: "basketball", league: "nba", logoUrl: "https://a.espncdn.com/i/teamlogos/nba/500/dal.png"),
        Team(id: "7", name: "Denver Nuggets", abbreviation: "DEN", sport: "basketball", league: "nba", logoUrl: "https://a.espncdn.com/i/teamlogos/nba/500/den.png"),
        Team(id: "8", name: "Detroit Pistons", abbreviation: "DET", sport: "basketball", league: "nba", logoUrl: "https://a.espncdn.com/i/teamlogos/nba/500/det.png"),
        Team(id: "9", name: "Golden State Warriors", abbreviation: "GS", sport: "basketball", league: "nba", logoUrl: "https://a.espncdn.com/i/teamlogos/nba/500/gs.png"),
        Team(id: "10", name: "Houston Rockets", abbreviation: "HOU", sport: "basketball", league: "nba", logoUrl: "https://a.espncdn.com/i/teamlogos/nba/500/hou.png"),
        Team(id: "11", name: "Indiana Pacers", abbreviation: "IND", sport: "basketball", league: "nba", logoUrl: "https://a.espncdn.com/i/teamlogos/nba/500/ind.png"),
        Team(id: "12", name: "LA Clippers", abbreviation: "LAC", sport: "basketball", league: "nba", logoUrl: "https://a.espncdn.com/i/teamlogos/nba/500/lac.png"),
        Team(id: "13", name: "Los Angeles Lakers", abbreviation: "LAL", sport: "basketball", league: "nba", logoUrl: "https://a.espncdn.com/i/teamlogos/nba/500/lal.png"),
        Team(id: "29", name: "Memphis Grizzlies", abbreviation: "MEM", sport: "basketball", league: "nba", logoUrl: "https://a.espncdn.com/i/teamlogos/nba/500/mem.png"),
        Team(id: "14", name: "Miami Heat", abbreviation: "MIA", sport: "basketball", league: "nba", logoUrl: "https://a.espncdn.com/i/teamlogos/nba/500/mia.png"),
        Team(id: "15", name: "Milwaukee Bucks", abbreviation: "MIL", sport: "basketball", league: "nba", logoUrl: "https://a.espncdn.com/i/teamlogos/nba/500/mil.png"),
        Team(id: "16", name: "Minnesota Timberwolves", abbreviation: "MIN", sport: "basketball", league: "nba", logoUrl: "https://a.espncdn.com/i/teamlogos/nba/500/min.png"),
        Team(id: "3", name: "New Orleans Pelicans", abbreviation: "NO", sport: "basketball", league: "nba", logoUrl: "https://a.espncdn.com/i/teamlogos/nba/500/no.png"),
        Team(id: "18", name: "New York Knicks", abbreviation: "NY", sport: "basketball", league: "nba", logoUrl: "https://a.espncdn.com/i/teamlogos/nba/500/ny.png"),
        Team(id: "25", name: "Oklahoma City Thunder", abbreviation: "OKC", sport: "basketball", league: "nba", logoUrl: "https://a.espncdn.com/i/teamlogos/nba/500/okc.png"),
        Team(id: "19", name: "Orlando Magic", abbreviation: "ORL", sport: "basketball", league: "nba", logoUrl: "https://a.espncdn.com/i/teamlogos/nba/500/orl.png"),
        Team(id: "20", name: "Philadelphia 76ers", abbreviation: "PHI", sport: "basketball", league: "nba", logoUrl: "https://a.espncdn.com/i/teamlogos/nba/500/phi.png"),
        Team(id: "21", name: "Phoenix Suns", abbreviation: "PHX", sport: "basketball", league: "nba", logoUrl: "https://a.espncdn.com/i/teamlogos/nba/500/phx.png"),
        Team(id: "22", name: "Portland Trail Blazers", abbreviation: "POR", sport: "basketball", league: "nba", logoUrl: "https://a.espncdn.com/i/teamlogos/nba/500/por.png"),
        Team(id: "23", name: "Sacramento Kings", abbreviation: "SAC", sport: "basketball", league: "nba", logoUrl: "https://a.espncdn.com/i/teamlogos/nba/500/sac.png"),
        Team(id: "24", name: "San Antonio Spurs", abbreviation: "SA", sport: "basketball", league: "nba", logoUrl: "https://a.espncdn.com/i/teamlogos/nba/500/sa.png"),
        Team(id: "28", name: "Toronto Raptors", abbreviation: "TOR", sport: "basketball", league: "nba", logoUrl: "https://a.espncdn.com/i/teamlogos/nba/500/tor.png"),
        Team(id: "26", name: "Utah Jazz", abbreviation: "UTAH", sport: "basketball", league: "nba", logoUrl: "https://a.espncdn.com/i/teamlogos/nba/500/utah.png"),
        Team(id: "27", name: "Washington Wizards", abbreviation: "WSH", sport: "basketball", league: "nba", logoUrl: "https://a.espncdn.com/i/teamlogos/nba/500/wsh.png"),
    ]

    // MARK: - NFL Teams (32 teams)
    static let nflTeams: [Team] = [
        Team(id: "22", name: "Arizona Cardinals", abbreviation: "ARI", sport: "football", league: "nfl", logoUrl: "https://a.espncdn.com/i/teamlogos/nfl/500/ari.png"),
        Team(id: "1", name: "Atlanta Falcons", abbreviation: "ATL", sport: "football", league: "nfl", logoUrl: "https://a.espncdn.com/i/teamlogos/nfl/500/atl.png"),
        Team(id: "33", name: "Baltimore Ravens", abbreviation: "BAL", sport: "football", league: "nfl", logoUrl: "https://a.espncdn.com/i/teamlogos/nfl/500/bal.png"),
        Team(id: "2", name: "Buffalo Bills", abbreviation: "BUF", sport: "football", league: "nfl", logoUrl: "https://a.espncdn.com/i/teamlogos/nfl/500/buf.png"),
        Team(id: "29", name: "Carolina Panthers", abbreviation: "CAR", sport: "football", league: "nfl", logoUrl: "https://a.espncdn.com/i/teamlogos/nfl/500/car.png"),
        Team(id: "3", name: "Chicago Bears", abbreviation: "CHI", sport: "football", league: "nfl", logoUrl: "https://a.espncdn.com/i/teamlogos/nfl/500/chi.png"),
        Team(id: "4", name: "Cincinnati Bengals", abbreviation: "CIN", sport: "football", league: "nfl", logoUrl: "https://a.espncdn.com/i/teamlogos/nfl/500/cin.png"),
        Team(id: "5", name: "Cleveland Browns", abbreviation: "CLE", sport: "football", league: "nfl", logoUrl: "https://a.espncdn.com/i/teamlogos/nfl/500/cle.png"),
        Team(id: "6", name: "Dallas Cowboys", abbreviation: "DAL", sport: "football", league: "nfl", logoUrl: "https://a.espncdn.com/i/teamlogos/nfl/500/dal.png"),
        Team(id: "7", name: "Denver Broncos", abbreviation: "DEN", sport: "football", league: "nfl", logoUrl: "https://a.espncdn.com/i/teamlogos/nfl/500/den.png"),
        Team(id: "8", name: "Detroit Lions", abbreviation: "DET", sport: "football", league: "nfl", logoUrl: "https://a.espncdn.com/i/teamlogos/nfl/500/det.png"),
        Team(id: "9", name: "Green Bay Packers", abbreviation: "GB", sport: "football", league: "nfl", logoUrl: "https://a.espncdn.com/i/teamlogos/nfl/500/gb.png"),
        Team(id: "34", name: "Houston Texans", abbreviation: "HOU", sport: "football", league: "nfl", logoUrl: "https://a.espncdn.com/i/teamlogos/nfl/500/hou.png"),
        Team(id: "11", name: "Indianapolis Colts", abbreviation: "IND", sport: "football", league: "nfl", logoUrl: "https://a.espncdn.com/i/teamlogos/nfl/500/ind.png"),
        Team(id: "30", name: "Jacksonville Jaguars", abbreviation: "JAX", sport: "football", league: "nfl", logoUrl: "https://a.espncdn.com/i/teamlogos/nfl/500/jax.png"),
        Team(id: "12", name: "Kansas City Chiefs", abbreviation: "KC", sport: "football", league: "nfl", logoUrl: "https://a.espncdn.com/i/teamlogos/nfl/500/kc.png"),
        Team(id: "13", name: "Las Vegas Raiders", abbreviation: "LV", sport: "football", league: "nfl", logoUrl: "https://a.espncdn.com/i/teamlogos/nfl/500/lv.png"),
        Team(id: "24", name: "Los Angeles Chargers", abbreviation: "LAC", sport: "football", league: "nfl", logoUrl: "https://a.espncdn.com/i/teamlogos/nfl/500/lac.png"),
        Team(id: "14", name: "Los Angeles Rams", abbreviation: "LAR", sport: "football", league: "nfl", logoUrl: "https://a.espncdn.com/i/teamlogos/nfl/500/lar.png"),
        Team(id: "15", name: "Miami Dolphins", abbreviation: "MIA", sport: "football", league: "nfl", logoUrl: "https://a.espncdn.com/i/teamlogos/nfl/500/mia.png"),
        Team(id: "16", name: "Minnesota Vikings", abbreviation: "MIN", sport: "football", league: "nfl", logoUrl: "https://a.espncdn.com/i/teamlogos/nfl/500/min.png"),
        Team(id: "17", name: "New England Patriots", abbreviation: "NE", sport: "football", league: "nfl", logoUrl: "https://a.espncdn.com/i/teamlogos/nfl/500/ne.png"),
        Team(id: "18", name: "New Orleans Saints", abbreviation: "NO", sport: "football", league: "nfl", logoUrl: "https://a.espncdn.com/i/teamlogos/nfl/500/no.png"),
        Team(id: "19", name: "New York Giants", abbreviation: "NYG", sport: "football", league: "nfl", logoUrl: "https://a.espncdn.com/i/teamlogos/nfl/500/nyg.png"),
        Team(id: "20", name: "New York Jets", abbreviation: "NYJ", sport: "football", league: "nfl", logoUrl: "https://a.espncdn.com/i/teamlogos/nfl/500/nyj.png"),
        Team(id: "21", name: "Philadelphia Eagles", abbreviation: "PHI", sport: "football", league: "nfl", logoUrl: "https://a.espncdn.com/i/teamlogos/nfl/500/phi.png"),
        Team(id: "23", name: "Pittsburgh Steelers", abbreviation: "PIT", sport: "football", league: "nfl", logoUrl: "https://a.espncdn.com/i/teamlogos/nfl/500/pit.png"),
        Team(id: "25", name: "San Francisco 49ers", abbreviation: "SF", sport: "football", league: "nfl", logoUrl: "https://a.espncdn.com/i/teamlogos/nfl/500/sf.png"),
        Team(id: "26", name: "Seattle Seahawks", abbreviation: "SEA", sport: "football", league: "nfl", logoUrl: "https://a.espncdn.com/i/teamlogos/nfl/500/sea.png"),
        Team(id: "27", name: "Tampa Bay Buccaneers", abbreviation: "TB", sport: "football", league: "nfl", logoUrl: "https://a.espncdn.com/i/teamlogos/nfl/500/tb.png"),
        Team(id: "10", name: "Tennessee Titans", abbreviation: "TEN", sport: "football", league: "nfl", logoUrl: "https://a.espncdn.com/i/teamlogos/nfl/500/ten.png"),
        Team(id: "28", name: "Washington Commanders", abbreviation: "WSH", sport: "football", league: "nfl", logoUrl: "https://a.espncdn.com/i/teamlogos/nfl/500/wsh.png"),
    ]

    // MARK: - MLB Teams (30 teams)
    static let mlbTeams: [Team] = [
        Team(id: "15", name: "Arizona Diamondbacks", abbreviation: "ARI", sport: "baseball", league: "mlb", logoUrl: "https://a.espncdn.com/i/teamlogos/mlb/500/ari.png"),
        Team(id: "1", name: "Atlanta Braves", abbreviation: "ATL", sport: "baseball", league: "mlb", logoUrl: "https://a.espncdn.com/i/teamlogos/mlb/500/atl.png"),
        Team(id: "2", name: "Baltimore Orioles", abbreviation: "BAL", sport: "baseball", league: "mlb", logoUrl: "https://a.espncdn.com/i/teamlogos/mlb/500/bal.png"),
        Team(id: "3", name: "Boston Red Sox", abbreviation: "BOS", sport: "baseball", league: "mlb", logoUrl: "https://a.espncdn.com/i/teamlogos/mlb/500/bos.png"),
        Team(id: "16", name: "Chicago Cubs", abbreviation: "CHC", sport: "baseball", league: "mlb", logoUrl: "https://a.espncdn.com/i/teamlogos/mlb/500/chc.png"),
        Team(id: "4", name: "Chicago White Sox", abbreviation: "CWS", sport: "baseball", league: "mlb", logoUrl: "https://a.espncdn.com/i/teamlogos/mlb/500/chw.png"),
        Team(id: "17", name: "Cincinnati Reds", abbreviation: "CIN", sport: "baseball", league: "mlb", logoUrl: "https://a.espncdn.com/i/teamlogos/mlb/500/cin.png"),
        Team(id: "5", name: "Cleveland Guardians", abbreviation: "CLE", sport: "baseball", league: "mlb", logoUrl: "https://a.espncdn.com/i/teamlogos/mlb/500/cle.png"),
        Team(id: "27", name: "Colorado Rockies", abbreviation: "COL", sport: "baseball", league: "mlb", logoUrl: "https://a.espncdn.com/i/teamlogos/mlb/500/col.png"),
        Team(id: "6", name: "Detroit Tigers", abbreviation: "DET", sport: "baseball", league: "mlb", logoUrl: "https://a.espncdn.com/i/teamlogos/mlb/500/det.png"),
        Team(id: "18", name: "Houston Astros", abbreviation: "HOU", sport: "baseball", league: "mlb", logoUrl: "https://a.espncdn.com/i/teamlogos/mlb/500/hou.png"),
        Team(id: "7", name: "Kansas City Royals", abbreviation: "KC", sport: "baseball", league: "mlb", logoUrl: "https://a.espncdn.com/i/teamlogos/mlb/500/kc.png"),
        Team(id: "3", name: "Los Angeles Angels", abbreviation: "LAA", sport: "baseball", league: "mlb", logoUrl: "https://a.espncdn.com/i/teamlogos/mlb/500/laa.png"),
        Team(id: "19", name: "Los Angeles Dodgers", abbreviation: "LAD", sport: "baseball", league: "mlb", logoUrl: "https://a.espncdn.com/i/teamlogos/mlb/500/lad.png"),
        Team(id: "28", name: "Miami Marlins", abbreviation: "MIA", sport: "baseball", league: "mlb", logoUrl: "https://a.espncdn.com/i/teamlogos/mlb/500/mia.png"),
        Team(id: "8", name: "Milwaukee Brewers", abbreviation: "MIL", sport: "baseball", league: "mlb", logoUrl: "https://a.espncdn.com/i/teamlogos/mlb/500/mil.png"),
        Team(id: "9", name: "Minnesota Twins", abbreviation: "MIN", sport: "baseball", league: "mlb", logoUrl: "https://a.espncdn.com/i/teamlogos/mlb/500/min.png"),
        Team(id: "21", name: "New York Mets", abbreviation: "NYM", sport: "baseball", league: "mlb", logoUrl: "https://a.espncdn.com/i/teamlogos/mlb/500/nym.png"),
        Team(id: "10", name: "New York Yankees", abbreviation: "NYY", sport: "baseball", league: "mlb", logoUrl: "https://a.espncdn.com/i/teamlogos/mlb/500/nyy.png"),
        Team(id: "11", name: "Oakland Athletics", abbreviation: "OAK", sport: "baseball", league: "mlb", logoUrl: "https://a.espncdn.com/i/teamlogos/mlb/500/oak.png"),
        Team(id: "22", name: "Philadelphia Phillies", abbreviation: "PHI", sport: "baseball", league: "mlb", logoUrl: "https://a.espncdn.com/i/teamlogos/mlb/500/phi.png"),
        Team(id: "23", name: "Pittsburgh Pirates", abbreviation: "PIT", sport: "baseball", league: "mlb", logoUrl: "https://a.espncdn.com/i/teamlogos/mlb/500/pit.png"),
        Team(id: "25", name: "San Diego Padres", abbreviation: "SD", sport: "baseball", league: "mlb", logoUrl: "https://a.espncdn.com/i/teamlogos/mlb/500/sd.png"),
        Team(id: "26", name: "San Francisco Giants", abbreviation: "SF", sport: "baseball", league: "mlb", logoUrl: "https://a.espncdn.com/i/teamlogos/mlb/500/sf.png"),
        Team(id: "12", name: "Seattle Mariners", abbreviation: "SEA", sport: "baseball", league: "mlb", logoUrl: "https://a.espncdn.com/i/teamlogos/mlb/500/sea.png"),
        Team(id: "24", name: "St. Louis Cardinals", abbreviation: "STL", sport: "baseball", league: "mlb", logoUrl: "https://a.espncdn.com/i/teamlogos/mlb/500/stl.png"),
        Team(id: "30", name: "Tampa Bay Rays", abbreviation: "TB", sport: "baseball", league: "mlb", logoUrl: "https://a.espncdn.com/i/teamlogos/mlb/500/tb.png"),
        Team(id: "13", name: "Texas Rangers", abbreviation: "TEX", sport: "baseball", league: "mlb", logoUrl: "https://a.espncdn.com/i/teamlogos/mlb/500/tex.png"),
        Team(id: "14", name: "Toronto Blue Jays", abbreviation: "TOR", sport: "baseball", league: "mlb", logoUrl: "https://a.espncdn.com/i/teamlogos/mlb/500/tor.png"),
        Team(id: "20", name: "Washington Nationals", abbreviation: "WSH", sport: "baseball", league: "mlb", logoUrl: "https://a.espncdn.com/i/teamlogos/mlb/500/wsh.png"),
    ]

    // MARK: - NHL Teams (32 teams)
    static let nhlTeams: [Team] = [
        Team(id: "25", name: "Anaheim Ducks", abbreviation: "ANA", sport: "hockey", league: "nhl", logoUrl: "https://a.espncdn.com/i/teamlogos/nhl/500/ana.png"),
        Team(id: "1", name: "Boston Bruins", abbreviation: "BOS", sport: "hockey", league: "nhl", logoUrl: "https://a.espncdn.com/i/teamlogos/nhl/500/bos.png"),
        Team(id: "2", name: "Buffalo Sabres", abbreviation: "BUF", sport: "hockey", league: "nhl", logoUrl: "https://a.espncdn.com/i/teamlogos/nhl/500/buf.png"),
        Team(id: "20", name: "Calgary Flames", abbreviation: "CGY", sport: "hockey", league: "nhl", logoUrl: "https://a.espncdn.com/i/teamlogos/nhl/500/cgy.png"),
        Team(id: "7", name: "Carolina Hurricanes", abbreviation: "CAR", sport: "hockey", league: "nhl", logoUrl: "https://a.espncdn.com/i/teamlogos/nhl/500/car.png"),
        Team(id: "16", name: "Chicago Blackhawks", abbreviation: "CHI", sport: "hockey", league: "nhl", logoUrl: "https://a.espncdn.com/i/teamlogos/nhl/500/chi.png"),
        Team(id: "29", name: "Colorado Avalanche", abbreviation: "COL", sport: "hockey", league: "nhl", logoUrl: "https://a.espncdn.com/i/teamlogos/nhl/500/col.png"),
        Team(id: "29", name: "Columbus Blue Jackets", abbreviation: "CBJ", sport: "hockey", league: "nhl", logoUrl: "https://a.espncdn.com/i/teamlogos/nhl/500/cbj.png"),
        Team(id: "25", name: "Dallas Stars", abbreviation: "DAL", sport: "hockey", league: "nhl", logoUrl: "https://a.espncdn.com/i/teamlogos/nhl/500/dal.png"),
        Team(id: "17", name: "Detroit Red Wings", abbreviation: "DET", sport: "hockey", league: "nhl", logoUrl: "https://a.espncdn.com/i/teamlogos/nhl/500/det.png"),
        Team(id: "22", name: "Edmonton Oilers", abbreviation: "EDM", sport: "hockey", league: "nhl", logoUrl: "https://a.espncdn.com/i/teamlogos/nhl/500/edm.png"),
        Team(id: "13", name: "Florida Panthers", abbreviation: "FLA", sport: "hockey", league: "nhl", logoUrl: "https://a.espncdn.com/i/teamlogos/nhl/500/fla.png"),
        Team(id: "26", name: "Los Angeles Kings", abbreviation: "LA", sport: "hockey", league: "nhl", logoUrl: "https://a.espncdn.com/i/teamlogos/nhl/500/la.png"),
        Team(id: "30", name: "Minnesota Wild", abbreviation: "MIN", sport: "hockey", league: "nhl", logoUrl: "https://a.espncdn.com/i/teamlogos/nhl/500/min.png"),
        Team(id: "8", name: "Montreal Canadiens", abbreviation: "MTL", sport: "hockey", league: "nhl", logoUrl: "https://a.espncdn.com/i/teamlogos/nhl/500/mtl.png"),
        Team(id: "18", name: "Nashville Predators", abbreviation: "NSH", sport: "hockey", league: "nhl", logoUrl: "https://a.espncdn.com/i/teamlogos/nhl/500/nsh.png"),
        Team(id: "1", name: "New Jersey Devils", abbreviation: "NJ", sport: "hockey", league: "nhl", logoUrl: "https://a.espncdn.com/i/teamlogos/nhl/500/nj.png"),
        Team(id: "2", name: "New York Islanders", abbreviation: "NYI", sport: "hockey", league: "nhl", logoUrl: "https://a.espncdn.com/i/teamlogos/nhl/500/nyi.png"),
        Team(id: "3", name: "New York Rangers", abbreviation: "NYR", sport: "hockey", league: "nhl", logoUrl: "https://a.espncdn.com/i/teamlogos/nhl/500/nyr.png"),
        Team(id: "9", name: "Ottawa Senators", abbreviation: "OTT", sport: "hockey", league: "nhl", logoUrl: "https://a.espncdn.com/i/teamlogos/nhl/500/ott.png"),
        Team(id: "4", name: "Philadelphia Flyers", abbreviation: "PHI", sport: "hockey", league: "nhl", logoUrl: "https://a.espncdn.com/i/teamlogos/nhl/500/phi.png"),
        Team(id: "5", name: "Pittsburgh Penguins", abbreviation: "PIT", sport: "hockey", league: "nhl", logoUrl: "https://a.espncdn.com/i/teamlogos/nhl/500/pit.png"),
        Team(id: "28", name: "San Jose Sharks", abbreviation: "SJ", sport: "hockey", league: "nhl", logoUrl: "https://a.espncdn.com/i/teamlogos/nhl/500/sj.png"),
        Team(id: "55", name: "Seattle Kraken", abbreviation: "SEA", sport: "hockey", league: "nhl", logoUrl: "https://a.espncdn.com/i/teamlogos/nhl/500/sea.png"),
        Team(id: "19", name: "St. Louis Blues", abbreviation: "STL", sport: "hockey", league: "nhl", logoUrl: "https://a.espncdn.com/i/teamlogos/nhl/500/stl.png"),
        Team(id: "14", name: "Tampa Bay Lightning", abbreviation: "TB", sport: "hockey", league: "nhl", logoUrl: "https://a.espncdn.com/i/teamlogos/nhl/500/tb.png"),
        Team(id: "10", name: "Toronto Maple Leafs", abbreviation: "TOR", sport: "hockey", league: "nhl", logoUrl: "https://a.espncdn.com/i/teamlogos/nhl/500/tor.png"),
        Team(id: "129764", name: "Utah Hockey Club", abbreviation: "UTAH", sport: "hockey", league: "nhl", logoUrl: "https://a.espncdn.com/i/teamlogos/nhl/500/utah.png"),
        Team(id: "23", name: "Vancouver Canucks", abbreviation: "VAN", sport: "hockey", league: "nhl", logoUrl: "https://a.espncdn.com/i/teamlogos/nhl/500/van.png"),
        Team(id: "54", name: "Vegas Golden Knights", abbreviation: "VGK", sport: "hockey", league: "nhl", logoUrl: "https://a.espncdn.com/i/teamlogos/nhl/500/vgk.png"),
        Team(id: "15", name: "Washington Capitals", abbreviation: "WSH", sport: "hockey", league: "nhl", logoUrl: "https://a.espncdn.com/i/teamlogos/nhl/500/wsh.png"),
        Team(id: "52", name: "Winnipeg Jets", abbreviation: "WPG", sport: "hockey", league: "nhl", logoUrl: "https://a.espncdn.com/i/teamlogos/nhl/500/wpg.png"),
    ]

    // MARK: - English Premier League Teams (20 teams) - 2025-26 Season
    static let eplTeams: [Team] = [
        Team(id: "349", name: "AFC Bournemouth", abbreviation: "BOU", sport: "soccer", league: "eng.1", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/349.png"),
        Team(id: "359", name: "Arsenal", abbreviation: "ARS", sport: "soccer", league: "eng.1", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/359.png"),
        Team(id: "362", name: "Aston Villa", abbreviation: "AVL", sport: "soccer", league: "eng.1", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/362.png"),
        Team(id: "337", name: "Brentford", abbreviation: "BRE", sport: "soccer", league: "eng.1", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/337.png"),
        Team(id: "331", name: "Brighton & Hove Albion", abbreviation: "BHA", sport: "soccer", league: "eng.1", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/331.png"),
        Team(id: "379", name: "Burnley", abbreviation: "BUR", sport: "soccer", league: "eng.1", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/379.png"),
        Team(id: "363", name: "Chelsea", abbreviation: "CHE", sport: "soccer", league: "eng.1", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/363.png"),
        Team(id: "384", name: "Crystal Palace", abbreviation: "CRY", sport: "soccer", league: "eng.1", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/384.png"),
        Team(id: "368", name: "Everton", abbreviation: "EVE", sport: "soccer", league: "eng.1", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/368.png"),
        Team(id: "370", name: "Fulham", abbreviation: "FUL", sport: "soccer", league: "eng.1", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/370.png"),
        Team(id: "357", name: "Leeds United", abbreviation: "LEE", sport: "soccer", league: "eng.1", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/357.png"),
        Team(id: "364", name: "Liverpool", abbreviation: "LIV", sport: "soccer", league: "eng.1", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/364.png"),
        Team(id: "382", name: "Manchester City", abbreviation: "MNC", sport: "soccer", league: "eng.1", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/382.png"),
        Team(id: "360", name: "Manchester United", abbreviation: "MAN", sport: "soccer", league: "eng.1", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/360.png"),
        Team(id: "361", name: "Newcastle United", abbreviation: "NEW", sport: "soccer", league: "eng.1", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/361.png"),
        Team(id: "393", name: "Nottingham Forest", abbreviation: "NFO", sport: "soccer", league: "eng.1", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/393.png"),
        Team(id: "366", name: "Sunderland", abbreviation: "SUN", sport: "soccer", league: "eng.1", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/366.png"),
        Team(id: "367", name: "Tottenham Hotspur", abbreviation: "TOT", sport: "soccer", league: "eng.1", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/367.png"),
        Team(id: "371", name: "West Ham United", abbreviation: "WHU", sport: "soccer", league: "eng.1", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/371.png"),
        Team(id: "380", name: "Wolverhampton Wanderers", abbreviation: "WOL", sport: "soccer", league: "eng.1", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/380.png"),
    ]

    // MARK: - English Championship Teams (24 teams) - 2025-26 Season
    static let echTeams: [Team] = [
        Team(id: "392", name: "Birmingham City", abbreviation: "BIR", sport: "soccer", league: "eng.2", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/392.png"),
        Team(id: "365", name: "Blackburn Rovers", abbreviation: "BLK", sport: "soccer", league: "eng.2", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/365.png"),
        Team(id: "333", name: "Bristol City", abbreviation: "BRC", sport: "soccer", league: "eng.2", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/333.png"),
        Team(id: "372", name: "Charlton Athletic", abbreviation: "CHA", sport: "soccer", league: "eng.2", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/372.png"),
        Team(id: "388", name: "Coventry City", abbreviation: "COV", sport: "soccer", league: "eng.2", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/388.png"),
        Team(id: "374", name: "Derby County", abbreviation: "DER", sport: "soccer", league: "eng.2", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/374.png"),
        Team(id: "306", name: "Hull City", abbreviation: "HUL", sport: "soccer", league: "eng.2", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/306.png"),
        Team(id: "373", name: "Ipswich Town", abbreviation: "IPS", sport: "soccer", league: "eng.2", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/373.png"),
        Team(id: "375", name: "Leicester City", abbreviation: "LEI", sport: "soccer", league: "eng.2", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/375.png"),
        Team(id: "369", name: "Middlesbrough", abbreviation: "MID", sport: "soccer", league: "eng.2", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/369.png"),
        Team(id: "391", name: "Millwall", abbreviation: "MIL", sport: "soccer", league: "eng.2", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/391.png"),
        Team(id: "381", name: "Norwich City", abbreviation: "NOR", sport: "soccer", league: "eng.2", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/381.png"),
        Team(id: "311", name: "Oxford United", abbreviation: "OXF", sport: "soccer", league: "eng.2", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/311.png"),
        Team(id: "385", name: "Portsmouth", abbreviation: "POR", sport: "soccer", league: "eng.2", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/385.png"),
        Team(id: "394", name: "Preston North End", abbreviation: "PNE", sport: "soccer", league: "eng.2", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/394.png"),
        Team(id: "334", name: "Queens Park Rangers", abbreviation: "QPR", sport: "soccer", league: "eng.2", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/334.png"),
        Team(id: "398", name: "Sheffield United", abbreviation: "SHU", sport: "soccer", league: "eng.2", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/398.png"),
        Team(id: "399", name: "Sheffield Wednesday", abbreviation: "SHW", sport: "soccer", league: "eng.2", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/399.png"),
        Team(id: "376", name: "Southampton", abbreviation: "SOU", sport: "soccer", league: "eng.2", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/376.png"),
        Team(id: "336", name: "Stoke City", abbreviation: "STK", sport: "soccer", league: "eng.2", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/336.png"),
        Team(id: "318", name: "Swansea City", abbreviation: "SWA", sport: "soccer", league: "eng.2", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/318.png"),
        Team(id: "395", name: "Watford", abbreviation: "WAT", sport: "soccer", league: "eng.2", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/395.png"),
        Team(id: "383", name: "West Bromwich Albion", abbreviation: "WBA", sport: "soccer", league: "eng.2", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/383.png"),
        Team(id: "352", name: "Wrexham", abbreviation: "WXM", sport: "soccer", league: "eng.2", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/352.png"),
    ]

    // MARK: - USL Championship Teams (24 teams)
    // MARK: - USL Championship Teams (correct league: usa.usl.1)
    static let uslTeams: [Team] = [
        Team(id: "19405", name: "Birmingham Legion FC", abbreviation: "BRM", sport: "soccer", league: "usa.usl.1", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/19405.png"),
        Team(id: "131579", name: "Brooklyn FC", abbreviation: "BFKC", sport: "soccer", league: "usa.usl.1", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/131579.png"),
        Team(id: "9729", name: "Charleston Battery", abbreviation: "CHS", sport: "soccer", league: "usa.usl.1", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/9729.png"),
        Team(id: "17830", name: "Colorado Springs Switchbacks FC", abbreviation: "COS", sport: "soccer", league: "usa.usl.1", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/17830.png"),
        Team(id: "19179", name: "Detroit City FC", abbreviation: "DET", sport: "soccer", league: "usa.usl.1", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/19179.png"),
        Team(id: "19407", name: "El Paso Locomotive FC", abbreviation: "ELP", sport: "soccer", league: "usa.usl.1", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/19407.png"),
        Team(id: "18446", name: "FC Tulsa", abbreviation: "TUL", sport: "soccer", league: "usa.usl.1", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/18446.png"),
        Team(id: "19411", name: "Hartford Athletic", abbreviation: "HFD", sport: "soccer", league: "usa.usl.1", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/19411.png"),
        Team(id: "17360", name: "Indy Eleven", abbreviation: "INDY", sport: "soccer", league: "usa.usl.1", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/17360.png"),
        Team(id: "18987", name: "Las Vegas Lights FC", abbreviation: "LVL", sport: "soccer", league: "usa.usl.1", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/18987.png"),
        Team(id: "21822", name: "Lexington SC", abbreviation: "LEX", sport: "soccer", league: "usa.usl.1", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/21822.png"),
        Team(id: "19410", name: "Loudoun United FC", abbreviation: "LDN", sport: "soccer", league: "usa.usl.1", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/19410.png"),
        Team(id: "17832", name: "Louisville City FC", abbreviation: "LOU", sport: "soccer", league: "usa.usl.1", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/17832.png"),
        Team(id: "18159", name: "Miami FC", abbreviation: "MIA", sport: "soccer", league: "usa.usl.1", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/18159.png"),
        Team(id: "21370", name: "Monterey Bay FC", abbreviation: "MTB", sport: "soccer", league: "usa.usl.1", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/21370.png"),
        Team(id: "19408", name: "New Mexico United", abbreviation: "NMU", sport: "soccer", league: "usa.usl.1", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/19408.png"),
        Team(id: "20687", name: "Oakland Roots SC", abbreviation: "OAK", sport: "soccer", league: "usa.usl.1", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/20687.png"),
        Team(id: "18455", name: "Orange County SC", abbreviation: "OCSC", sport: "soccer", league: "usa.usl.1", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/18455.png"),
        Team(id: "17850", name: "Phoenix Rising FC", abbreviation: "PHX", sport: "soccer", league: "usa.usl.1", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/17850.png"),
        Team(id: "17827", name: "Pittsburgh Riverhounds SC", abbreviation: "PIT", sport: "soccer", league: "usa.usl.1", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/17827.png"),
        Team(id: "22164", name: "Rhode Island FC", abbreviation: "RHI", sport: "soccer", league: "usa.usl.1", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/22164.png"),
        Team(id: "17828", name: "Sacramento Republic FC", abbreviation: "SAC", sport: "soccer", league: "usa.usl.1", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/17828.png"),
        Team(id: "18265", name: "San Antonio FC", abbreviation: "SAFC", sport: "soccer", league: "usa.usl.1", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/18265.png"),
        Team(id: "131578", name: "Sporting Jacksonville", abbreviation: "JAX", sport: "soccer", league: "usa.usl.1", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/131578.png"),
        Team(id: "17361", name: "Tampa Bay Rowdies", abbreviation: "TBR", sport: "soccer", league: "usa.usl.1", logoUrl: "https://a.espncdn.com/i/teamlogos/soccer/500/17361.png"),
    ]

    // MARK: - All Teams Combined
    static let allTeams: [Team] = nbaTeams + nflTeams + mlbTeams + nhlTeams + eplTeams + echTeams + uslTeams

    static func teams(for league: String) -> [Team] {
        switch league.lowercased() {
        case "nba": return nbaTeams
        case "nfl": return nflTeams
        case "mlb": return mlbTeams
        case "nhl": return nhlTeams
        case "eng.1", "epl": return eplTeams
        case "eng.2", "ech": return echTeams
        case "usa.usl.1", "usl": return uslTeams
        default: return []
        }
    }
}
