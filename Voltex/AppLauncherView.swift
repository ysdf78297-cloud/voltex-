import SwiftUI
import UIKit
import ObjectiveC

struct HiddenApp: Identifiable {
    let id: String
    let name: String
    let note: String
    let icon: String
    let candidates: [String]
    let scheme: String?

    init(id: String, name: String, note: String, icon: String,
         candidates: [String] = [], scheme: String? = nil) {
        self.id = id
        self.name = name
        self.note = note
        self.icon = icon
        self.candidates = candidates
        self.scheme = scheme
    }
}

/// Lists the hidden / internal apps that you can't normally find or launch.
struct AppLauncherView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var search = ""
    @State private var message: String?
    @State private var discovered: [(name: String, bundleID: String)] = []
    @AppStorage("alShowAll") private var showAll = false

    /// Apps that only exist from a certain iOS version onwards.
    private let minIOSById: [String: Int] = [
        "safetymonitor": 15,
        "posterboard": 16, "prideposter": 16, "unityposter": 16,
        "climate": 17, "vehicle": 17, "tirepressure": 17,
        "activity": 17, "eyerelief": 17, "closures": 17,
        "writingtools": 18
    ]

    private var iosMajor: Int {
        ProcessInfo.processInfo.operatingSystemVersion.majorVersion
    }

    /// Everything that can exist on the iOS version this device is running.
    private var compatibleApps: [HiddenApp] {
        internalApps.filter { (minIOSById[$0.id] ?? 0) <= iosMajor }
    }

    /// Of those, the ones actually installed here — the ones that will really open.
    private var workingApps: [HiddenApp] {
        guard !discovered.isEmpty else { return compatibleApps }
        let installedIDs = Set(discovered.map { $0.bundleID.lowercased() })
        return compatibleApps.filter { app in
            app.candidates.contains { installedIDs.contains($0.lowercased()) }
        }
    }

    private var hiddenCount: Int {
        max(0, internalApps.count - workingApps.count)
    }

    /// Internal apps that ship inside iOS but have no icon anywhere on the Home Screen.
    private let internalApps: [HiddenApp] = [
        HiddenApp(id: "springboard", name: "SpringBoard", note: "The Home Screen itself", icon: "square.grid.2x2.fill", candidates: ["com.apple.springboard"]),
        HiddenApp(id: "spotlight", name: "Spotlight", note: "System search", icon: "magnifyingglass", candidates: ["com.apple.Spotlight"]),
        HiddenApp(id: "axremote", name: "AX Remote View Service", note: "Internal accessibility service", icon: "rectangle.on.rectangle", candidates: ["com.apple.AXRemoteViewService"]),
        HiddenApp(id: "axui", name: "AccessibilityUIServer", note: "Accessibility overlay server", icon: "figure.wave", candidates: ["com.apple.accessibility.AccessibilityUIServer"]),
        HiddenApp(id: "diagnostics", name: "Diagnostics", note: "Apple Store Genius diagnostics", icon: "waveform.path.ecg", candidates: ["com.apple.Diagnostics"], scheme: "diagnostics://"),
        HiddenApp(id: "iodiagnostics", name: "iOS Diagnostics", note: "Genius Bar diagnostics", icon: "wrench.and.screwdriver.fill", candidates: ["com.apple.iOSDiagnostics"], scheme: "diags://"),
        HiddenApp(id: "checkerboard", name: "CheckerBoard", note: "Self Service Repair mode", icon: "square.grid.3x3.fill", candidates: ["com.apple.CheckerBoard"]),
        HiddenApp(id: "preboard", name: "PreBoard", note: "Developer Mode authorisation", icon: "lock.shield.fill", candidates: ["com.apple.PreBoard"]),
        HiddenApp(id: "setup", name: "Setup", note: "Setup Assistant (PurpleBuddy)", icon: "gearshape.2.fill", candidates: ["com.apple.purplebuddy", "com.apple.Setup"]),
        HiddenApp(id: "feedback", name: "Feedback", note: "Feedback Assistant", icon: "bubble.left.fill", candidates: ["com.apple.appleseed.FeedbackAssistant", "com.apple.Feedback"], scheme: "feedback://"),
        HiddenApp(id: "fieldtest", name: "Field Test", note: "Cellular engineering menu", icon: "antenna.radiowaves.left.and.right", candidates: ["com.apple.FieldTest", "com.apple.FTMInternal"]),
        HiddenApp(id: "posterboard", name: "PosterBoard", note: "Lock Screen wallpapers engine", icon: "photo.on.rectangle.angled", candidates: ["com.apple.PosterBoard"]),
        HiddenApp(id: "previewshell", name: "PreviewShell", note: "Internal preview host", icon: "square.stack.3d.up.fill", candidates: ["com.apple.PreviewShell"]),
        HiddenApp(id: "websheet", name: "WebSheet", note: "In-app auth web sheet", icon: "safari.fill", candidates: ["com.apple.WebSheet"]),
        HiddenApp(id: "trustme", name: "TrustMe", note: "Certificate trust dialog", icon: "checkmark.shield.fill", candidates: ["com.apple.TrustMe"]),
        HiddenApp(id: "loginui", name: "LoginUI", note: "System login UI", icon: "person.crop.circle.fill", candidates: ["com.apple.LoginUI"]),
        HiddenApp(id: "coreauthui", name: "CoreAuthUI", note: "Biometric auth UI", icon: "faceid", candidates: ["com.apple.CoreAuthUI"]),
        HiddenApp(id: "demoapp", name: "DemoApp", note: "Retail demo app", icon: "play.rectangle.fill", candidates: ["com.apple.DemoApp"]),
        HiddenApp(id: "family", name: "Family", note: "Screen Time internals", icon: "person.3.fill", candidates: ["com.apple.Family"]),
        HiddenApp(id: "sidecar", name: "Sidecar", note: "Use iPad as a second display", icon: "ipad.and.iphone", candidates: ["com.apple.Sidecar"]),
        HiddenApp(id: "printcenter", name: "Print Center", note: "AirPrint queue", icon: "printer.fill", candidates: ["com.apple.printcenter", "com.apple.PrintCenter"]),
        HiddenApp(id: "sharingview", name: "SharingViewService", note: "AirDrop / share sheet", icon: "square.and.arrow.up", candidates: ["com.apple.SharingViewService"]),
        HiddenApp(id: "acctauthdialog", name: "Account Authentication Dialog", note: "iCloud sign-in dialog", icon: "person.badge.key.fill", candidates: ["com.apple.AccountAuthenticationDialog"]),
        HiddenApp(id: "accessorysetup", name: "AccessorySetupUI", note: "Accessory pairing", icon: "airpodspro", candidates: ["com.apple.AccessorySetupUI", "com.apple.AccessorySetupKitUI"]),
        HiddenApp(id: "adsheet", name: "AdSheet", note: "Internal ad sheet", icon: "rectangle.badge.plus", candidates: ["com.apple.AdSheet"]),
        HiddenApp(id: "airplay", name: "AirPlay", note: "AirPlay receiver UI", icon: "airplayvideo", candidates: ["com.apple.AirPlay"]),
        HiddenApp(id: "batteries", name: "Batteries", note: "Battery widget internals", icon: "battery.100", candidates: ["com.apple.Batteries"]),
        HiddenApp(id: "carplaysplash", name: "CarPlaySplashScreen", note: "CarPlay splash", icon: "car.fill", candidates: ["com.apple.CarPlaySplashScreen"]),
        HiddenApp(id: "climate", name: "Climate", note: "In-car climate controls", icon: "thermometer.medium", candidates: ["com.apple.Climate"]),
        HiddenApp(id: "clipview", name: "ClipViewService", note: "Clipboard view service", icon: "doc.on.clipboard.fill", candidates: ["com.apple.ClipViewService"]),
        HiddenApp(id: "clockangel", name: "ClockAngel", note: "Lock Screen clock", icon: "clock.fill", candidates: ["com.apple.ClockAngel"]),
        HiddenApp(id: "closures", name: "Closures", note: "Internal closures UI", icon: "circle.dashed", candidates: ["com.apple.Closures"]),
        HiddenApp(id: "colorpicker", name: "ColorPickerUIService", note: "System colour picker", icon: "paintpalette.fill", candidates: ["com.apple.ColorPickerUIService"]),
        HiddenApp(id: "eyerelief", name: "EyeReliefUI", note: "Screen distance alerts", icon: "eye.fill", candidates: ["com.apple.EyeReliefUI"]),
        HiddenApp(id: "musicrecognition", name: "MusicRecognition", note: "Song recognition internals", icon: "music.note", candidates: ["com.apple.MusicRecognition"]),
        HiddenApp(id: "pasview", name: "PASViewService", note: "Password AutoFill view", icon: "key.horizontal.fill", candidates: ["com.apple.PASViewService"]),
        HiddenApp(id: "prideposter", name: "PridePosterApp", note: "Pride wallpapers", icon: "rainbow", candidates: ["com.apple.PridePosterApp"]),
        HiddenApp(id: "safetymonitor", name: "SafetyMonitorApp", note: "Crash / safety monitor", icon: "exclamationmark.shield.fill", candidates: ["com.apple.SafetyMonitorApp"]),
        HiddenApp(id: "screenshotservices", name: "ScreenshotServicesService", note: "Screenshot markup engine", icon: "camera.viewfinder", candidates: ["com.apple.ScreenshotServicesService"]),
        HiddenApp(id: "tvconference", name: "TVConferenceRoomDisplay", note: "Apple TV conference mode", icon: "tv.fill", candidates: ["com.apple.TVConferenceRoomDisplay"]),
        HiddenApp(id: "tvscreensaver", name: "TVScreenSaver", note: "Apple TV screen saver", icon: "tv.inset.filled", candidates: ["com.apple.TVScreenSaver"]),
        HiddenApp(id: "tvsettings", name: "TVSettings", note: "Apple TV settings", icon: "tv.badge.wifi", candidates: ["com.apple.TVSettings"]),
        HiddenApp(id: "tirepressure", name: "TirePressure", note: "Vehicle tyre pressure", icon: "car.circle.fill", candidates: ["com.apple.TirePressure"]),
        HiddenApp(id: "unityposter", name: "UnityPosterApp", note: "Unity wallpapers", icon: "circle.hexagongrid.fill", candidates: ["com.apple.UnityPosterApp"]),
        HiddenApp(id: "vehicle", name: "Vehicle", note: "Car integration", icon: "car.2.fill", candidates: ["com.apple.Vehicle"]),
        HiddenApp(id: "writingtools", name: "WritingToolsUIService", note: "Apple Intelligence UI", icon: "text.append", candidates: ["com.apple.WritingToolsUIService"]),
        HiddenApp(id: "activity", name: "Activity", note: "Internal activity UI", icon: "bolt.circle.fill", candidates: ["com.apple.Activity"]),
        HiddenApp(id: "watchbridge", name: "Watch Bridge", note: "Apple Watch pairing", icon: "applewatch", candidates: ["com.apple.Bridge"])
    ]

    /// Normal system apps — these have URL schemes, so they open even without the private path.
    private let schemeApps: [HiddenApp] = [
        HiddenApp(id: "settings", name: "Settings", note: "System settings", icon: "gearshape.fill", scheme: "App-prefs:"),
        HiddenApp(id: "photos", name: "Photos", note: "Hidden redirect", icon: "photo.fill", scheme: "photos-redirect://"),
        HiddenApp(id: "files", name: "Files", note: "Files app", icon: "folder.fill", scheme: "shareddocuments://"),
        HiddenApp(id: "notes", name: "Notes", note: "Notes app", icon: "note.text", scheme: "mobilenotes://"),
        HiddenApp(id: "shortcuts", name: "Shortcuts", note: "Automation", icon: "wand.and.stars", scheme: "shortcuts://"),
        HiddenApp(id: "health", name: "Health", note: "Health data", icon: "heart.fill", scheme: "x-apple-health://"),
        HiddenApp(id: "wallet", name: "Wallet", note: "Wallet", icon: "creditcard.fill", scheme: "shoebox://"),
        HiddenApp(id: "calendar", name: "Calendar", note: "Calendar", icon: "calendar", scheme: "calshow://"),
        HiddenApp(id: "reminders", name: "Reminders", note: "Reminders", icon: "checkmark.circle", scheme: "x-apple-reminder://"),
        HiddenApp(id: "compass", name: "Compass", note: "Compass", icon: "location.north.circle.fill", scheme: "compass://"),
        HiddenApp(id: "measure", name: "Measure", note: "Measure", icon: "ruler", scheme: "com.apple.measure://"),
        HiddenApp(id: "translate", name: "Translate", note: "Translate", icon: "textformat", scheme: "translate://"),
        HiddenApp(id: "tips", name: "Tips", note: "Tips", icon: "lightbulb.fill", scheme: "tips://"),
        HiddenApp(id: "podcasts", name: "Podcasts", note: "Podcasts", icon: "mic.fill", scheme: "podcasts://"),
        HiddenApp(id: "books", name: "Books", note: "Books", icon: "book.fill", scheme: "ibooks://"),
        HiddenApp(id: "appstore", name: "App Store", note: "App Store", icon: "app.fill", scheme: "itms-apps://"),
        HiddenApp(id: "maps", name: "Maps", note: "Maps", icon: "map.fill", scheme: "maps://"),
        HiddenApp(id: "clock", name: "Clock", note: "Alarms", icon: "alarm.fill", scheme: "clock-alarm://"),
        HiddenApp(id: "stocks", name: "Stocks", note: "Stocks", icon: "chart.bar.fill", scheme: "stocks://"),
        HiddenApp(id: "weather", name: "Weather", note: "Weather", icon: "cloud.sun.fill", scheme: "weather://"),
        HiddenApp(id: "freeform", name: "Freeform", note: "Freeform", icon: "pencil.tip.crop.circle", scheme: "freeform://"),
        HiddenApp(id: "findmy", name: "Find My", note: "Find My", icon: "location.fill", scheme: "findmy://"),
        HiddenApp(id: "passwords", name: "Passwords", note: "Passwords", icon: "key.fill", scheme: "passwordmanager://")
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                BlobBackground()

                List {
                    if let message {
                        Section {
                            Text(message)
                                .font(.footnote)
                                .foregroundStyle(VoltexTheme.orange)
                        }
                    }

                    Section {
                        Toggle(isOn: $showAll) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Show everything")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.white)
                                Text("Include apps this iOS version can't run")
                                    .font(.footnote)
                                    .foregroundStyle(VoltexTheme.secondary)
                            }
                        }
                        .tint(VoltexTheme.orange)
                    } footer: {
                        Text("Detected iOS \(iosMajor). Showing \(filteredInternal.count) app\(filteredInternal.count == 1 ? "" : "s") that can open here\(hiddenCount > 0 ? " — \(hiddenCount) hidden because they don't." : ".")")
                    }

                    Section {
                        ForEach(filteredInternal) { app in
                            row(app, tap: { openInternal(app) })
                        }
                    } header: {
                        Text("Hidden / internal apps")
                    } footer: {
                        Text("These ship inside iOS with no icon anywhere. A few still refuse to launch — that's the system, not Voltex.")
                    }

                    Section("System apps") {
                        ForEach(filteredScheme) { app in
                            row(app, tap: { openScheme(app) })
                        }
                    }

                    if !filteredDiscovered.isEmpty {
                        Section("Found on this device") {
                            ForEach(filteredDiscovered) { app in
                                row(app, tap: { openBundle(app.bundleID, name: app.name) })
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .searchable(text: $search, prompt: "Search apps")
            }
            .navigationTitle("Open any app")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(VoltexTheme.orange)
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear(perform: discover)
    }

    // MARK: - filtering

    private var filteredInternal: [HiddenApp] {
        match(showAll ? internalApps : workingApps)
    }
    private var filteredScheme: [HiddenApp] { match(schemeApps) }

    private func match(_ apps: [HiddenApp]) -> [HiddenApp] {
        guard !search.isEmpty else { return apps }
        return apps.filter { $0.name.localizedCaseInsensitiveContains(search) }
    }

    private struct DiscoveredApp: Identifiable {
        let id: String
        let name: String
        let bundleID: String
    }

    private var filteredDiscovered: [DiscoveredApp] {
        let known = Set((internalApps + schemeApps).flatMap { $0.candidates })
        let others = discovered
            .filter { !known.contains($0.bundleID) && !$0.bundleID.hasPrefix("com.voltex") }
            .map { DiscoveredApp(id: $0.bundleID, name: $0.name, bundleID: $0.bundleID) }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        guard !search.isEmpty else { return others }
        return others.filter { $0.name.localizedCaseInsensitiveContains(search) }
    }

    // MARK: - rows

    private func row(_ app: HiddenApp, tap: @escaping () -> Void) -> some View {
        Button(action: tap) { rowLabel(app.name, subtitle: app.note, icon: app.icon) }
            .buttonStyle(.plain)
            .listRowBackground(Color.white.opacity(0.05))
    }

    private func row(_ app: DiscoveredApp, tap: @escaping () -> Void) -> some View {
        Button(action: tap) { rowLabel(app.name, subtitle: app.bundleID, icon: "app.dashed") }
            .buttonStyle(.plain)
            .listRowBackground(Color.white.opacity(0.05))
    }

    private func rowLabel(_ title: String, subtitle: String, icon: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .fill(VoltexTheme.brandGradient)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(VoltexTheme.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "arrow.up.forward.app")
                .foregroundStyle(VoltexTheme.orange)
        }
        .padding(.vertical, 4)
    }

    // MARK: - opening

    private func openInternal(_ app: HiddenApp) {
        if let installed = resolvedBundleID(for: app), PrivateApps.open(bundleID: installed) {
            return
        }
        if let scheme = app.scheme, let url = URL(string: scheme) {
            UIApplication.shared.open(url, options: [:]) { ok in
                guard !ok else { return }
                DispatchQueue.main.async { message = "\(app.name) is blocked on this iOS version." }
            }
            return
        }
        message = "\(app.name) is blocked on this iOS version."
    }

    private func resolvedBundleID(for app: HiddenApp) -> String? {
        for candidate in app.candidates {
            if discovered.contains(where: { $0.bundleID.caseInsensitiveCompare(candidate) == .orderedSame }) {
                return candidate
            }
        }
        if let byName = discovered.first(where: { $0.name.caseInsensitiveCompare(app.name) == .orderedSame }) {
            return byName.bundleID
        }
        return app.candidates.first
    }

    private func openScheme(_ app: HiddenApp) {
        guard let scheme = app.scheme, let url = URL(string: scheme) else { return }
        UIApplication.shared.open(url, options: [:]) { ok in
            guard !ok else { return }
            DispatchQueue.main.async { message = "\(app.name) isn't available on this device." }
        }
    }

    private func openBundle(_ bundleID: String, name: String) {
        if !PrivateApps.open(bundleID: bundleID) {
            message = "\(name) isn't openable on this iOS version."
        }
    }

    private func discover() {
        discovered = PrivateApps.installed()
    }
}

/// Best-effort access to the private app list, so "open any app" can reach apps
/// that don't publish a URL scheme.
enum PrivateApps {
    static func workspace() -> NSObject? {
        guard let cls = NSClassFromString("LSApplicationWorkspace") else { return nil }
        let selector = NSSelectorFromString("defaultWorkspace")
        guard let method = class_getClassMethod(cls, selector) else { return nil }

        typealias DefaultWorkspaceFn = @convention(c) (AnyClass, Selector) -> Unmanaged<AnyObject>?
        let fn = unsafeBitCast(method_getImplementation(method), to: DefaultWorkspaceFn.self)
        return fn(cls, selector)?.takeUnretainedValue() as? NSObject
    }

    static func installed() -> [(name: String, bundleID: String)] {
        guard let ws = workspace(),
              let apps = ws.perform(NSSelectorFromString("allApplications"))?
                .takeUnretainedValue() as? [NSObject]
        else { return [] }

        return apps.compactMap { app in
            guard let name = app.perform(NSSelectorFromString("localizedName"))?
                    .takeUnretainedValue() as? String,
                  let bundleID = app.perform(NSSelectorFromString("bundleIdentifier"))?
                    .takeUnretainedValue() as? String,
                  !bundleID.isEmpty, !name.isEmpty else { return nil }
            return (name, bundleID)
        }
    }

    @discardableResult
    static func open(bundleID: String) -> Bool {
        guard let ws = workspace() else { return false }
        let selector = NSSelectorFromString("openApplicationWithBundleID:")
        guard let method = class_getInstanceMethod(type(of: ws), selector) else { return false }

        typealias OpenFn = @convention(c) (NSObject, Selector, NSString) -> Bool
        let fn = unsafeBitCast(method_getImplementation(method), to: OpenFn.self)
        return fn(ws, selector, bundleID as NSString)
    }
}
