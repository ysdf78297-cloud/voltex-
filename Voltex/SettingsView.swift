import SwiftUI
import UIKit

struct SettingsView: View {
    @AppStorage("animationsEnabled") private var animationsEnabled = true
    @AppStorage("voltexDeveloper") private var isDeveloper = false

    @State private var buildTaps = 0
    @State private var showDeveloper = false
    @State private var confirmClear = false

    private var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    private var build: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    private var bundleID: String {
        Bundle.main.bundleIdentifier ?? "com.voltex.app"
    }

    var body: some View {
        ZStack {
            BlobBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(alignment: .center) {
                        Text("Settings")
                            .font(.system(size: 40, weight: .black, design: .rounded))
                            .foregroundStyle(VoltexTheme.brandGradient)

                        Spacer(minLength: 12)

                        Button {
                            confirmClear = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "trash")
                                    .font(.system(size: 13, weight: .bold))
                                Text("Clear data")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(Capsule().stroke(Color.red.opacity(0.65), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 24)

                    card("App") {
                        row("Version", version)
                        divider
                        buildRow
                        divider
                        row("Bundle ID",
                            isDeveloper ? bundleID : "You need to be a developer to see this",
                            valueColor: isDeveloper ? VoltexTheme.secondary : VoltexTheme.orange)
                        divider
                        row("Theme", "Orange / Black")
                    }

                    card("Device") {
                        row("Model", DeviceInfo.modelName)
                        divider
                        row("System", "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)")
                    }

                    card("Preferences") {
                        Toggle(isOn: $animationsEnabled) {
                            Text("Animations")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.white)
                        }
                        .tint(VoltexTheme.orange)
                        .padding(.vertical, 6)
                    }

                    if isDeveloper {
                        card("Developer") {
                            Button { showDeveloper = true } label: {
                                HStack {
                                    Text("Developer options")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(.white)
                                    Spacer()
                                    Text("Wireless + USB debugging")
                                        .font(.system(size: 14))
                                        .foregroundStyle(VoltexTheme.secondary)
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(VoltexTheme.secondary)
                                }
                                .padding(.vertical, 14)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Text("Voltex")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .kerning(3)
                        .foregroundStyle(VoltexTheme.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)
                        .padding(.bottom, 140)
                }
                .padding(.horizontal, 20)
            }
        }
        .sheet(isPresented: $showDeveloper) {
            DeveloperOptionsView()
        }
        .alert("Clear all data?", isPresented: $confirmClear) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) { clearAllData() }
        } message: {
            Text("Wipes everything Voltex remembers about you — settings, developer mode and all saved data — then closes the app.")
        }
    }

    /// Wipes every stored value and fully quits, so the app comes back like a fresh install.
    private func clearAllData() {
        let defaults = UserDefaults.standard
        if let domain = Bundle.main.bundleIdentifier {
            defaults.removePersistentDomain(forName: domain)
        }
        defaults.synchronize()
        Notifier.clearAll()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            exit(0)
        }
    }

    // MARK: - pieces

    private var divider: some View {
        Rectangle().fill(VoltexTheme.hairline).frame(height: 1)
    }

    private var buildRow: some View {
        Button(action: registerBuildTap) {
            HStack {
                Text("Build")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
                Spacer(minLength: 16)
                Text(build)
                    .font(.system(size: 15))
                    .foregroundStyle(VoltexTheme.secondary)
            }
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func row(_ title: String, _ value: String, valueColor: Color = VoltexTheme.secondary) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white)
            Spacer(minLength: 16)
            Text(value)
                .font(.system(size: 15))
                .foregroundStyle(valueColor)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 14)
    }

    private func card<Content: View>(_ title: String, @ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .kerning(1.4)
                .foregroundStyle(VoltexTheme.orange)
                .padding(.bottom, 10)

            VStack(alignment: .leading, spacing: 0) { content() }
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: VoltexTheme.corner, style: .continuous)
                        .fill(VoltexTheme.card)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: VoltexTheme.corner, style: .continuous)
                        .stroke(VoltexTheme.hairline, lineWidth: 1)
                )
        }
    }

    // MARK: - developer mode
    //
    // Tapping the build number enables developer mode. Nothing on screen says how.

    private func registerBuildTap() {
        if isDeveloper {
            ToastCenter.shared.show("You are already a developer")
            return
        }

        buildTaps += 1
        let remaining = 5 - buildTaps

        if remaining <= 0 {
            isDeveloper = true
            ToastCenter.shared.show("You are now a developer!")
        } else {
            ToastCenter.shared.show("Click \(remaining) time\(remaining == 1 ? "" : "s") more to access Developer")
        }
    }
}

enum DeviceInfo {
    /// e.g. "iPhone15,2" -> "iPhone 14 Pro"; falls back to the raw id.
    static var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let mirror = Mirror(reflecting: systemInfo.machine)
        let identifier = mirror.children.reduce(into: "") { partial, element in
            guard let value = element.value as? Int8, value != 0 else { return }
            partial.append(Character(UnicodeScalar(UInt8(value))))
        }
        return friendly[identifier] ?? identifier
    }

    private static let friendly: [String: String] = [
        "iPhone14,7": "iPhone 14",
        "iPhone14,8": "iPhone 14 Plus",
        "iPhone15,2": "iPhone 14 Pro",
        "iPhone15,3": "iPhone 14 Pro Max",
        "iPhone15,4": "iPhone 15",
        "iPhone15,5": "iPhone 15 Plus",
        "iPhone16,1": "iPhone 15 Pro",
        "iPhone16,2": "iPhone 15 Pro Max",
        "iPhone17,1": "iPhone 16 Pro",
        "iPhone17,2": "iPhone 16 Pro Max",
        "iPhone17,3": "iPhone 16",
        "iPhone17,4": "iPhone 16 Plus"
    ]
}

#Preview {
    SettingsView().preferredColorScheme(.dark)
}
