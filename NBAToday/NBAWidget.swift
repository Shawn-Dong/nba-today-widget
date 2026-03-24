import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct NBAEntry: TimelineEntry {
    let date: Date
    let games: [NBAGame]
    let hasError: Bool
}

// MARK: - Timeline Provider

struct NBATimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> NBAEntry {
        NBAEntry(date: .now, games: NBAGame.placeholders, hasError: false)
    }

    func getSnapshot(in context: Context, completion: @escaping (NBAEntry) -> Void) {
        Task {
            let games = (try? await NBAService.fetchGames()) ?? NBAGame.placeholders
            completion(NBAEntry(date: .now, games: games, hasError: false))
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NBAEntry>) -> Void) {
        Task {
            do {
                let games = try await NBAService.fetchGames()
                let entry = NBAEntry(date: .now, games: games, hasError: false)
                // Refresh every 30s if a game is live, otherwise every 5 minutes
                let interval: TimeInterval = games.contains { $0.isLive } ? 30 : 300
                completion(Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(interval))))
            } catch {
                let entry = NBAEntry(date: .now, games: [], hasError: true)
                completion(Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(300))))
            }
        }
    }
}

// MARK: - Widget Definition

struct NBAWidget: Widget {
    let kind = "NBAWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NBATimelineProvider()) { entry in
            NBAWidgetView(entry: entry)
                .containerBackground(Color(red: 0.07, green: 0.07, blue: 0.12), for: .widget)
        }
        .configurationDisplayName("NBA Today")
        .description("Live scores and today's NBA schedule.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

// MARK: - Bundle Entry Point

@main
struct NBAWidgetBundle: WidgetBundle {
    var body: some Widget {
        NBAWidget()
    }
}
