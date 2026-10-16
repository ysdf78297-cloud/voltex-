import SwiftUI
import UIKit

struct SettingsView: View {
    @AppStorage("animationsEnabled") private var animationsEnabled = true

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
                    Text("Settings")
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundStyle(VoltexTheme.brandGradient)
                        .padding(.top, 24)

                    card("App") {
                        row("Version", version)
                        divider
                        row("Build", build)
                        divider
                        row("Bundle ID", bundleID)
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
                    }

                    Text("Voltex")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .kerning(3)
                        .foregroundStyle(VoltexTheme.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)
                        .padding(.bottom, 40)
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private var divider: some View {
        Rectangle().fill(VoltexTheme.hairline).frame(height: 1)
    }

    private func row(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white)
            Spacer(minLength: 16)
            Text(value)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(VoltexTheme.secondary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 12)
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
}

enum DeviceInfo {
    /// e.g. "iPhone15,2" -> "iPhone 15 Pro"-ish; falls back to the raw id.
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
