import SwiftUI

struct AboutView: View {
    @AppStorage("animationsEnabled") private var animationsEnabled = true
    @State private var pulse = false

    var body: some View {
        ZStack {
            BlobBackground()

            VStack(spacing: 20) {
                Spacer()

                Image("VoltexLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 96, height: 96)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .shadow(color: VoltexTheme.orange.opacity(0.5), radius: 20, y: 10)

                Text("Soon")
                    .font(.system(size: 52, weight: .black, design: .rounded))
                    .foregroundStyle(VoltexTheme.brandGradient)
                    .scaleEffect(pulse ? 1.04 : 0.98)

                Text("More about Voltex is on the way.")
                    .font(.footnote)
                    .foregroundStyle(VoltexTheme.secondary)

                Spacer()
            }
            .padding()
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
