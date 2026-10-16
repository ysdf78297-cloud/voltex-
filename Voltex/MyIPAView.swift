import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct SideloadedIPA: Identifiable, Codable {
    let id: String
    var name: String
    var fileName: String
    var iconFileName: String?
    var sizeBytes: Int
    var bundleID: String?
    var version: String?
    var date: Date
}

/// Caches decoded icons so scrolling doesn't re-read from disk.
final class IPAImageCache {
    static let shared = IPAImageCache()
    private var store: [String: UIImage] = [:]
    private let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

    func image(named name: String) -> UIImage? {
        if let cached = store[name] { return cached }
        guard let image = UIImage(contentsOfFile: docs.appendingPathComponent(name).path) else { return nil }
        store[name] = image
        return image
    }

    func forget(_ name: String) { store.removeValue(forKey: name) }
}

/// "Your IPA" â€” pick an .ipa off your phone and Voltex pulls it in here.
struct MyIPAView: View {
    @State private var showPicker = false
    @State private var items: [SideloadedIPA] = []
    @State private var busyName: String?
    @State private var busyProgress: Double = 0
    @State private var pendingDelete: SideloadedIPA?
    @State private var pendingInstall: SideloadedIPA?
    @State private var installNotice: String?
    @State private var showCertificates = false

    @AppStorage("ipaManifestURL") private var manifestURL =
        "https://raw.githubusercontent.com/ysdf78297-cloud/voltex-/main/ipa/manifest.plist"

    private let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

    var body: some View {
        ZStack {
            BlobBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    header
                    chooserCard
                        .sheet(isPresented: $showCertificates) {
                            CertificateView(onClose: { showCertificates = false })
                        }

                    if let busyName {
                        busyCard(busyName)
                    }

                    if items.isEmpty {
                        emptyState
                    } else {
                        VStack(spacing: 14) {
                            ForEach(items) { item in
                                itemCard(item)
                            }
                        }
                        .confirmationDialog("Install \(pendingInstall?.name ?? "")?",
                                            isPresented: installOptionsBinding,
                                            titleVisibility: .visible) {
                            Button("Install") {
                                if let item = pendingInstall { install(item, withCertificate: false) }
                                pendingInstall = nil
                            }
                            Button("Install with certificate") {
                                if let item = pendingInstall { install(item, withCertificate: true) }
                                pendingInstall = nil
                            }
                            Button("Cancel", role: .cancel) { pendingInstall = nil }
                        } message: {
                            Text("Install hands the IPA to iOS. Install with certificate uses the signing identity you imported.")
                        }
                    }

                    Spacer(minLength: 120)
                }
                .padding(.top, 24)
            }
        }
        .fileImporter(isPresented: $showPicker,
                      allowedContentTypes: allowedTypes,
                      allowsMultipleSelection: false) { result in
            handlePick(result)
        }
        .alert("Uninstall \(pendingDelete?.name ?? "")?", isPresented: deleteBinding) {
            Button("Uninstall", role: .destructive) { uninstall() }
            Button("Keep") { pendingDelete = nil }
        } message: {
            Text("Removes it from Voltex.")
        }
        .alert("Install", isPresented: noticeBinding) {
            Button("OK") { installNotice = nil }
        } message: {
            Text(installNotice ?? "")
        }
        .onAppear(perform: load)
    }

    private var allowedTypes: [UTType] {
        var types: [UTType] = [.data, .item]
        if let ipa = UTType(filenameExtension: "ipa") { types.insert(ipa, at: 0) }
        return types
    }

    private var deleteBinding: Binding<Bool> {
        Binding(get: { pendingDelete != nil }, set: { if !$0 { pendingDelete = nil } })
    }

    private var installOptionsBinding: Binding<Bool> {
        Binding(get: { pendingInstall != nil }, set: { if !$0 { pendingInstall = nil } })
    }

    private var noticeBinding: Binding<Bool> {
        Binding(get: { installNotice != nil }, set: { if !$0 { installNotice = nil } })
    }

    private func install(_ item: SideloadedIPA, withCertificate: Bool) {
        if withCertificate {
            guard CertificateStore.shared.hasCertificate else {
                showCertificates = true
                installNotice = "Add a .p12 and a .mobileprovision first, then try again."
                return
            }
            installNotice = "Certificate ready (\(CertificateStore.shared.info?.name ?? "imported")). Voltex can't re-sign an IPA â€” sign it with ESign or Sideloadly, host the signed build, then Install will take it."
            return
        }

        let trimmed = manifestURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              let manifest = URL(string: trimmed),
              let encoded = manifest.absoluteString
                .addingPercentEncoding(withAllowedCharacters: .alphanumerics),
              let installURL = URL(string: "itms-services://?action=download-manifest&url=\(encoded)") else {
            installNotice = "No install source is set. Add one on the IPA's tab."
            return
        }

        UIApplication.shared.open(installURL, options: [:]) { ok in
            DispatchQueue.main.async {
                installNotice = ok
                    ? "Handed to iOS. If it ends with \u{201C}Unable to Install\u{201D}, the IPA isn't signed."
                    : "iOS refused the installer."
            }
        }
    }

    // MARK: - pieces

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "shippingbox.fill")
                .font(.system(size: 40))
                .foregroundStyle(VoltexTheme.brandGradient)

            Text("Your IPA")
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundStyle(VoltexTheme.brandGradient)

            Text("Put your IPA in here")
                .font(.subheadline)
                .foregroundStyle(VoltexTheme.secondary)
        }
    }

    private var chooserCard: some View {
        VStack(spacing: 14) {
            Image(systemName: "doc.badge.plus")
                .font(.system(size: 34))
                .foregroundStyle(VoltexTheme.orange)

            Text("Pick an .ipa from Files and Voltex will pull it in, read its name and icon, and keep it here.")
                .font(.footnote)
                .foregroundStyle(VoltexTheme.secondary)
                .multilineTextAlignment(.center)

            Button {
                showPicker = true
            } label: {
                Text("Choose file")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(Color.black)
                    .padding(.horizontal, 26)
                    .padding(.vertical, 12)
                    .background(Capsule().fill(VoltexTheme.brandGradient))
            }
            .buttonStyle(.plain)
            .disabled(busyName != nil)
            .opacity(busyName == nil ? 1 : 0.5)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 26)
        .padding(.horizontal, 22)
        .background(
            RoundedRectangle(cornerRadius: VoltexTheme.corner, style: .continuous)
                .fill(VoltexTheme.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: VoltexTheme.corner, style: .continuous)
                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6, 5]))
                .foregroundStyle(VoltexTheme.orange.opacity(0.5))
        )
        .padding(.horizontal, 20)
    }

    private func busyCard(_ name: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Side-loading \(name)")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            ProgressView(value: busyProgress)
                .tint(VoltexTheme.orange)

            Text("\(Int(busyProgress * 100))%")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(VoltexTheme.orange)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: VoltexTheme.corner, style: .continuous)
                .fill(VoltexTheme.card)
        )
        .padding(.horizontal, 20)
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "tray")
                .font(.system(size: 36, weight: .light))
                .foregroundStyle(VoltexTheme.orange.opacity(0.8))
            Text("Nothing here yet")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text("IPAs you add show up here, and you can remove them any time.")
                .font(.footnote)
                .foregroundStyle(VoltexTheme.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 26)
        .padding(.horizontal, 22)
        .background(
            RoundedRectangle(cornerRadius: VoltexTheme.corner, style: .continuous)
                .fill(VoltexTheme.card)
        )
        .padding(.horizontal, 20)
    }

    private func itemCard(_ item: SideloadedIPA) -> some View {
        HStack(spacing: 14) {
            Group {
                if let iconName = item.iconFileName, let image = IPAImageCache.shared.image(named: iconName) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    ZStack {
                        VoltexTheme.brandGradient
                        Image(systemName: "shippingbox.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(.white)
                    }
                }
            }
            .frame(width: 58, height: 58)
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .stroke(VoltexTheme.orange.opacity(0.4), lineWidth: 1)
            )

            VStack(alignment: .leading, spacing: 3) {
                Text(item.name)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text(subtitle(for: item))
                    .font(.system(size: 11))
                    .foregroundStyle(VoltexTheme.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text("Sideloaded")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(VoltexTheme.orange)
            }

            Spacer(minLength: 8)

            VStack(spacing: 8) {
                Button {
                    pendingInstall = item
                } label: {
                    Text("Install")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .foregroundStyle(Color.black)
                        .frame(width: 92)
                        .padding(.vertical, 9)
                        .background(Capsule().fill(VoltexTheme.brandGradient))
                }
                .buttonStyle(.plain)

                Button {
                    pendingDelete = item
                } label: {
                    Text("Uninstall")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .foregroundStyle(.white)
                        .frame(width: 92)
                        .padding(.vertical, 9)
                        .background(Capsule().fill(Color.red.opacity(0.85)))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: VoltexTheme.corner, style: .continuous)
                .fill(VoltexTheme.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: VoltexTheme.corner, style: .continuous)
                .stroke(VoltexTheme.hairline, lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }

    private func subtitle(for item: SideloadedIPA) -> String {
        var parts: [String] = []
        if let version = item.version { parts.append("v\(version)") }
        parts.append(ByteCountFormatter.string(fromByteCount: Int64(item.sizeBytes), countStyle: .file))
        if let bundleID = item.bundleID { parts.append(bundleID) }
        return parts.joined(separator: " Â· ")
    }

    // MARK: - picking

    private func handlePick(_ result: Result<[URL], Error>) {
        switch result {
        case .failure:
            ToastCenter.shared.show("Couldn't open the picker")
        case .success(let urls):
            guard let url = urls.first else { return }
            importIPA(url)
        }
    }

    private func importIPA(_ url: URL) {
        let fileName = url.lastPathComponent
        guard fileName.lowercased().hasSuffix(".ipa") else {
            ToastCenter.shared.show("That isn't an .ipa file")
            return
        }

        let scoped = url.startAccessingSecurityScopedResource()
        busyName = fileName
        busyProgress = 0

        DispatchQueue.global(qos: .userInitiated).async {
            let destination = docs.appendingPathComponent(fileName)
            try? FileManager.default.removeItem(at: destination)

            var total = 1
            if let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
               let size = attributes[.size] as? Int, size > 0 {
                total = size
            }

            var copied = 0
            var ok = false
            FileManager.default.createFile(atPath: destination.path, contents: nil)

            if let input = try? FileHandle(forReadingFrom: url),
               let output = try? FileHandle(forWritingTo: destination) {
                ok = true
                while true {
                    let chunk = (try? input.read(upToCount: 1 << 20)) ?? nil
                    guard let chunk, !chunk.isEmpty else { break }
                    do { try output.write(contentsOf: chunk) } catch { ok = false; break }
                    copied += chunk.count
                    let fraction = min(0.95, Double(copied) / Double(total))
                    DispatchQueue.main.async { busyProgress = fraction }
                }
                try? input.close()
                try? output.close()
            }

            if scoped { url.stopAccessingSecurityScopedResource() }

            guard ok else {
                try? FileManager.default.removeItem(at: destination)
                DispatchQueue.main.async {
                    busyName = nil
                    busyProgress = 0
                    ToastCenter.shared.show("Couldn't read that file")
                }
                return
            }

            let info = IPAReader.inspect(destination)

            var iconFileName: String?
            if let icon = info.icon, let png = icon.pngData() {
                let name = "ipa-icon-\(UUID().uuidString).png"
                if (try? png.write(to: docs.appendingPathComponent(name))) != nil {
                    iconFileName = name
                }
            }

            let attributes = try? FileManager.default.attributesOfItem(atPath: destination.path)
            let sizeBytes = (attributes?[.size] as? Int) ?? 0

            let item = SideloadedIPA(id: UUID().uuidString,
                                     name: info.name ?? fileName.replacingOccurrences(of: ".ipa", with: ""),
                                     fileName: fileName,
                                     iconFileName: iconFileName,
                                     sizeBytes: sizeBytes,
                                     bundleID: info.bundleID,
                                     version: info.version,
                                     date: Date())

            DispatchQueue.main.async {
                items.insert(item, at: 0)
                save()
                busyName = nil
                busyProgress = 0
                ToastCenter.shared.show("\(item.name) is ready")
            }
        }
    }

    private func uninstall() {
        guard let item = pendingDelete else { return }

        try? FileManager.default.removeItem(at: docs.appendingPathComponent(item.fileName))
        if let iconName = item.iconFileName {
            try? FileManager.default.removeItem(at: docs.appendingPathComponent(iconName))
            IPAImageCache.shared.forget(iconName)
        }

        items.removeAll { $0.id == item.id }
        save()
        ToastCenter.shared.show("\(item.name) uninstalled")
        pendingDelete = nil
    }

    // MARK: - storage

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: "voltexSideloadedIPAs"),
              let list = try? JSONDecoder().decode([SideloadedIPA].self, from: data) else { return }
        items = list
    }

    private func save() {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: "voltexSideloadedIPAs")
        }
    }
}

#Preview {
    MyIPAView().preferredColorScheme(.dark)
}
