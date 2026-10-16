import SwiftUI
import UIKit
import UniformTypeIdentifiers

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
    @AppStorage("showFakeMoneyTab") private var showFakeMoney = false

    @AppStorage("animationSpeed") private var animationSpeed = 1.0
    @AppStorage("animationsEnabled") private var animationsEnabled = true
    @AppStorage("devBlobs") private var showBlobs = true
    @AppStorage("devStars") private var showStars = true
    @AppStorage("devShockwaves") private var shockwaves = true
    @AppStorage("devTouchPoints") private var touchPoints = false
    @AppStorage("devShowFPS") private var showFPS = false
    @AppStorage("devKeepAwake") private var keepAwake = false

    @State private var path: [DevRoute] = []
    @State private var showCertificates = false

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

                    AndroidSection("Interface") {
                        AndroidActionRow(title: "Animation speed",
                                         subtitle: "Wordmark and background motion",
                                         value: speedLabel,
                                         action: cycleSpeed)
                        AndroidDivider()
                        AndroidSwitchRow(title: "Animations", subtitle: "Master switch", isOn: $animationsEnabled)
                        AndroidDivider()
                        AndroidSwitchRow(title: "Nebula blobs", isOn: $showBlobs)
                        AndroidDivider()
                        AndroidSwitchRow(title: "Starfield", isOn: $showStars)
                        AndroidDivider()
                        AndroidSwitchRow(title: "Tap shockwaves", isOn: $shockwaves)
                        AndroidDivider()
                        AndroidSwitchRow(title: "Show touch points", subtitle: "A ring wherever you tap", isOn: $touchPoints)
                        AndroidDivider()
                        AndroidSwitchRow(title: "FPS counter", subtitle: "Frames per second, top right", isOn: $showFPS)
                    }

                    AndroidSection("System") {
                        AndroidSwitchRow(title: "Stay awake while charging",
                                         subtitle: "Keep the screen on",
                                         isOn: $keepAwake)
                        AndroidDivider()
                        AndroidActionRow(title: "Certificates",
                                         subtitle: "Import a .p12 and .mobileprovision",
                                         action: { showCertificates = true })
                        AndroidDivider()
                        AndroidActionRow(title: "Clear history",
                                         subtitle: "\(HistoryStore.shared.events.count) of 20 stored",
                                         action: {
                                             HistoryStore.shared.clear()
                                             ToastCenter.shared.show("History cleared")
                                         })
                        AndroidDivider()
                        AndroidActionRow(title: "Copy device info",
                                         subtitle: "To the clipboard",
                                         action: copyDeviceInfo)
                        AndroidDivider()
                        AndroidActionRow(title: "Reset all settings",
                                         subtitle: "Keeps developer mode on",
                                         action: resetAllSettings)
                    }

                    AndroidSection("Extras") {
                        AndroidSwitchRow(title: "Fake money test",
                                         subtitle: "Adds the Fake Money tab",
                                         isOn: $showFakeMoney)
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
        .sheet(isPresented: $showCertificates) {
            CertificatesView()
        }
        .onAppear {
            Notifier.requestPermission()
            UIApplication.shared.isIdleTimerDisabled = keepAwake
        }
        .onChange(of: keepAwake) { newValue in
            UIApplication.shared.isIdleTimerDisabled = newValue
            ToastCenter.shared.show(newValue ? "Screen will stay awake" : "Screen sleep restored")
        }
    }

    private func goBack() {
        if !path.isEmpty { path.removeLast() }
    }

    private var speedLabel: String {
        if animationSpeed <= 0.6 { return "Slow" }
        if animationSpeed >= 1.7 { return "Fast" }
        return "Normal"
    }

    private func cycleSpeed() {
        if animationSpeed <= 0.6 { animationSpeed = 1.0 }
        else if animationSpeed >= 1.7 { animationSpeed = 0.5 }
        else { animationSpeed = 2.0 }
        ToastCenter.shared.show("Animation speed: \(speedLabel)")
    }

    private func copyDeviceInfo() {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?"
        let size = UIScreen.main.bounds.size
        let info = """
        Voltex \(version) (\(build))
        \(UIDevice.current.systemName) \(UIDevice.current.systemVersion)
        Model \(UIDevice.current.model)
        Screen \(Int(size.width))x\(Int(size.height)) @\(UIScreen.main.scale)x
        """
        UIPasteboard.general.string = info
        ToastCenter.shared.show("Device info copied")
    }

    private func resetAllSettings() {
        if let domain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: domain)
        }
        UserDefaults.standard.synchronize()

        animationSpeed = 1.0
        animationsEnabled = true
        showBlobs = true
        showStars = true
        shockwaves = true
        touchPoints = false
        showFPS = false
        keepAwake = false
        stayAwake = false
        showTaps = false
        pointerLocation = false
        layoutBounds = false
        showFakeMoney = false
        wirelessDebug = false
        usbDebug = false

        UserDefaults.standard.set(true, forKey: "voltexDeveloper")
        ToastCenter.shared.show("Settings reset")
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

// MARK: - Certificates

/// Holds a signing certificate (.p12) and provisioning profile, and can read the
/// profile's details back out. Stored in the app's own Documents folder.
final class CertificateStore: ObservableObject {
    static let shared = CertificateStore()

    struct ProfileInfo {
        var name: String
        var team: String
        var uuid: String
        var expires: Date?
        var deviceCount: Int
        var appID: String
    }

    @Published private(set) var p12Name: String?
    @Published private(set) var profileName: String?
    @Published private(set) var info: ProfileInfo?

    private let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    private let p12Key = "voltexP12Name"
    private let profileKey = "voltexProfileName"

    private init() { load() }

    var hasCertificate: Bool { p12Name != nil && profileName != nil }

    func importP12(_ url: URL) {
        copy(url, prefix: "cert-") { name in
            p12Name = name
            UserDefaults.standard.set(name, forKey: p12Key)
            ToastCenter.shared.show("Certificate imported")
        }
    }

    func importProfile(_ url: URL) {
        copy(url, prefix: "profile-") { name in
            profileName = name
            UserDefaults.standard.set(name, forKey: profileKey)
            info = Self.readProfile(docs.appendingPathComponent(name))
            ToastCenter.shared.show(info == nil ? "Profile imported" : "Profile: \(info!.name)")
        }
    }

    func removeAll() {
        for name in [p12Name, profileName].compactMap({ $0 }) {
            try? FileManager.default.removeItem(at: docs.appendingPathComponent(name))
        }
        p12Name = nil
        profileName = nil
        info = nil
        UserDefaults.standard.removeObject(forKey: p12Key)
        UserDefaults.standard.removeObject(forKey: profileKey)
        ToastCenter.shared.show("Certificate removed")
    }

    private func copy(_ url: URL, prefix: String, done: (String) -> Void) {
        let scoped = url.startAccessingSecurityScopedResource()
        defer { if scoped { url.stopAccessingSecurityScopedResource() } }

        let extensionPart = url.pathExtension.isEmpty ? "bin" : url.pathExtension
        let name = "\(prefix)\(UUID().uuidString).\(extensionPart)"
        let destination = docs.appendingPathComponent(name)
        do {
            try? FileManager.default.removeItem(at: destination)
            try FileManager.default.copyItem(at: url, to: destination)
            done(name)
        } catch {
            ToastCenter.shared.show("Couldn't import that file")
        }
    }

    private func load() {
        p12Name = UserDefaults.standard.string(forKey: p12Key)
        profileName = UserDefaults.standard.string(forKey: profileKey)
        if let profileName {
            info = Self.readProfile(docs.appendingPathComponent(profileName))
        }
    }

    /// A .mobileprovision is a CMS blob with a plist inside it.
    static func readProfile(_ url: URL) -> ProfileInfo? {
        guard let data = try? Data(contentsOf: url),
              let start = data.range(of: Data("<?xml".utf8)),
              let end = data.range(of: Data("</plist>".utf8), in: start.lowerBound..<data.endIndex)
        else { return nil }

        let plistData = data.subdata(in: start.lowerBound..<end.upperBound)
        guard let plist = (try? PropertyListSerialization.propertyList(from: plistData, options: [], format: nil)) as? [String: Any]
        else { return nil }

        return ProfileInfo(
            name: plist["Name"] as? String ?? "Unnamed",
            team: plist["TeamName"] as? String ?? "Unknown team",
            uuid: plist["UUID"] as? String ?? "-",
            expires: plist["ExpirationDate"] as? Date,
            deviceCount: (plist["ProvisionedDevices"] as? [String])?.count ?? 0,
            appID: plist["Entitlements"].flatMap { ($0 as? [String: Any])?["application-identifier"] as? String } ?? "-"
        )
    }
}

struct CertificatesView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = CertificateStore.shared

    @State private var showP12Picker = false
    @State private var showProfilePicker = false

    var body: some View {
        NavigationStack {
            ZStack {
                AndroidPalette.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        AndroidSection("Signing certificate") {
                            AndroidActionRow(title: store.p12Name == nil ? "Import .p12" : ".p12 imported",
                                             subtitle: store.p12Name == nil ? "Tap to choose your certificate file" : "Tap to replace",
                                             action: { showP12Picker = true })
                            AndroidDivider()
                            AndroidActionRow(title: store.profileName == nil ? "Import .mobileprovision" : ".mobileprovision imported",
                                             subtitle: store.profileName == nil ? "Tap to choose your profile" : "Tap to replace",
                                             action: { showProfilePicker = true })
                        }

                        if let info = store.info {
                            AndroidSection("Profile") {
                                AndroidInfoRow(title: "Name", value: info.name)
                                AndroidDivider()
                                AndroidInfoRow(title: "Team", value: info.team)
                                AndroidDivider()
                                AndroidInfoRow(title: "App ID", value: info.appID)
                                AndroidDivider()
                                AndroidInfoRow(title: "Devices", value: "\(info.deviceCount)")
                                AndroidDivider()
                                AndroidInfoRow(title: "Expires", value: info.expires.map { Self.formatter.string(from: $0) } ?? "unknown")
                            }
                        }

                        AndroidSection("") {
                            AndroidActionRow(title: "Remove certificate", action: { store.removeAll() })
                        }

                        AndroidFooter(text: "Voltex keeps your certificate here and reads your profile, but it cannot re-sign an IPA. Signing needs Apple's code-signing engine plus your private key, which is exactly what ESign/Scarlet ship. Voltex installs an IPA that is already signed — point it at a signed build and it will hand it to iOS.")
                    }
                    .padding(16)
                    .padding(.bottom, 30)
                }

                AndroidToastHost()
            }
            .navigationTitle("Certificates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(AndroidPalette.accent)
                }
            }
            .fileImporter(isPresented: $showP12Picker, allowedContentTypes: [.data, .item]) { result in
                if case .success(let url) = result { store.importP12(url) }
            }
            .fileImporter(isPresented: $showProfilePicker, allowedContentTypes: [.data, .item]) { result in
                if case .success(let url) = result { store.importProfile(url) }
            }
        }
        .preferredColorScheme(.light)
    }

    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }()
}
