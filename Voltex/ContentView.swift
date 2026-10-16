import SwiftUI
import UIKit

struct ContentView: View {
    @AppStorage("showFakeMoneyTab") private var showFakeMoney = false
    @AppStorage("devShockwaves") private var shockwaves = true
    @AppStorage("devTouchPoints") private var touchPoints = false
    @AppStorage("devKeepAwake") private var keepAwake = false
    @State private var selection = "ipas"

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
                    .tag("ipas")

                MyIPAView()
                    .tabItem { Label("Your IPA", systemImage: "shippingbox.fill") }
                    .tag("youripa")

                CertificateView()
                    .tabItem { Label("Certificate", systemImage: "checkmark.seal.fill") }
                    .tag("certificate")

                if showFakeMoney {
                    FakeMoneyView()
                        .tabItem { Label("Fake Money", systemImage: "cart.fill") }
                        .tag("fake")
                }

                SettingsView()
                    .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                    .tag("settings")

                AboutView()
                    .tabItem { Label("About", systemImage: "info.circle.fill") }
                    .tag("about")
            }
            .tint(VoltexTheme.orange)

            ShockwaveOverlay()
            TouchDotOverlay()
            FPSMeterOverlay()
            AndroidToastHost()
        }
        .onChange(of: showFakeMoney) { newValue in
            if !newValue && selection == "fake" { selection = "ipas" }
        }
        .onAppear { UIApplication.shared.isIdleTimerDisabled = keepAwake }
        .onChange(of: keepAwake) { newValue in
            UIApplication.shared.isIdleTimerDisabled = newValue
        }
        .background(
            WindowTapCatcher { point in
                if shockwaves { ShockwaveCenter.shared.spawn(at: point) }
                if touchPoints { TouchDotCenter.shared.add(at: point) }
            }
        )
    }
}

#Preview {
    ContentView().preferredColorScheme(.dark)
}
