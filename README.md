# NBA Today Widget

A native macOS desktop widget that shows today's NBA games — live scores, schedules, and final results — built with WidgetKit and SwiftUI.

## Features

- Live scores with quarter and clock (e.g. `Q3 4:22`)
- Tip-off times in your local timezone for upcoming games
- Final scores for completed games
- Auto-refreshes every 30 seconds during live games, every 5 minutes otherwise
- Supports Medium and Large widget sizes
- No API key required

## Tech Stack

| Layer | Technology |
|---|---|
| UI | SwiftUI |
| Widget framework | WidgetKit |
| Data | [ESPN Scoreboard API](https://site.api.espn.com/apis/site/v2/sports/basketball/nba/scoreboard) (unofficial, free, no auth) |
| Language | Swift 5.0 |
| Platform | macOS 14+ (Sonoma) |

## Project Structure

```
NBAWidget/               # Main app target
  NBAWidgetApp.swift     # App entry point
  ContentView.swift      # Simple launcher UI

NBAToday/                # Widget Extension target (NBATodayExtension)
  NBAWidget.swift        # Widget definition + TimelineProvider
  NBAWidgetView.swift    # SwiftUI views (Medium + Large layouts)
  NBAModels.swift        # Data model (NBAGame)
  NBAService.swift       # ESPN API fetching + JSON parsing
  NBAToday.entitlements  # Network sandbox entitlement
  Info.plist             # WidgetKit extension point
```

## How It Works

WidgetKit uses a **timeline** model — instead of running continuously, the widget extension is woken up by the system at scheduled intervals, fetches data, renders a snapshot, and exits. Memory usage between refreshes is zero.

```
System wakes extension
  → getTimeline() called
  → NBAService fetches ESPN API
  → NBAEntry created with game data
  → Widget renders snapshot
  → Extension process exits
  → System schedules next wake (30s if live, 5min otherwise)
```

## Setup

1. Clone the repo and open `NBAWidget.xcodeproj` in Xcode
2. Select the `NBAWidget` scheme and press Run (⌘R)
3. Right-click your desktop → Edit Widgets → search **NBA Today**

To install permanently without Xcode: **Product → Archive → Distribute App → Custom → Copy App**, then move `NBAWidget.app` to `/Applications/`.
