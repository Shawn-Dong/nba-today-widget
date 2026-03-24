import SwiftUI
import WidgetKit

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("🏀 NBA Widget")
                .font(.title).bold()
            Text("Right-click your desktop → Edit Widgets to add it.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Reload Widget") {
                WidgetCenter.shared.reloadAllTimelines()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(40)
        .frame(width: 360, height: 180)
    }
}
