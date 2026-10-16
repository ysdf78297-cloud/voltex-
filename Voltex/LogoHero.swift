import SwiftUI

/// The logo + the "Voltex" wordmark, which types itself in letter by letter.
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

            LetterWordmark(text: "Voltex")
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

/// Renders each letter of the word with its own pop-in, then breathes gently.
/// The orange -> purple gradient spans the whole word.
struct LetterWordmark: View {
    let text: String

    @AppStorage("animationsEnabled") private var animationsEnabled = true
    @State private var revealed = 0
    @State private var breathe = false

    private var letters: [Character] { Array(text) }
    private var wordFont: Font { .system(size: 62, weight: .black, design: .rounded) }

    var body: some View {
        letterRow
            .overlay(VoltexTheme.brandGradient)
            .mask(letterRow)
            .scaleEffect(breathe ? 1.03 : 1.0)
            .shadow(color: VoltexTheme.purple.opacity(0.32), radius: 16, y: 5)
            .onAppear(perform: run)
            .onChange(of: animationsEnabled) { _ in run() }
    }

    private var letterRow: some View {
        HStack(spacing: 2) {
            ForEach(Array(letters.enumerated()), id: \.offset) { index, letter in
                Text(String(letter))
                    .font(wordFont)
                    .kerning(2)
                    .opacity(index < revealed ? 1 : 0)
                    .scaleEffect(index < revealed ? 1 : 0.35, anchor: .bottom)
                    .offset(y: index < revealed ? 0 : 24)
            }
        }
    }

    private func run() {
        breathe = false

        guard animationsEnabled else {
            revealed = letters.count
            return
        }

        revealed = 0
        for index in letters.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.16 * Double(index) + 0.12) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.55)) {
                    revealed = max(revealed, index + 1)
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16 * Double(letters.count) + 0.45) {
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                breathe = true
            }
        }
    }
}
