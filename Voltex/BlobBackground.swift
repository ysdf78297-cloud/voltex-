import SwiftUI

/// Orange "blobs" drifting slowly over a black background.
/// Freezes into a still frame when the Animations setting is off.
struct BlobBackground: View {
    @AppStorage("animationsEnabled") private var animationsEnabled = true

    var body: some View {
        Group {
            if animationsEnabled {
                TimelineView(.animation) { timeline in
                    canvas(time: timeline.date.timeIntervalSinceReferenceDate)
                }
            } else {
                canvas(time: 0)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private func canvas(time t: TimeInterval) -> some View {
        GeometryReader { geo in
            let base = max(geo.size.width, geo.size.height)
            ZStack {
                VoltexTheme.black

                blob(t: t, unit: CGPoint(x: 0.24, y: 0.16), amp: 0.055, speed: 0.11, phase: 0.0,
                     size: base, scale: 1.10, opacity: 0.55, in: geo.size)
                blob(t: t, unit: CGPoint(x: 0.82, y: 0.28), amp: 0.065, speed: 0.09, phase: 1.7,
                     size: base, scale: 0.90, opacity: 0.45, in: geo.size)
                blob(t: t, unit: CGPoint(x: 0.50, y: 0.80), amp: 0.050, speed: 0.13, phase: 3.1,
                     size: base, scale: 1.20, opacity: 0.40, in: geo.size)
                blob(t: t, unit: CGPoint(x: 0.10, y: 0.88), amp: 0.045, speed: 0.10, phase: 4.4,
                     size: base, scale: 0.75, opacity: 0.30, in: geo.size)
                blob(t: t, unit: CGPoint(x: 0.62, y: 0.52), amp: 0.040, speed: 0.15, phase: 5.6,
                     size: base, scale: 0.60, opacity: 0.22, tint: VoltexTheme.purple, in: geo.size)

                LinearGradient(
                    colors: [Color.black.opacity(0.30), .clear, Color.black.opacity(0.60)],
                    startPoint: .top, endPoint: .bottom
                )
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    private func blob(t: TimeInterval,
                      unit: CGPoint,
                      amp: Double,
                      speed: Double,
                      phase: Double,
                      size base: CGFloat,
                      scale: CGFloat,
                      opacity: Double,
                      tint: Color = VoltexTheme.orange,
                      in size: CGSize) -> some View {
        let dx = CGFloat(cos(t * speed + phase) * amp)
        let dy = CGFloat(sin(t * speed * 1.27 + phase) * amp)
        let diameter = base * scale

        return Circle()
            .fill(
                RadialGradient(
                    colors: [tint.opacity(opacity), tint.opacity(opacity * 0.35), .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: diameter / 2
                )
            )
            .frame(width: diameter, height: diameter)
            .blur(radius: 36)
            .position(x: (unit.x + dx) * size.width,
                      y: (unit.y + dy) * size.height)
    }
}
