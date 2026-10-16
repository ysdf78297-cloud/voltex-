import SwiftUI

struct IPAPackage: Identifiable {
    let id: String
    let name: String
    let subtitle: String
    let icon: String
}

/// Landing tab: the animated hero, your IPA library, and the "Open any app" launcher.
struct IPAsView: View {
    @State private var showLauncher = false

    @State private var installing: String?
    @State private var progress: Double = 0
    @State private var installed: Set<String> = []
    @State private var pendingDelete: IPAPackage?

    private let packages: [IPAPackage] = [
        IPAPackage(id: "charlie",
                   name: "Charlie, the Steak",
                   subtitle: "v1.2 (495) · 64-bit · this is the IPA",
                   icon: "SteakIcon")
    ]

    var body: some View {
        ZStack {
            BlobBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 26) {
                    LogoHero()
                        .padding(.top, 48)
                        .padding(.bottom, 8)

                    Text("This is a test of the IPA")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(VoltexTheme.orange)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    Rectangle()
                        .fill(VoltexTheme.brandGradient)
                        .frame(width: 90, height: 3)
                        .clipShape(Capsule())

                    VStack(spacing: 14) {
                        ForEach(packages) { package in
                            packageCard(package)
                        }
                    }

                    launcherCard

                    Text("Voltex")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .kerning(3)
                        .foregroundStyle(VoltexTheme.secondary)
                        .padding(.top, 10)
                        .padding(.bottom, 140)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .sheet(isPresented: $showLauncher) {
            AppLauncherView()
        }
        .alert("Are you sure?", isPresented: deleteConfirmBinding) {
            Button("No", role: .cancel) { pendingDelete = nil }
            Button("Yes", role: .destructive) { confirmDelete() }
        } message: {
            Text("This will delete the app from your phone.")
        }
    }

    private var deleteConfirmBinding: Binding<Bool> {
        Binding(
            get: { pendingDelete != nil },
            set: { if !$0 { pendingDelete = nil } }
        )
    }

    // MARK: - IPA card

    private func packageCard(_ package: IPAPackage) -> some View {
        let isInstalled = installed.contains(package.id)
        let isInstalling = installing == package.id

        return VStack(spacing: 14) {
            HStack(spacing: 14) {
                Image(package.icon)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .stroke(VoltexTheme.orange.opacity(0.4), lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: 3) {
                    Text(package.name)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text(package.subtitle)
                        .font(.footnote)
                        .foregroundStyle(VoltexTheme.secondary)
                        .lineLimit(2)

                    if isInstalled {
                        Text("Installed")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color.red)
                    }
                }

                Spacer(minLength: 8)

                trailingControl(package, isInstalled: isInstalled, isInstalling: isInstalling)
            }

            if isInstalled {
                Button {
                    pendingDelete = package
                } label: {
                    Text("Click me to delete the app")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
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

    @ViewBuilder
    private func trailingControl(_ package: IPAPackage, isInstalled: Bool, isInstalling: Bool) -> some View {
        if isInstalling {
            VStack(spacing: 6) {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(VoltexTheme.orange)
                ProgressView(value: progress)
                    .tint(VoltexTheme.orange)
                    .frame(width: 74)
            }
        } else if isInstalled {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 22))
                .foregroundStyle(Color.red)
        } else {
            Button {
                startInstall(package)
            } label: {
                Text("Download")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.black)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(VoltexTheme.brandGradient))
            }
            .buttonStyle(.plain)
        }
    }

    private func startInstall(_ package: IPAPackage) {
        guard installing == nil else { return }
        installing = package.id
        progress = 0

        Task { @MainActor in
            while progress < 1 {
                try? await Task.sleep(nanoseconds: 120_000_000)
                progress = min(1, progress + Double.random(in: 0.012...0.05))
            }
            installed.insert(package.id)
            installing = nil
            ToastCenter.shared.show("\(package.name) installed")
        }
    }

    private func confirmDelete() {
        guard let package = pendingDelete else { return }
        installed.remove(package.id)
        pendingDelete = nil
        ToastCenter.shared.show("\(package.name) deleted")
    }

    // MARK: - launcher card

    private var launcherCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "bolt.horizontal.circle.fill")
                .font(.system(size: 42))
                .foregroundStyle(VoltexTheme.brandGradient)

            Text("Open any app, not IPA")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text("Secret apps you normally can't reach — jump straight in.")
                .font(.footnote)
                .foregroundStyle(VoltexTheme.secondary)
                .multilineTextAlignment(.center)

            Button {
                showLauncher = true
            } label: {
                Text("View")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.black)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 11)
                    .background(VoltexTheme.brandGradient)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .padding(.horizontal, 22)
        .background(
            RoundedRectangle(cornerRadius: VoltexTheme.corner, style: .continuous)
                .fill(VoltexTheme.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: VoltexTheme.corner, style: .continuous)
                .stroke(VoltexTheme.orange.opacity(0.35), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
}

#Preview {
    IPAsView().preferredColorScheme(.dark)
}
