import SwiftUI

struct AboutView: View {
    @AppStorage("animationsEnabled") private var animationsEnabled = true
    @State private var pulse = false

    var body: some View {
        ZStack {
            BlobBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    Image("VoltexLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 96, height: 96)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .shadow(color: VoltexTheme.orange.opacity(0.5), radius: 20, y: 10)
                        .padding(.top, 56)

                    LetterWordmark(text: "Voltex")
                        .scaleEffect(0.72)
                        .frame(height: 52)

                    Text("Soon")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(VoltexTheme.orange)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(
                            Capsule().fill(VoltexTheme.orange.opacity(0.14))
                        )
                        .scaleEffect(pulse ? 1.04 : 0.98)

                    VStack(spacing: 16) {
                        Text("Here is where you find IPA's. Instead of Sideloadly always being stupid and never working — we're here to save the day.")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)

                        Rectangle()
                            .fill(VoltexTheme.brandGradient)
                            .frame(width: 70, height: 2)
                            .clipShape(Capsule())

                        Text("© Voltex — built by the community, for the community.")
                            .font(.footnote)
                            .foregroundStyle(VoltexTheme.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 26)
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

                    Spacer(minLength: 40)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear {
            guard animationsEnabled else { return }
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) { pulse = true }
        }
    }
}

#Preview {
    AboutView().preferredColorScheme(.dark)
}
