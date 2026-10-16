import SwiftUI
import UIKit
import UniformTypeIdentifiers
import Security
import CryptoKit

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

/// A toggle row whose text opens a sub-screen â€” exactly how Android does it.
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
            CertificateView(onClose: { showCertificates = false })
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


// MARK: - Certificate storage

enum Keychain {
    private static let service = "com.voltex.app"

    static func set(_ value: String, for key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)

        var add = query
        add[kSecValueData as String] = Data(value.utf8)
        add[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlocked
        SecItemAdd(add as CFDictionary, nil)
    }

    static func get(_ key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func remove(_ key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}

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
    private let passwordKey = "voltexP12Password"

    private init() { load() }

    var hasCertificate: Bool { p12Name != nil && profileName != nil }

    var password: String { Keychain.get(passwordKey) ?? "" }

    func savePassword(_ value: String) {
        if value.isEmpty { Keychain.remove(passwordKey) } else { Keychain.set(value, for: passwordKey) }
    }

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
        Keychain.remove(passwordKey)
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

        let entitlements = plist["Entitlements"] as? [String: Any]
        return ProfileInfo(
            name: plist["Name"] as? String ?? "Unnamed",
            team: plist["TeamName"] as? String ?? "Unknown team",
            uuid: plist["UUID"] as? String ?? "-",
            expires: plist["ExpirationDate"] as? Date,
            deviceCount: (plist["ProvisionedDevices"] as? [String])?.count ?? 0,
            appID: entitlements?["application-identifier"] as? String ?? "-"
        )
    }
}

// MARK: - Experimental key + certificate request generation

enum CertificateFactory {
    struct Output {
        var pem: String
        var keyDescription: String
        var fingerprint: String
    }

    /// Generates an RSA-2048 key pair in the Keychain and a PKCS#10 certificate
    /// request (CSR) you could hand to Apple or a CA. Experimental: it makes the
    /// request, not the certificate â€” only Apple or a CA can issue one.
    static func makeRequest(commonName: String) -> Output? {
        let tag = "com.voltex.csr.\(UUID().uuidString)".data(using: .utf8) ?? Data()

        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits as String: 2048,
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String: true,
                kSecAttrApplicationTag as String: tag
            ]
        ]

        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error),
              let publicKey = SecKeyCopyPublicKey(privateKey),
              let publicDER = SecKeyCopyExternalRepresentation(publicKey, &error) as Data?
        else { return nil }

        let subject = DER.sequence([
            DER.set([
                DER.sequence([
                    DER.oid([0x55, 0x04, 0x03]),          // commonName
                    DER.utf8(commonName)
                ])
            ])
        ])

        let algorithm = DER.sequence([
            DER.oid([0x2A, 0x86, 0x48, 0x86, 0xF7, 0x0D, 0x01, 0x01, 0x01]),  // rsaEncryption
            DER.null()
        ])

        let publicKeyInfo = DER.sequence([
            algorithm,
            DER.bitString([UInt8](publicDER))
        ])

        let requestInfo = DER.sequence([
            DER.integer(0),
            subject,
            publicKeyInfo,
            DER.tagged(0xA0, [])                                   // no attributes
        ])

        let signatureAlgorithm = DER.sequence([
            DER.oid([0x2A, 0x86, 0x48, 0x86, 0xF7, 0x0D, 0x01, 0x01, 0x0B]),  // sha256WithRSA
            DER.null()
        ])

        guard let signature = SecKeyCreateSignature(privateKey,
                                                    .rsaSignatureMessagePKCS1v15SHA256,
                                                    Data(requestInfo) as CFData,
                                                    &error) as Data? else { return nil }

        let request = DER.sequence([
            requestInfo,
            signatureAlgorithm,
            DER.bitString([UInt8](signature))
        ])

        let base64 = Data(request).base64EncodedString(options: [.lineLength64Characters,
                                                                 .endLineWithLineFeed])
        let pem = "-----BEGIN CERTIFICATE REQUEST-----\n\(base64)\n-----END CERTIFICATE REQUEST-----"

        let digest = SHA256.hash(data: publicDER)
        let fingerprint = digest.prefix(8).map { String(format: "%02X", $0) }.joined(separator: ":")

        return Output(pem: pem,
                      keyDescription: "RSA 2048-bit, held in the app Keychain",
                      fingerprint: fingerprint)
    }
}

/// Tiny DER encoder â€” enough for a PKCS#10 request.
enum DER {
    static func length(_ value: Int) -> [UInt8] {
        if value < 0x80 { return [UInt8(value)] }
        var bytes: [UInt8] = []
        var remaining = value
        while remaining > 0 {
            bytes.insert(UInt8(remaining & 0xFF), at: 0)
            remaining >>= 8
        }
        return [0x80 | UInt8(bytes.count)] + bytes
    }

    static func tagged(_ tag: UInt8, _ content: [UInt8]) -> [UInt8] {
        [tag] + length(content.count) + content
    }

    static func sequence(_ items: [[UInt8]]) -> [UInt8] { tagged(0x30, items.flatMap { $0 }) }
    static func set(_ items: [[UInt8]]) -> [UInt8] { tagged(0x31, items.flatMap { $0 }) }
    static func octetString(_ bytes: [UInt8]) -> [UInt8] { tagged(0x04, bytes) }
    static func bitString(_ bytes: [UInt8]) -> [UInt8] { tagged(0x03, [0x00] + bytes) }
    static func oid(_ bytes: [UInt8]) -> [UInt8] { tagged(0x06, bytes) }
    static func utf8(_ string: String) -> [UInt8] { tagged(0x0C, Array(string.utf8)) }
    static func null() -> [UInt8] { [0x05, 0x00] }

    static func integer(_ value: Int) -> [UInt8] {
        var bytes: [UInt8] = []
        var remaining = value
        if remaining == 0 { bytes = [0] }
        while remaining > 0 {
            bytes.insert(UInt8(remaining & 0xFF), at: 0)
            remaining >>= 8
        }
        if let first = bytes.first, first & 0x80 != 0 { bytes.insert(0, at: 0) }
        return tagged(0x02, bytes)
    }
}

// MARK: - Certificate tab

struct CertificateView: View {
    var onClose: (() -> Void)? = nil

    @ObservedObject private var store = CertificateStore.shared

    @AppStorage("signingMethod") private var method = "install"
    @State private var password = ""
    @State private var showP12Picker = false
    @State private var showProfilePicker = false
    @State private var generated: CertificateFactory.Output?
    @State private var zipURL: URL?
    @State private var working = false

    private let methods: [(id: String, title: String, detail: String, icon: String)] = [
        ("install", "Just install", "Hands the IPA straight to iOS. Works with an already-signed build.", "arrow.down.circle.fill"),
        ("phone", "This iPhone (Apple ID)", "Uses the Apple ID this device is signed in with, the way a free sideload does.", "iphone.gen3"),
        ("certificate", "Certificate (.p12)", "Signs with your own certificate and provisioning profile.", "checkmark.seal.fill")
    ]

    var body: some View {
        ZStack {
            BlobBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    header
                    methodCard
                    if method == "certificate" { certificateCard }
                    if let info = store.info, method == "certificate" { profileCard(info) }
                    experimentalCard

                    Text("Voltex stores your details and reads your profile. It does not contain a code-signing engine, so it installs builds that are already signed.")
                        .font(.footnote)
                        .foregroundStyle(VoltexTheme.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 26)

                    Button {
                        if let onClose { onClose() }
                    } label: {
                        Text("Done")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(Capsule().fill(VoltexTheme.brandGradient))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 20)
                    .opacity(onClose == nil ? 0 : 1)
                    .disabled(onClose == nil)

                    Spacer(minLength: 120)
                }
                .padding(.top, 24)
            }
        }
        .onAppear { password = store.password }
        .fileImporter(isPresented: $showP12Picker, allowedContentTypes: [.data, .item]) { result in
            if case .success(let url) = result { store.importP12(url) }
        }
        .fileImporter(isPresented: $showProfilePicker, allowedContentTypes: [.data, .item]) { result in
            if case .success(let url) = result { store.importProfile(url) }
        }
    }

    // MARK: pieces

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 40))
                .foregroundStyle(VoltexTheme.brandGradient)

            Text("Certificate")
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundStyle(VoltexTheme.brandGradient)

            Text("Choose what Voltex signs with")
                .font(.subheadline)
                .foregroundStyle(VoltexTheme.secondary)
        }
    }

    private var methodCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(methods.enumerated()), id: \.offset) { index, option in
                Button {
                    method = option.id
                    ToastCenter.shared.show(option.title)
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: option.icon)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(VoltexTheme.brandGradient)
                            )

                        VStack(alignment: .leading, spacing: 2) {
                            Text(option.title)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white)
                            Text(option.detail)
                                .font(.system(size: 11))
                                .foregroundStyle(VoltexTheme.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer(minLength: 8)

                        if method == option.id {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(VoltexTheme.orange)
                        }
                    }
                    .padding(.vertical, 14)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if index < methods.count - 1 { divider }
            }
        }
        .padding(.horizontal, 16)
        .background(cardBackground)
        .overlay(cardBorder)
        .padding(.horizontal, 20)
    }

    private var certificateCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button { showP12Picker = true } label: {
                rowLabel(title: store.p12Name == nil ? "Import .p12" : ".p12 imported",
                         value: store.p12Name == nil ? "choose" : "replace",
                         subtitle: "Your signing certificate")
            }
            .buttonStyle(.plain)

            divider

            Button { showProfilePicker = true } label: {
                rowLabel(title: store.profileName == nil ? "Import .mobileprovision" : ".mobileprovision imported",
                         value: store.profileName == nil ? "choose" : "replace",
                         subtitle: "Your provisioning profile")
            }
            .buttonStyle(.plain)

            divider

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Password")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                    Text("For the .p12, kept in the Keychain")
                        .font(.system(size: 11))
                        .foregroundStyle(VoltexTheme.secondary)
                }
                Spacer(minLength: 12)
                SecureField("â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢", text: $password)
                    .multilineTextAlignment(.trailing)
                    .foregroundStyle(VoltexTheme.orange)
                    .frame(maxWidth: 150)
                    .onChange(of: password) { newValue in store.savePassword(newValue) }
            }
            .padding(.vertical, 14)

            if store.hasCertificate {
                divider
                Button { store.removeAll(); password = "" } label: {
                    Text("Remove certificate")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .background(cardBackground)
        .overlay(cardBorder)
        .padding(.horizontal, 20)
    }

    private func profileCard(_ info: CertificateStore.ProfileInfo) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("YOUR PROFILE")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .kerning(1.4)
                .foregroundStyle(VoltexTheme.orange)
                .padding(.bottom, 10)

            infoRow("Name", info.name)
            divider
            infoRow("Team", info.team)
            divider
            infoRow("App ID", info.appID)
            divider
            infoRow("Devices", "\(info.deviceCount)")
            divider
            infoRow("Expires", info.expires.map { Self.dateFormatter.string(from: $0) } ?? "unknown")
        }
        .padding(16)
        .background(cardBackground)
        .overlay(cardBorder)
        .padding(.horizontal, 20)
    }

    private var experimentalCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Text("CREATE CERTIFICATE")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .kerning(1.4)
                    .foregroundStyle(VoltexTheme.orange)

                Text("EXPERIMENTAL")
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .kerning(1)
                    .foregroundStyle(Color.black)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(VoltexTheme.orange))
            }

            Text("Makes an RSA-2048 key in the Keychain and a certificate request (CSR). Only Apple or a CA can turn that request into a real certificate â€” this just does your half.")
                .font(.system(size: 12))
                .foregroundStyle(VoltexTheme.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                working = true
                DispatchQueue.global(qos: .userInitiated).async {
                    let output = CertificateFactory.makeRequest(commonName: "Voltex \(DeviceInfo.modelName)")
                    let url = output.flatMap { Self.writeArchive($0) }
                    DispatchQueue.main.async {
                        working = false
                        generated = output
                        zipURL = url
                        ToastCenter.shared.show(output == nil ? "Couldn't generate" : "Certificate request created")
                    }
                }
            } label: {
                Text(working ? "Workingâ€¦" : "Generate key + certificate request")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(Color.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Capsule().fill(VoltexTheme.brandGradient))
            }
            .buttonStyle(.plain)
            .disabled(working)

            if let generated {
                divider
                infoRow("Key", generated.keyDescription)
                divider
                infoRow("Fingerprint", generated.fingerprint)

                Text(generated.pem)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(VoltexTheme.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.white.opacity(0.05))
                    )

                HStack(spacing: 10) {
                    Button {
                        UIPasteboard.general.string = generated.pem
                        ToastCenter.shared.show("Certificate request copied")
                    } label: {
                        Text("Copy")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Capsule().fill(VoltexTheme.orange))
                    }
                    .buttonStyle(.plain)

                    if let zipURL {
                        ShareLink(item: zipURL) {
                            Text("Download .zip")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Capsule().fill(VoltexTheme.orangeDeep))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(16)
        .background(cardBackground)
        .overlay(cardBorder)
        .padding(.horizontal, 20)
    }

    // MARK: helpers

    private var divider: some View {
        Rectangle().fill(VoltexTheme.hairline).frame(height: 1)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: VoltexTheme.corner, style: .continuous)
            .fill(VoltexTheme.card)
    }

    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: VoltexTheme.corner, style: .continuous)
            .stroke(VoltexTheme.hairline, lineWidth: 1)
    }

    private func rowLabel(title: String, value: String, subtitle: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundStyle(VoltexTheme.secondary)
            }
            Spacer(minLength: 12)
            Text(value)
                .font(.system(size: 14))
                .foregroundStyle(VoltexTheme.orange)
        }
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }

    private func infoRow(_ title: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white)
            Spacer(minLength: 12)
            Text(value)
                .font(.system(size: 13))
                .foregroundStyle(VoltexTheme.secondary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 12)
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }()

    /// Zips the generated request so it can be saved out of the app.
    private static func writeArchive(_ output: CertificateFactory.Output) -> URL? {
        let stamp = ISO8601DateFormatter().string(from: Date())
            .replacingOccurrences(of: ":", with: "-")

        let info = """
        Voltex — certificate request
        Generated: \(Date())
        Key: \(output.keyDescription)
        Fingerprint: \(output.fingerprint)
        """
        let readme = """
        HOW TO USE THIS
        1. Send certificate-request.csr to Apple (developer.apple.com) or a certificate authority.
        2. They return a signed certificate (.cer / .p12).
        3. Import that .p12 back into Voltex, along with a .mobileprovision.

        The private key that matches this request never leaves the device.
        """

        guard let data = ZipWriter.archive([
            ("certificate-request.csr", Data(output.pem.utf8)),
            ("info.txt", Data(info.utf8)),
            ("README.txt", Data(readme.utf8))
        ]) else { return nil }

        let folder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("CertificateExports", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)

        let url = folder.appendingPathComponent("voltex-certificate-\(stamp).zip")
        do {
            try data.write(to: url)
            return url
        } catch {
            return nil
        }
    }
}

// MARK: - Signing method (applies everywhere)

enum SigningMethod: String {
    case install
    case phone
    case certificate

    var title: String {
        switch self {
        case .install:     return "Just install"
        case .phone:       return "This iPhone (Apple ID)"
        case .certificate: return "Certificate (.p12)"
        }
    }
}

/// One place every Install button goes through, so the method chosen in the
/// Certificate tab applies to all of them.
enum InstallCoordinator {
    static let defaultManifest =
        "https://raw.githubusercontent.com/ysdf78297-cloud/voltex-/main/ipa/manifest.plist"

    static var method: SigningMethod {
        SigningMethod(rawValue: UserDefaults.standard.string(forKey: "signingMethod") ?? "install")
            ?? .install
    }

    static var manifestURL: String {
        let stored = UserDefaults.standard.string(forKey: "ipaManifestURL") ?? ""
        return stored.isEmpty ? defaultManifest : stored
    }

    /// Hands the manifest to iOS, which shows its own Install prompt.
    static func install(name: String, completion: @escaping (String) -> Void) {
        if method == .certificate && !CertificateStore.shared.hasCertificate {
            completion("No certificate yet — open the Certificate tab and import a .p12 and .mobileprovision.")
            return
        }

        guard let manifest = URL(string: manifestURL),
              let encoded = manifest.absoluteString
                .addingPercentEncoding(withAllowedCharacters: .alphanumerics),
              let installURL = URL(string: "itms-services://?action=download-manifest&url=\(encoded)") else {
            completion("The install source isn't a valid link.")
            return
        }

        UIApplication.shared.open(installURL, options: [:]) { ok in
            DispatchQueue.main.async {
                completion(ok
                    ? "Installing \(name) using \(method.title). If iOS ends with \u{201C}Unable to Install\u{201D}, the IPA isn't signed for this device."
                    : "iOS refused the installer.")
            }
        }
    }
}
