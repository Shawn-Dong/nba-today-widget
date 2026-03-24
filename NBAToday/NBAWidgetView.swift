import SwiftUI
import WidgetKit

// MARK: - Root View (dispatches by widget size)

struct NBAWidgetView: View {
    let entry: NBAEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemMedium:
            MediumView(entry: entry)
        default:
            LargeView(entry: entry)
        }
    }
}

// MARK: - Medium (compact rows, up to 3 games)

struct MediumView: View {
    let entry: NBAEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            WidgetHeader()
            Divider().overlay(Color.white.opacity(0.1))

            if entry.hasError {
                Spacer()
                Text("Unable to load games").font(.caption).foregroundStyle(.secondary)
                Spacer()
            } else if entry.games.isEmpty {
                Spacer()
                Text("No games today").font(.caption).foregroundStyle(.secondary)
                Spacer()
            } else {
                ForEach(entry.games.prefix(3)) { CompactRow(game: $0) }
                if entry.games.count > 3 {
                    Text("+\(entry.games.count - 3) more")
                        .font(.caption2).foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
            }
        }
        .padding(14)
    }
}

// MARK: - Large (full detail, all games)

struct LargeView: View {
    let entry: NBAEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            WidgetHeader()
            Divider().overlay(Color.white.opacity(0.1))

            if entry.hasError {
                Spacer()
                Text("Unable to load games").font(.callout).foregroundStyle(.secondary)
                Spacer()
            } else if entry.games.isEmpty {
                Spacer()
                Text("No games today").font(.callout).foregroundStyle(.secondary)
                Spacer()
            } else {
                ForEach(Array(entry.games.enumerated()), id: \.element.id) { i, game in
                    DetailRow(game: game)
                    if i < entry.games.count - 1 {
                        Divider().overlay(Color.white.opacity(0.07))
                    }
                }
                Spacer(minLength: 0)
            }
        }
        .padding(16)
    }
}

// MARK: - Header

struct WidgetHeader: View {
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("NBA Today")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white)
            Spacer()
            Text(Date.now, format: .dateTime.month(.abbreviated).day())
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Compact row (medium widget)

struct CompactRow: View {
    let game: NBAGame

    var body: some View {
        HStack(spacing: 0) {
            // Away
            Text(game.awayAbbr)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundStyle(.white)
                .frame(width: 32, alignment: .leading)
            if !game.awayScore.isEmpty {
                Text(game.awayScore)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
                    .frame(width: 22, alignment: .trailing)
            }
            Text(" @ ")
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
            // Home
            if !game.homeScore.isEmpty {
                Text(game.homeScore)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
                    .frame(width: 22, alignment: .leading)
            }
            Text(game.homeAbbr)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundStyle(.white)
                .frame(width: 32)
            Spacer()
            StatusBadge(game: game, small: true)
        }
    }
}

// MARK: - Detail row (large widget)

struct DetailRow: View {
    let game: NBAGame

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                TeamLine(abbr: game.awayAbbr, name: game.awayName, score: game.awayScore)
                TeamLine(abbr: game.homeAbbr, name: game.homeName, score: game.homeScore)
            }
            Spacer()
            StatusBadge(game: game, small: false)
        }
    }
}

struct TeamLine: View {
    let abbr: String
    let name: String
    let score: String

    var body: some View {
        HStack(spacing: 6) {
            Text(abbr)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundStyle(.white)
                .frame(width: 34, alignment: .leading)
            Text(name)
                .font(.system(size: 11))
                .foregroundStyle(Color.white.opacity(0.55))
            Spacer()
            if !score.isEmpty {
                Text(score)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
            }
        }
    }
}

// MARK: - Status Badge

struct StatusBadge: View {
    let game: NBAGame
    let small: Bool

    var color: Color {
        if game.isLive  { return Color(red: 1.0, green: 0.27, blue: 0.33) }
        if game.isFinal { return .secondary }
        return Color(red: 1.0, green: 0.64, blue: 0.0)
    }

    var body: some View {
        Text(game.statusText)
            .font(.system(size: small ? 9 : 10, weight: .semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.15), in: Capsule())
    }
}

// MARK: - Preview

#Preview(as: .systemLarge) {
    NBAWidget()
} timeline: {
    NBAEntry(date: .now, games: NBAGame.placeholders, hasError: false)
}
