import SwiftUI

/// Landing tab: the animated Voltex hero, then the IPA list (empty for now).
struct IPAsView: View {
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
}

#Preview {
    IPAsView().preferredColorScheme(.dark)
}
