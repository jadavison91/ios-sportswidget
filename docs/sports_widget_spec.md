# iOS Sports Schedule Widget - Technical Specification

## Project Overview
Create an iOS home screen widget that displays upcoming game times and scores for user-selected sports teams. The widget updates every 15 minutes and shows both live/completed games and upcoming schedules.

## Core Requirements

### Functional Requirements
- Display upcoming games for user's favorite teams (3-5 teams)
- Show game date, time, opponent, and scores (for completed/in-progress games)
- Update every 15 minutes for timely score updates
- Support multiple sports (NBA, NFL, MLB, NHL, Premier League, Championship, USL, etc.)
- Handle timezone conversion to user's local time
- Show "No upcoming games" state when applicable
- Support both small and medium widget sizes
- Keep completed game scores visible for the remainder of the day
- Show league games when user's team isn't playing that day
- Smart prioritization when more games than widget can display (in-progress → scheduled → completed)

### Non-Functional Requirements
- Reasonable battery drain (15-minute refresh cycle)
- Works offline (shows last cached data)
- Fast widget load time (<1 second)
- Clean, readable design on both light and dark mode
- Handle API failures gracefully

## Data Source

### Recommended API: ESPN API (Unofficial)
- **Endpoint**: `http://site.api.espn.com/apis/site/v2/sports/{sport}/{league}/scoreboard`
- **Free**: Yes (no API key required)
- **Sports supported**: NFL, NBA, MLB, NHL, MLS, NCAAF, NCAAB, etc.
- **Rate limits**: None enforced, but be respectful
- **Example**: `http://site.api.espn.com/apis/site/v2/sports/basketball/nba/scoreboard`

### Alternative: TheSportsDB API
- **Endpoint**: `https://www.thesportsdb.com/api/v1/json/3/eventsnext.php?id={teamId}`
- **Free tier**: Yes (3 in some plans, 1 for others)
- **Requires**: Team IDs lookup

## Technical Stack

### iOS Technologies
- **Widget Framework**: WidgetKit (iOS 14+)
- **UI Framework**: SwiftUI
- **Data Persistence**: UserDefaults or App Group container
- **Networking**: URLSession with async/await
- **Background Refresh**: TimelineProvider with daily update policy

### Minimum iOS Version
- iOS 16.0+ (for modern SwiftUI features)

## Widget Specifications

### Widget Sizes
1. **Small Widget (2x2)**
   - Shows next 1-2 games
   - Team abbreviations
   - Game time or score
   - Compact scorebug format

2. **Medium Widget (4x2)**
   - Shows up to 4 games with compact scorebug design
   - Team abbreviations (no logos for space efficiency)
   - Game date/time or live/final scores
   - No home/away indicators (removed for compactness)
   - Smart prioritization: in-progress games first, then scheduled, then completed

### Widget Update Schedule
- Refresh: Every 15 minutes for timely score updates
- Timeline: Provide entries for 15-minute intervals
- Fallback: Show cached data if refresh fails
- Game day behavior: Keep completed scores visible until midnight local time

### Game Prioritization
- When more games exist than widget can display, show most relevant games
- Priority order: In-progress → Scheduled → Completed
- Within each status, sort by start time (earliest first)
- User's team games take priority over league fallback games

## Data Models

### Team Configuration
```swift
struct Team {
    let id: String          // ESPN team ID
    let name: String        // "Los Angeles Lakers"
    let abbreviation: String // "LAL"
    let sport: String       // "basketball"
    let league: String      // "nba"
    let logoUrl: String?    // Team logo URL
}
```

### Game Data
```swift
struct Game {
    let id: String
    let homeTeam: String
    let homeTeamAbbreviation: String
    let homeTeamLogoUrl: String?  // Logo URL from ESPN API
    let awayTeam: String
    let awayTeamAbbreviation: String
    let awayTeamLogoUrl: String?  // Logo URL from ESPN API
    let startTime: Date
    let isHomeGame: Bool    // Is user's team at home?
    let venue: String?
    let status: GameStatus  // scheduled, in_progress, completed, postponed, canceled
    let userTeamAbbreviation: String // The user's team in this game
    let league: String      // League identifier (e.g., "nba", "eng.1")
    let homeScore: Int?     // Score if game started
    let awayScore: Int?     // Score if game started
    let periodNumber: Int?  // Current period/quarter/inning number
    let periodHalf: String? // For baseball: "top" or "bottom"
    let clock: String?      // Game clock if in progress
}

enum GameStatus {
    case scheduled
    case inProgress
    case completed
    case postponed
    case canceled
}
```

### Widget Entry
```swift
struct ScheduleEntry: TimelineEntry {
    let date: Date
    let games: [Game]
    let lastUpdated: Date
}
```

## User Configuration

### Main App Features
- Team selection screen (multi-select from list)
- Sport/league filters
- Upcoming games list with team badges
- League scoreboard showing all games for selected leagues
- Manual refresh button
- Settings for:
  - Preferred widget size configuration
  - Number of games to display
  - Time format (12h/24h)

### Persistence
- Store selected teams in UserDefaults (App Group)
- Cache game data for offline viewing
- Store last successful API fetch timestamp
- Cache scoreboard data separately from widget data

## API Integration

### ESPN API Response Structure
```json
{
  "events": [
    {
      "id": "401584876",
      "name": "Lakers vs Warriors",
      "date": "2026-01-30T03:00Z",
      "competitions": [
        {
          "competitors": [
            {
              "homeAway": "home",
              "team": {
                "displayName": "Golden State Warriors",
                "abbreviation": "GSW"
              }
            },
            {
              "homeAway": "away",
              "team": {
                "displayName": "Los Angeles Lakers",
                "abbreviation": "LAL"
              }
            }
          ],
          "venue": {
            "fullName": "Chase Center"
          }
        }
      ]
    }
  ]
}
```

### Data Fetching Strategy
1. For each user's team, fetch next 7-14 days of schedule
2. Filter out games that have already started
3. Sort by game time (earliest first)
4. Take the next 3-5 games across all teams
5. Cache results locally

### Error Handling
- Network timeout: Use cached data
- Invalid response: Show "Unable to fetch schedule"
- No upcoming games: Show "No games scheduled"
- Partial failure: Show available data with warning

## Widget Appearance

### Design Elements
- **Background**: Semi-transparent with blur (system material)
- **Typography**: 
  - Title: SF Pro Rounded Bold, 14pt
  - Body: SF Pro, 12pt
  - Time: SF Pro Mono, 11pt
- **Colors**: 
  - Use team colors for accents
  - Adapt to light/dark mode
  - High contrast for readability
- **Spacing**: 8pt between elements, 12pt margins

### Layout (Medium Widget - Compact Scorebug)
```
┌─────────────────────────────────┐
│  🏀 Your Games      Updated 2:30│
├─────────────────────────────────┤
│  LAL  102 - 98   GSW    FINAL   │
│  BOS   87 - 91   MIA    Q3      │
│  PHX  vs  DEN           7:30P   │
│  NYK  vs  CHI         2/3 8:00P │
└─────────────────────────────────┘
```

### Game Day Display Logic
1. **User's team playing today**: Show their game (score if completed/in-progress, time if upcoming)
2. **User's team game completed**: Keep showing "FINAL" score until midnight, don't replace with upcoming games
3. **User's team not playing**: Show other games from their league(s)
4. **Multiple leagues**: Prioritize user's teams, then fill with league games

## Implementation Phases

### Phase 1: Core Functionality ✅ COMPLETE
- [x] Set up WidgetKit project structure
- [x] Implement ESPN API client
- [x] Create basic data models
- [x] Build TimelineProvider with daily refresh
- [x] Implement small widget layout

### Phase 2: Enhanced Features ✅ COMPLETE
- [x] Add medium widget layout
- [x] Implement team selection UI in companion app
- [x] Add team logo support
- [x] Implement proper error states
- [x] Add light/dark mode support

### Phase 3: Polish
- [ ] Add animations for widget updates
- [ ] Add widget configuration options (AppIntents-based)
- [ ] Performance optimization
- [ ] Testing on various iPhone models
- [ ] Customizable color schemes

### Phase 4: Live Scores & Enhanced Display ✅ COMPLETE
- [x] **4.1** Update refresh interval from daily to 15 minutes
- [x] **4.2** Game model updates: Add homeScore, awayScore, periodNumber, periodHalf, clock, league fields
- [x] **4.3** Sport-specific period formatting (Q1-Q4, 1st/2nd/3rd, ↑7/↓7, etc.)
- [x] **4.4** Compact scorebug redesign:
  - Fit up to 4 games on medium widget
  - Remove home/away icons from widget
  - Optimize layout for score display
  - Team abbreviations only (no logos in widget)
- [x] **4.5** Game day persistence: Keep scores/final visible all day for user's teams
  - Completed games remain visible until midnight local time
- [x] **4.6** League fallback display: When user's team isn't playing but other teams in their league are, show those league games/scores
- [x] **4.7** Enhanced status parsing: Support ESPN state/completed fields for reliable game status detection

**Note**: Auto-scroll via timeline entries was investigated but iOS widget refresh throttling makes sub-minute scrolling unreliable. Widget shows prioritized games (in-progress → scheduled → completed) instead.

### Phase 5: Companion App Enhancements ✅ COMPLETE
- [x] **5.1** League Scoreboard in Companion App
  - Added new "Scores" tab showing all games for selected leagues
  - Display live scores, final scores, and upcoming games
  - Pull-to-refresh functionality
  - League picker with horizontal scroll (NBA, NFL, MLB, NHL, EPL, EFL, USL)
  - Team logos loaded from ESPN API response
- [x] **5.2** Team Badges in Upcoming Games
  - User's favorite team badge shown next to each upcoming game
  - Reuses TeamLogoView component for consistent styling
  - Game time, venue, and status information preserved
- [x] **5.3** Companion App Navigation
  - TabView with "My Teams" and "Scores" tabs
  - "My Teams" tab: Upcoming games section + team list
  - "Scores" tab: League scoreboard with team logos
- [x] **5.4** Scoreboard Data Integration
  - ESPNAPIClient fetches all league games via `fetchLeagueGames()`
  - Logo URLs parsed from ESPN API response (fixes soccer team logos)
  - Game model includes `homeTeamLogoUrl` and `awayTeamLogoUrl` fields

## Testing Requirements

### Test Scenarios
1. Widget displays correctly with 0, 1, 3, 5+ upcoming games
2. Timezone conversion works correctly
3. Widget updates every 15 minutes
4. Handles API failures gracefully
5. Works in airplane mode (shows cached data)
6. Proper display in light and dark mode
7. Team selection persists across app restarts
8. Multiple widget instances on home screen
9. Completed game scores persist until midnight
10. League fallback displays when user's team not playing
11. Game prioritization shows in-progress games first
12. Companion app scoreboard displays all league games
13. Team badges display correctly in upcoming games list

### Edge Cases
- No internet connection
- Team has no upcoming games for 2+ weeks
- User selects teams from different sports
- User is in different timezone than team's location
- API returns unexpected data format
- Widget space constraints with long team names
- Game spans midnight (start time vs completion time)
- Multiple user teams playing simultaneously
- More games than widget can display (prioritization kicks in)
- Scoreboard with 0 games in a league
- Team logo fails to load (fallback to abbreviation badge)

## Performance Targets
- API response time: < 2 seconds
- Widget render time: < 500ms
- Memory usage: < 50MB
- Background refresh time: < 5 seconds

## Future Enhancements (Optional)
- Tap widget to open game details or streaming link
- Toggle for light/dark mode preference
- Show playoff indicators
- Display TV network/streaming info
- Customizable team color accents

## File Structure
```
SportsWidget/
├── SportsWidgetExtension/           # Widget extension
│   ├── SportsWidgetExtension.swift  # Widget entry point & TimelineProvider
│   ├── Views/
│   │   ├── SmallWidgetView.swift
│   │   └── MediumWidgetView.swift
│   ├── Models/
│   │   ├── Team.swift
│   │   ├── Game.swift
│   │   └── ScheduleEntry.swift
│   ├── Services/
│   │   ├── ESPNAPIClient.swift
│   │   └── DataCache.swift
│   └── Shared/
│       └── AppGroup.swift
├── SportsWidget/                    # Companion app
│   ├── SportsWidgetApp.swift
│   ├── ContentView.swift            # Main TabView container
│   ├── Views/
│   │   ├── MyTeamsView.swift        # Team list & upcoming games
│   │   ├── ScoreboardView.swift     # League scoreboard
│   │   ├── TeamPickerView.swift     # Team selection sheet
│   │   └── Components/
│   │       ├── TeamLogoView.swift
│   │       ├── GameRowView.swift    # Game row with team badges
│   │       └── ScoreboardGameRow.swift
│   ├── Models/
│   │   ├── Team.swift
│   │   ├── Game.swift
│   │   └── ScheduleEntry.swift
│   ├── Services/
│   │   ├── ESPNAPIClient.swift
│   │   └── DataCache.swift
│   └── Shared/
│       └── AppGroup.swift
└── docs/
    └── sports_widget_spec.md
```

## Notes for Claude Code
- Use modern Swift concurrency (async/await)
- Follow Apple's Human Interface Guidelines for widgets
- Implement proper error handling at every API boundary
- Use SwiftUI for all UI components
- Consider accessibility (VoiceOver support)
- Add comments for complex logic
- Use meaningful variable names
- Follow Swift naming conventions
