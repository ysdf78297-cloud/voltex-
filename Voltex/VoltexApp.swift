import SwiftUI

@main
struct VoltexApp: App {
    init() {
        Notifier.configure()
        Notifier.requestPermission()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}
