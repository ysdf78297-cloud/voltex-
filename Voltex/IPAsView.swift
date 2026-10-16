import SwiftUI

/// Landing tab: the animated Voltex hero, the IPA list (empty for now),
/// and the "Open any app, not IPA" launcher.
struct IPAsView: View {
    @State private var showLauncher = false

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

                    emptyState
                        .padding(.top, 4)

                    launcherCard

                    Text("Voltex")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .kerning(3)
                        .foregroundStyle(VoltexTheme.secondary)
                        .padding(.top, 24)
                        .padding(.bottom, 40)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .sheet(isPresented: $showLauncher) {
            AppLauncherView()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "tray")
                .font(.system(size: 46, weight: .light))
                .foregroundStyle(VoltexTheme.orange.opacity(0.85))

            Text("None here yet")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("IPA's you add will show up here.")
                .font(.footnote)
                .foregroundStyle(VoltexTheme.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 34)
        .padding(.horizontal, 22)
        .background(cardBackground)
        .padding(.horizontal, 20)
    }

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
        .background(cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: VoltexTheme.corner, style: .continuous)
                .stroke(VoltexTheme.orange.opacity(0.35), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: VoltexTheme.corner, style: .continuous)
            .fill(VoltexTheme.card)
    }
}

#Preview {
    IPAsView().preferredColorScheme(.dark)
}
