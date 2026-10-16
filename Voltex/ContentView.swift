import SwiftUI
import UIKit

struct ContentView: View {
    @State private var selection = 0

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(VoltexTheme.black)
        appearance.shadowColor = UIColor(VoltexTheme.orange).withAlphaComponent(0.25)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        ZStack {
            TabView(selection: $selection) {
                IPAsView()
                    .tabItem { Label("IPA's", systemImage: "square.stack.3d.up.fill") }
                    .tag(0)

                SettingsView()
                    .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                    .tag(1)

                AboutView()
                    .tabItem { Label("About", systemImage: "info.circle.fill") }
                    .tag(2)
            }
            .tint(VoltexTheme.orange)

            ShockwaveOverlay()
            AndroidToastHost()
        }
        .background(
            WindowTapCatcher { point in
                ShockwaveCenter.shared.spawn(at: point)
            }
        )
    }
}

#Preview {
    ContentView().preferredColorScheme(.dark)
}
