import Foundation

struct NBAService {
    static func fetchGames() async throws -> [NBAGame] {
        let url = URL(string: "https://site.api.espn.com/apis/site/v2/sports/basketball/nba/scoreboard")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try parseGames(from: data)
    }

    private static func parseGames(from data: Data) throws -> [NBAGame] {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let events = json["events"] as? [[String: Any]] else { return [] }
        return events.compactMap(parseGame)
    }

    private static func parseGame(_ event: [String: Any]) -> NBAGame? {
        guard let id = event["id"] as? String,
              let competition = (event["competitions"] as? [[String: Any]])?.first,
              let competitors = competition["competitors"] as? [[String: Any]],
              let statusObj = event["status"] as? [String: Any],
              let statusType = statusObj["type"] as? [String: Any],
              let statusName = statusType["name"] as? String,
              let dateStr = event["date"] as? String
        else { return nil }

        let home = competitors.first { $0["homeAway"] as? String == "home" }
        let away = competitors.first { $0["homeAway"] as? String == "away" }

        func abbr(_ c: [String: Any]?) -> String {
            (c?["team"] as? [String: Any])?["abbreviation"] as? String ?? "???"
        }
        func name(_ c: [String: Any]?) -> String {
            (c?["team"] as? [String: Any])?["shortDisplayName"] as? String ?? "Unknown"
        }

        let period = statusObj["period"] as? Int ?? 0
        let clock = statusObj["displayClock"] as? String ?? ""

        let isLive: Bool
        let isFinal: Bool
        let statusText: String

        switch statusName {
        case "STATUS_FINAL", "STATUS_FULL_TIME":
            isLive = false; isFinal = true; statusText = "Final"
        case "STATUS_IN_PROGRESS":
            isLive = true; isFinal = false; statusText = "Q\(period) \(clock)"
        case "STATUS_HALFTIME":
            isLive = true; isFinal = false; statusText = "Halftime"
        default:
            isLive = false; isFinal = false
            let df = DateFormatter()
            df.locale = Locale(identifier: "en_US_POSIX")
            df.timeZone = TimeZone(identifier: "UTC")
            df.dateFormat = "yyyy-MM-dd'T'HH:mmZ"
            let date = df.date(from: dateStr)
            if let date {
                let display = DateFormatter()
                display.dateFormat = "h:mm a"
                display.timeZone = .current
                statusText = display.string(from: date)
            } else {
                statusText = "TBD"
            }
        }

        return NBAGame(
            id: id,
            awayAbbr: abbr(away), homeAbbr: abbr(home),
            awayName: name(away), homeName: name(home),
            awayScore: away?["score"] as? String ?? "",
            homeScore: home?["score"] as? String ?? "",
            statusText: statusText, isLive: isLive, isFinal: isFinal
        )
    }
}
