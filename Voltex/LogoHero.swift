import SwiftUI

/// The logo + animated "Voltex" wordmark, orange with a purple shine.
struct LogoHero: View {
    @AppStorage("animationsEnabled") private var animationsEnabled = true

    @State private var floatUp = false
    @State private var glow = false

    var body: some View {
        VStack(spacing: 22) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [VoltexTheme.orange.opacity(0.60), .clear],
                            center: .center, startRadius: 4, endRadius: 130
                        )
                    )
                    .frame(width: 260, height: 260)
                    .scaleEffect(glow ? 1.10 : 0.90)
                    .blur(radius: 20)

                Image("VoltexLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 128, height: 128)
                    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .stroke(VoltexTheme.orange.opacity(0.45), lineWidth: 1)
                    )
                    .shadow(color: VoltexTheme.orange.opacity(0.55), radius: 26, y: 12)
            }
            .offset(y: floatUp ? -8 : 8)

            ShimmerTitle(text: "Voltex")
        }
        .onAppear(perform: start)
        .onChange(of: animationsEnabled) { _ in start() }
    }

    private func start() {
        guard animationsEnabled else {
            floatUp = false
            glow = false
            return
        }
        withAnimation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true)) { floatUp = true }
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) { glow = true }
    }
}

/// Gradient wordmark with a light sweeping across it.
struct ShimmerTitle: View {
    let text: String
    @AppStorage("animationsEnabled") private var animationsEnabled = true
    @State private var sweep: CGFloat = -1.2

    private var font: Font { .system(size: 62, weight: .black, design: .rounded) }

    var body: some View {
        Text(text)
            .font(font)
            .kerning(2)
            .foregroundStyle(VoltexTheme.brandGradient)
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.95), .clear],
                        startPoint: .leading, endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 0.40)
                    .rotationEffect(.degrees(16))
                    .offset(x: sweep * geo.size.width * 1.9)
                    .blendMode(.plusLighter)
                    .mask(Text(text).font(font).kerning(2))
                    .opacity(animationsEnabled ? 1 : 0)
                }
            )
            .shadow(color: VoltexTheme.purple.opacity(0.35), radius: 16, y: 5)
            .onAppear(perform: start)
            .onChange(of: animationsEnabled) { _ in start() }
    }

    private func start() {
        guard animationsEnabled else { sweep = -1.2; return }
        sweep = -1.2
        withAnimation(.linear(duration: 2.4).repeatForever(autoreverses: false)) { sweep = 1.4 }
    }
}
