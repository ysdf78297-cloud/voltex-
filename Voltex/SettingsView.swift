import SwiftUI
import UIKit

// MARK: - Android-style toast

final class ToastCenter: ObservableObject {
    static let shared = ToastCenter()

    @Published private(set) var message: String?
    private var dismissWork: DispatchWorkItem?

    func show(_ text: String) {
        dismissWork?.cancel()
        withAnimation(.easeOut(duration: 0.2)) { message = text }

        let work = DispatchWorkItem { [weak self] in
            withAnimation(.easeIn(duration: 0.25)) { self?.message = nil }
        }
        dismissWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2, execute: work)
    }
}

/// A little dark pill that slides up from the bottom — Android's toast.
struct AndroidToastHost: View {
    @ObservedObject private var center = ToastCenter.shared

    var body: some View {
        VStack {
            Spacer()
            if let message = center.message {
                Text(message)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color(white: 0.94))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 13)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color(white: 0.16).opacity(0.97))
                            .shadow(color: .black.opacity(0.45), radius: 12, y: 4)
                    )
                    .padding(.horizontal, 28)
                    .padding(.bottom, 132)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}

struct SettingsView: View {
    @AppStorage("animationsEnabled") private var animationsEnabled = true
    @AppStorage("voltexDeveloper") private var isDeveloper = false

    @State private var buildTaps = 0
    @State private var showDeveloper = false

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
                        buildRow
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
                                    Text("Debugging")
                                        .font(.system(size: 15))
                                        .foregroundStyle(VoltexTheme.secondary)
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(VoltexTheme.secondary)
                                }
                                .padding(.vertical, 14)
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

    private func row(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white)
            Spacer(minLength: 16)
            Text(value)
                .font(.system(size: 15))
                .foregroundStyle(VoltexTheme.secondary)
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

// MARK: - Developer options (Android styled)

struct DeveloperOptionsView: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage("voltexWirelessDebug") private var wirelessDebug = false
    @AppStorage("voltexUSBDebug") private var usbDebug = false

    private let androidBlue = Color(red: 0.13, green: 0.59, blue: 0.95)
    private let background = Color(red: 0.94, green: 0.94, blue: 0.94)
    private let onSurface = Color(red: 0.13, green: 0.13, blue: 0.13)

    var body: some View {
        NavigationStack {
            ZStack {
                background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        banner

                        card {
                            devToggle("Wireless debugging",
                                      subtitle: "Debug apps over Wi-Fi",
                                      isOn: $wirelessDebug)
                            divider
                            devToggle("USB debugging",
                                      subtitle: "Debug apps over USB",
                                      isOn: $usbDebug)
                        }

                        Text("These are here for looks — iOS doesn't expose Android's debugging bridge. Leaving them on is harmless.")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 4)
                    }
                    .padding(16)
                }

                AndroidToastHost()
            }
            .navigationTitle("Developer options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "arrow.backward")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundStyle(onSurface)
                }
            }
            .onChange(of: wirelessDebug) { newValue in
                ToastCenter.shared.show(newValue ? "Wireless debugging on" : "Wireless debugging off")
            }
            .onChange(of: usbDebug) { newValue in
                ToastCenter.shared.show(newValue ? "USB debugging on" : "USB debugging off")
            }
        }
        .preferredColorScheme(.light)
    }

    private var banner: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(Color(red: 0.72, green: 0.30, blue: 0.05))
            VStack(alignment: .leading, spacing: 2) {
                Text("You are a developer now!")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(onSurface)
                Text("Tap the build number again to change this later.")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(red: 1.0, green: 0.95, blue: 0.86))
        )
    }

    private var divider: some View {
        Rectangle().fill(Color.black.opacity(0.08)).frame(height: 1)
    }

    private func devToggle(_ title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(onSurface)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(androidBlue)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private func card<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) { content() }
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
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
