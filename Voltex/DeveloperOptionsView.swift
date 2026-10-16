import SwiftUI
import UIKit

// MARK: - Android styling

enum AndroidPalette {
    static let background = Color(red: 0.945, green: 0.953, blue: 0.957)
    static let surface    = Color.white
    static let onSurface  = Color(red: 0.125, green: 0.129, blue: 0.141)
    static let secondary  = Color(red: 0.373, green: 0.388, blue: 0.408)
    static let accent     = Color(red: 0.102, green: 0.451, blue: 0.910)
    static let divider    = Color(red: 0.855, green: 0.863, blue: 0.878)
}

/// An Android-style screen: light grey, a back arrow with the title, white cards.
struct AndroidScreen<Content: View>: View {
    let title: String
    let showBack: Bool
    let onBack: (() -> Void)?
    let content: Content

    init(title: String, showBack: Bool = true, onBack: (() -> Void)? = nil,
         @ViewBuilder content: () -> Content) {
        self.title = title
        self.showBack = showBack
        self.onBack = onBack
        self.content = content()
    }

    var body: some View {
        ZStack {
            AndroidPalette.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    if showBack {
                        Button { onBack?() } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "arrow.backward")
                                    .font(.system(size: 18, weight: .medium))
                                Text(title)
                                    .font(.system(size: 21, weight: .semibold))
                            }
                            .foregroundStyle(AndroidPalette.onSurface)
                            .padding(.horizontal, 16)
                            .padding(.top, 10)
                            .padding(.bottom, 4)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }

                    content
                        .padding(.horizontal, 16)
                        .padding(.bottom, 48)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            AndroidToastHost()
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct AndroidSection<Content: View>: View {
    let title: String
    let content: Content

    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !title.isEmpty {
                Text(title.uppercased())
                    .font(.system(size: 12, weight: .bold))
                    .kerning(0.6)
                    .foregroundStyle(AndroidPalette.accent)
                    .padding(.horizontal, 6)
            }
            VStack(spacing: 0) { content }
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(AndroidPalette.surface)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}

struct AndroidDivider: View {
    var body: some View {
        Rectangle()
            .fill(AndroidPalette.divider)
            .frame(height: 1)
            .padding(.leading, 16)
    }
}

struct AndroidSwitchRow: View {
    let title: String
    var subtitle: String? = nil
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16))
                    .foregroundStyle(AndroidPalette.onSurface)
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(AndroidPalette.secondary)
                }
            }
            Spacer(minLength: 8)
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(AndroidPalette.accent)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
    }
}

/// A toggle row whose text opens a sub-screen — exactly how Android does it.
struct AndroidNavRow: View {
    let title: String
    var subtitle: String? = nil
    @Binding var isOn: Bool
    let action: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: action) {
                HStack(spacing: 6) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.system(size: 16))
                            .foregroundStyle(AndroidPalette.onSurface)
                        if let subtitle {
                            Text(subtitle)
                                .font(.system(size: 12))
                                .foregroundStyle(AndroidPalette.secondary)
                        }
                    }
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AndroidPalette.secondary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(AndroidPalette.accent)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
    }
}

struct AndroidActionRow: View {
    let title: String
    var subtitle: String? = nil
    var value: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16))
                        .foregroundStyle(AndroidPalette.onSurface)
                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: 12))
                            .foregroundStyle(AndroidPalette.secondary)
                    }
                }
                Spacer(minLength: 8)
                if let value {
                    Text(value)
                        .font(.system(size: 14))
                        .foregroundStyle(AndroidPalette.secondary)
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AndroidPalette.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct AndroidInfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16))
                .foregroundStyle(AndroidPalette.onSurface)
            Spacer(minLength: 8)
            Text(value)
                .font(.system(size: 14))
                .foregroundStyle(AndroidPalette.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
    }
}

struct AndroidFooter: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 12))
            .foregroundStyle(AndroidPalette.secondary)
            .padding(.horizontal, 6)
    }
}

// MARK: - Routes

enum DevRoute: Hashable {
    case wireless
    case usb
    case usbConfig
}

// MARK: - Developer options

struct DeveloperOptionsView: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage("voltexWirelessDebug") private var wirelessDebug = false
    @AppStorage("voltexUSBDebug") private var usbDebug = false
    @AppStorage("voltexStayAwake") private var stayAwake = false
    @AppStorage("voltexShowTaps") private var showTaps = false
    @AppStorage("voltexPointerLocation") private var pointerLocation = false
    @AppStorage("voltexLayoutBounds") private var layoutBounds = false

    @State private var path: [DevRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            AndroidScreen(title: "Developer options", onBack: { dismiss() }) {
                VStack(alignment: .leading, spacing: 18) {
                    banner

                    AndroidSection("Debugging") {
                        AndroidNavRow(title: "Wireless debugging",
                                      subtitle: "Debug apps over Wi-Fi",
                                      isOn: $wirelessDebug,
                                      action: { path.append(.wireless) })
                        AndroidDivider()
                        AndroidNavRow(title: "USB debugging",
                                      subtitle: "Debug apps over USB",
                                      isOn: $usbDebug,
                                      action: { path.append(.usb) })
                    }

                    AndroidSection("Tools") {
                        AndroidActionRow(title: "Send test notification",
                                         subtitle: "Posts a real iOS notification",
                                         action: {
                                             Notifier.requestPermission()
                                             Notifier.send(title: "Voltex", body: "This is a test")
                                             ToastCenter.shared.show("Test notification sent")
                                         })
                    }

                    AndroidSection("Drawing") {
                        AndroidSwitchRow(title: "Show taps", subtitle: "Show a dot where you touch", isOn: $showTaps)
                        AndroidDivider()
                        AndroidSwitchRow(title: "Pointer location", subtitle: "Show touch coordinates", isOn: $pointerLocation)
                        AndroidDivider()
                        AndroidSwitchRow(title: "Show layout bounds", isOn: $layoutBounds)
                    }

                    AndroidSection("Battery") {
                        AndroidSwitchRow(title: "Stay awake while charging", isOn: $stayAwake)
                    }

                    AndroidFooter(text: "These switches are cosmetic. iOS doesn't expose Android's ADB bridge or a build number, so nothing here changes how your iPhone actually works.")
                }
            }
            .navigationDestination(for: DevRoute.self) { route in
                switch route {
                case .wireless:
                    WirelessDebuggingView(onBack: { goBack() })
                case .usb:
                    USBDebuggingView(onBack: { goBack() },
                                     onConfig: { path.append(.usbConfig) })
                case .usbConfig:
                    USBConfigurationView(onBack: { goBack() })
                }
            }
        }
        .preferredColorScheme(.light)
        .onAppear { Notifier.requestPermission() }
    }

    private func goBack() {
        if !path.isEmpty { path.removeLast() }
    }

    private var banner: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(Color(red: 0.72, green: 0.30, blue: 0.05))
            VStack(alignment: .leading, spacing: 3) {
                Text("You are a developer now!")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AndroidPalette.onSurface)
                Text("Debugging features are available on this device.")
                    .font(.system(size: 12))
                    .foregroundStyle(AndroidPalette.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(red: 1.0, green: 0.95, blue: 0.86))
        )
    }
}

// MARK: - Wireless debugging

struct WirelessDebuggingView: View {
    let onBack: () -> Void

    @AppStorage("voltexWirelessDebug") private var enabled = false
    @State private var showPairing = false
    @State private var pairingCode = "000000"

    private var ipAddress: String { "192.168.1.42" }
    private var port: Int { 38651 }

    var body: some View {
        AndroidScreen(title: "Wireless debugging", onBack: onBack) {
            VStack(alignment: .leading, spacing: 18) {
                AndroidSection("") {
                    AndroidSwitchRow(title: "Wireless debugging",
                                     subtitle: "Debug apps over Wi-Fi on this network",
                                     isOn: $enabled)
                }

                if enabled {
                    AndroidSection("Current connection") {
                        AndroidInfoRow(title: "IP address & Port", value: "\(ipAddress):\(port)")
                        AndroidDivider()
                        AndroidActionRow(title: "Pair device with pairing code",
                                         subtitle: "Shows a 6-digit Wi-Fi pairing code",
                                         action: {
                                             pairingCode = String(format: "%06d", Int.random(in: 0...999999))
                                             showPairing = true
                                         })
                    }

                    AndroidSection("Paired devices") {
                        AndroidActionRow(title: "JACOBSPC", subtitle: "Paired", action: {
                            ToastCenter.shared.show("Forgot JACOBSPC")
                        })
                    }
                }

                AndroidFooter(text: "Wireless debugging lets a computer connect to this device over your Wi-Fi network after pairing with a code.")
            }
        }
        .sheet(isPresented: $showPairing) {
            pairingSheet
        }
        .onChange(of: enabled) { newValue in
            ToastCenter.shared.show(newValue ? "Wireless debugging on" : "Wireless debugging off")
        }
    }

    private var pairingSheet: some View {
        VStack(spacing: 18) {
            Text("Pair with pairing code")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(AndroidPalette.onSurface)

            Text("On your computer, enter this code.")
                .font(.system(size: 13))
                .foregroundStyle(AndroidPalette.secondary)

            Text("\(ipAddress):\(port)")
                .font(.system(size: 17, weight: .medium, design: .monospaced))
                .foregroundStyle(AndroidPalette.onSurface)

            Text(pairingCode)
                .font(.system(size: 40, weight: .bold, design: .monospaced))
                .kerning(6)
                .foregroundStyle(AndroidPalette.accent)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(AndroidPalette.background)
                )

            Button {
                showPairing = false
                ToastCenter.shared.show("Pairing code dismissed")
            } label: {
                Text("Cancel")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AndroidPalette.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.plain)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AndroidPalette.surface.ignoresSafeArea())
        .preferredColorScheme(.light)
    }
}

// MARK: - USB debugging

struct USBDebuggingView: View {
    let onBack: () -> Void
    let onConfig: () -> Void

    @AppStorage("voltexUSBDebug") private var enabled = false

    var body: some View {
        AndroidScreen(title: "USB debugging", onBack: onBack) {
            VStack(alignment: .leading, spacing: 18) {
                AndroidSection("") {
                    AndroidSwitchRow(title: "USB debugging",
                                     subtitle: "Debug mode when USB is connected",
                                     isOn: $enabled)
                }

                AndroidSection("Authorisations") {
                    AndroidActionRow(title: "Revoke USB debugging authorisations",
                                     subtitle: "Clear all trusted computers",
                                     action: { ToastCenter.shared.show("Authorisations revoked") })
                }

                AndroidSection("Default USB configuration") {
                    AndroidActionRow(title: "USB configuration",
                                     value: USBModeStore.current.label,
                                     action: onConfig)
                }

                AndroidFooter(text: "USB debugging allows a connected computer to read logs and install apps through Android's ADB. iOS has no equivalent, so this is display only.")
            }
        }
        .onChange(of: enabled) { newValue in
            ToastCenter.shared.show(newValue ? "USB debugging on" : "USB debugging off")
        }
    }
}

// MARK: - Default USB configuration

enum USBModeStore {
    static let all = ["No data transfer", "File transfer", "USB tethering", "MIDI", "PTP"]
    static var index: Int {
        get { UserDefaults.standard.integer(forKey: "voltexUSBMode") }
        set { UserDefaults.standard.set(newValue, forKey: "voltexUSBMode") }
    }
    static var current: (label: String, index: Int) {
        let i = min(max(index, 0), all.count - 1)
        return (all[i], i)
    }
}

struct USBConfigurationView: View {
    let onBack: () -> Void
    @State private var selected = USBModeStore.index

    var body: some View {
        AndroidScreen(title: "Default USB configuration", onBack: onBack) {
            VStack(alignment: .leading, spacing: 18) {
                AndroidSection("") {
                    ForEach(Array(USBModeStore.all.enumerated()), id: \.offset) { index, mode in
                        Button {
                            selected = index
                            USBModeStore.index = index
                            ToastCenter.shared.show("Set to \(mode)")
                        } label: {
                            HStack(spacing: 12) {
                                Text(mode)
                                    .font(.system(size: 16))
                                    .foregroundStyle(AndroidPalette.onSurface)
                                Spacer(minLength: 8)
                                if selected == index {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundStyle(AndroidPalette.accent)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 13)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        if index < USBModeStore.all.count - 1 { AndroidDivider() }
                    }
                }

                AndroidFooter(text: "How this device appears to a connected computer.")
            }
        }
    }
}
