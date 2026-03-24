import Foundation

struct NBAGame: Identifiable {
    let id: String
    let awayAbbr: String
    let homeAbbr: String
    let awayName: String
    let homeName: String
    let awayScore: String
    let homeScore: String
    let statusText: String
    let isLive: Bool
    let isFinal: Bool

    static var placeholders: [NBAGame] {
        [
            NBAGame(id: "1", awayAbbr: "LAL", homeAbbr: "GSW",
                    awayName: "Lakers", homeName: "Warriors",
                    awayScore: "98", homeScore: "102",
                    statusText: "Q3 4:22", isLive: true, isFinal: false),
            NBAGame(id: "2", awayAbbr: "BOS", homeAbbr: "MIA",
                    awayName: "Celtics", homeName: "Heat",
                    awayScore: "110", homeScore: "104",
                    statusText: "Final", isLive: false, isFinal: true),
            NBAGame(id: "3", awayAbbr: "NYK", homeAbbr: "CHI",
                    awayName: "Knicks", homeName: "Bulls",
                    awayScore: "", homeScore: "",
                    statusText: "7:30 PM", isLive: false, isFinal: false),
        ]
    }
}
