import SwiftUI
import UIKit
import ObjectiveC

struct HiddenApp: Identifiable {
    let id: String
    let name: String
    let scheme: String
    let icon: String
    let note: String
}

/// Lists the hidden / system apps you normally can't reach, and opens them.
struct AppLauncherView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var search = ""
    @State private var message: String?
    @State private var discovered: [HiddenApp] = []

    private let hiddenApps: [HiddenApp] = [
        HiddenApp(id: "settings",   name: "Settings",     scheme: "App-prefs:",          icon: "gearshape.fill",     note: "System settings"),
        HiddenApp(id: "photos",     name: "Photos",       scheme: "photos-redirect://",  icon: "photo.fill",         note: "Hidden redirect"),
        HiddenApp(id: "files",      name: "Files",        scheme: "shareddocuments://",  icon: "folder.fill",        note: "Files app"),
        HiddenApp(id: "notes",      name: "Notes",        scheme: "mobilenotes://",      icon: "note.text",          note: "Notes app"),
        HiddenApp(id: "shortcuts",  name: "Shortcuts",    scheme: "shortcuts://",        icon: "wand.and.stars",     note: "Automation"),
        HiddenApp(id: "health",     name: "Health",       scheme: "x-apple-health://",   icon: "heart.fill",         note: "Health data"),
        HiddenApp(id: "wallet",     name: "Wallet",       scheme: "shoebox://",          icon: "creditcard.fill",    note: "Wallet"),
        HiddenApp(id: "watch",      name: "Watch",        scheme: "watchapp://",         icon: "applewatch",         note: "Watch app"),
        HiddenApp(id: "calendar",   name: "Calendar",     scheme: "calshow://",          icon: "calendar",           note: "Calendar"),
        HiddenApp(id: "reminders",  name: "Reminders",    scheme: "x-apple-reminder://", icon: "checkmark.circle",   note: "Reminders"),
        HiddenApp(id: "compass",    name: "Compass",      scheme: "compass://",          icon: "location.north.circle.fill", note: "Compass"),
        HiddenApp(id: "measure",    name: "Measure",      scheme: "com.apple.measure://", icon: "ruler",             note: "Measure"),
        HiddenApp(id: "translate",  name: "Translate",    scheme: "translate://",        icon: "textformat",         note: "Translate"),
        HiddenApp(id: "tips",       name: "Tips",         scheme: "tips://",             icon: "lightbulb.fill",     note: "Tips"),
        HiddenApp(id: "podcasts",   name: "Podcasts",     scheme: "podcasts://",         icon: "mic.fill",           note: "Podcasts"),
        HiddenApp(id: "books",      name: "Books",        scheme: "ibooks://",           icon: "book.fill",          note: "Books"),
        HiddenApp(id: "appstore",   name: "App Store",    scheme: "itms-apps://",        icon: "app.fill",           note: "App Store"),
        HiddenApp(id: "maps",       name: "Maps",         scheme: "maps://",             icon: "map.fill",           note: "Maps"),
        HiddenApp(id: "clock",      name: "Clock",        scheme: "clock-alarm://",      icon: "alarm.fill",         note: "Alarms"),
        HiddenApp(id: "stocks",     name: "Stocks",       scheme: "stocks://",           icon: "chart.bar.fill",     note: "Stocks"),
        HiddenApp(id: "weather",    name: "Weather",      scheme: "weather://",          icon: "cloud.sun.fill",     note: "Weather"),
        HiddenApp(id: "freeform",   name: "Freeform",     scheme: "freeform://",         icon: "pencil.tip.crop.circle", note: "Freeform"),
        HiddenApp(id: "findmy",     name: "Find My",      scheme: "findmy://",           icon: "location.fill",      note: "Find My"),
        HiddenApp(id: "passwords",  name: "Passwords",    scheme: "passwordmanager://",  icon: "key.fill",           note: "Passwords"),
        HiddenApp(id: "feedback",   name: "Feedback",     scheme: "feedback://",         icon: "bubble.left.fill",   note: "Feedback Assistant"),
        HiddenApp(id: "diagnostics",name: "Diagnostics",  scheme: "diagnostics://",      icon: "waveform.path.ecg",  note: "Diagnostics")
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

                    if !discovered.isEmpty {
                        Section("Found on this device") {
                            ForEach(discovered) { app in
                                row(app, action: { openBundle(app.id) })
                            }
                        }
                    }

                    Section("Hidden system apps") {
                        ForEach(filtered) { app in
                            row(app, action: { open(app) })
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

    private var filtered: [HiddenApp] {
        guard !search.isEmpty else { return hiddenApps }
        return hiddenApps.filter { $0.name.localizedCaseInsensitiveContains(search) }
    }

    private func row(_ app: HiddenApp, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: app.icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 34)
                    .background(
                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .fill(VoltexTheme.brandGradient)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(app.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                    Text(app.note)
                        .font(.footnote)
                        .foregroundStyle(VoltexTheme.secondary)
                }

                Spacer()

                Image(systemName: "arrow.up.forward.app")
                    .foregroundStyle(VoltexTheme.orange)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
        .listRowBackground(Color.white.opacity(0.05))
    }

    private func open(_ app: HiddenApp) {
        guard let url = URL(string: app.scheme) else {
            message = "That link isn't valid."
            return
        }
        UIApplication.shared.open(url, options: [:]) { ok in
            guard !ok else { return }
            DispatchQueue.main.async {
                message = "\(app.name) can't be opened on this device."
            }
        }
    }

    private func openBundle(_ bundleID: String) {
        PrivateApps.open(bundleID: bundleID)
    }

    private func discover() {
        let found = PrivateApps.installed()
        discovered = found
            .map { HiddenApp(id: $0.bundleID, name: $0.name, scheme: "", icon: "app.dashed", note: $0.bundleID) }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}

/// Best-effort access to the private app list, so "open any app" can reach apps
/// that don't publish a URL scheme. Falls back silently to the curated list.
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
                  !bundleID.isEmpty else { return nil }
            return (name, bundleID)
        }
    }

    static func open(bundleID: String) {
        _ = workspace()?.perform(NSSelectorFromString("openApplicationWithBundleID:"), with: bundleID)
    }
}
