import SwiftUI
import UIKit

/// The Voltex background, done natively (no HTML): a drifting orange "nebula"
/// over black, plus a constellation network of stars that link up when close —
/// the same look as the website, rebuilt with SwiftUI Canvas.
struct BlobBackground: View {
    @AppStorage("animationsEnabled") private var animationsEnabled = true
    @State private var stars: [Star] = Star.make(count: 48)
    @State private var started = Date()

    var body: some View {
        GeometryReader { geo in
            ZStack {
                VoltexTheme.black

                if animationsEnabled {
                    TimelineView(.animation) { timeline in
                        layers(t: timeline.date.timeIntervalSince(started), size: geo.size)
                    }
                } else {
                    layers(t: 2, size: geo.size)
                }

                vignette
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private var vignette: some View {
        LinearGradient(
            colors: [Color.black.opacity(0.28), .clear, Color.black.opacity(0.55)],
            startPoint: .top, endPoint: .bottom
        )
    }

    @ViewBuilder
    private func layers(t: TimeInterval, size: CGSize) -> some View {
        ZStack {
            blobs(t: t, size: size)
            starfield(t: t)
        }
    }

    // MARK: - nebula blobs

    @ViewBuilder
    private func blobs(t: TimeInterval, size: CGSize) -> some View {
        let base = max(size.width, size.height)
        ZStack {
            blob(t: t, unit: CGPoint(x: 0.24, y: 0.16), amp: 0.055, speed: 0.11, phase: 0.0,
                 size: base, scale: 1.10, opacity: 0.55, in: size)
            blob(t: t, unit: CGPoint(x: 0.82, y: 0.28), amp: 0.065, speed: 0.09, phase: 1.7,
                 size: base, scale: 0.90, opacity: 0.45, in: size)
            blob(t: t, unit: CGPoint(x: 0.50, y: 0.80), amp: 0.050, speed: 0.13, phase: 3.1,
                 size: base, scale: 1.20, opacity: 0.40, in: size)
            blob(t: t, unit: CGPoint(x: 0.10, y: 0.88), amp: 0.045, speed: 0.10, phase: 4.4,
                 size: base, scale: 0.75, opacity: 0.30, in: size)
            blob(t: t, unit: CGPoint(x: 0.62, y: 0.52), amp: 0.040, speed: 0.15, phase: 5.6,
                 size: base, scale: 0.60, opacity: 0.22, tint: VoltexTheme.purple, in: size)
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
            .position(x: (unit.x + dx) * size.width, y: (unit.y + dy) * size.height)
    }

    // MARK: - constellation starfield

    private func starfield(t: TimeInterval) -> some View {
        Canvas { context, canvasSize in
            guard canvasSize.width > 1, canvasSize.height > 1 else { return }

            var points = [CGPoint]()
            points.reserveCapacity(stars.count)

            for star in stars {
                let nx = wrap(star.x + star.vx * CGFloat(t))
                let ny = wrap(star.y + star.vy * CGFloat(t))
                let p = CGPoint(x: nx * canvasSize.width, y: ny * canvasSize.height)
                points.append(p)

                let twinkle = 0.5 + 0.5 * sin(t * star.speed + star.phase)
                let alpha = 0.22 + twinkle * 0.55
                let r = star.radius
                context.fill(
                    Path(ellipseIn: CGRect(x: p.x - r, y: p.y - r, width: r * 2, height: r * 2)),
                    with: .color(VoltexTheme.star.opacity(alpha))
                )
            }

            let linkDistance: CGFloat = 120
            let linkSq = linkDistance * linkDistance
            for i in 0..<points.count {
                var j = i + 1
                while j < points.count {
                    let dx = points[i].x - points[j].x
                    let dy = points[i].y - points[j].y
                    let dSq = dx * dx + dy * dy
                    if dSq < linkSq {
                        let d = dSq.squareRoot()
                        let strength = CGFloat(0.16) * (1 - d / linkDistance)
                        var path = Path()
                        path.move(to: points[i])
                        path.addLine(to: points[j])
                        context.stroke(
                            path,
                            with: .color(VoltexTheme.orange.opacity(Double(strength))),
                            lineWidth: 1
                        )
                    }
                    j += 1
                }
            }
        }
    }

    private func wrap(_ value: CGFloat) -> CGFloat {
        value - floor(value)
    }
}

/// A single drifting star. Positions are normalised (0...1) so they scale to any screen.
struct Star {
    var x: CGFloat
    var y: CGFloat
    var vx: CGFloat
    var vy: CGFloat
    var radius: CGFloat
    var phase: Double
    var speed: Double

    static func make(count: Int) -> [Star] {
        (0..<count).map { _ in
            let angle = Double.random(in: 0..<(2 * .pi))
            let drift = CGFloat.random(in: 0.003...0.010)
            return Star(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1),
                vx: CGFloat(cos(angle)) * drift,
                vy: CGFloat(sin(angle)) * drift,
                radius: CGFloat.random(in: 0.7...1.9),
                phase: Double.random(in: 0..<(2 * .pi)),
                speed: Double.random(in: 0.4...1.1)
            )
        }
    }
}

// MARK: - click shockwaves

/// Broadcasts an expanding ring wherever the screen is tapped, like the website.
final class ShockwaveCenter: ObservableObject {
    static let shared = ShockwaveCenter()

    struct Wave: Identifiable {
        let id = UUID()
        let position: CGPoint
    }

    @Published private(set) var waves: [Wave] = []

    func spawn(at point: CGPoint) {
        let wave = Wave(position: point)
        waves.append(wave)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) { [weak self] in
            self?.waves.removeAll { $0.id == wave.id }
        }
    }
}

struct ShockwaveOverlay: View {
    @ObservedObject private var center = ShockwaveCenter.shared

    var body: some View {
        GeometryReader { geo in
            let origin = geo.frame(in: .global).origin
            ZStack {
                ForEach(center.waves) { wave in
                    ShockwaveRing(
                        position: CGPoint(x: wave.position.x - origin.x,
                                          y: wave.position.y - origin.y)
                    )
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}

/// Watches taps on the whole window without stealing them from the UI,
/// so shockwaves fire everywhere while the tab bar and buttons still work.
struct WindowTapCatcher: UIViewRepresentable {
    var onTap: (CGPoint) -> Void

    func makeUIView(context: Context) -> TapView {
        let view = TapView()
        view.isUserInteractionEnabled = false
        view.onTap = onTap
        return view
    }

    func updateUIView(_ uiView: TapView, context: Context) {
        uiView.onTap = onTap
    }

    final class TapView: UIView, UIGestureRecognizerDelegate {
        var onTap: ((CGPoint) -> Void)?
        private var installed = false

        override func didMoveToWindow() {
            super.didMoveToWindow()
            guard let window, !installed else { return }
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            recognizer.cancelsTouchesInView = false
            recognizer.delegate = self
            window.addGestureRecognizer(recognizer)
            installed = true
        }

        @objc private func handleTap(_ recognizer: UITapGestureRecognizer) {
            guard let window else { return }
            onTap?(recognizer.location(in: window))
        }

        func gestureRecognizer(_ gesture: UIGestureRecognizer,
                               shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool {
            true
        }
    }
}

private struct ShockwaveRing: View {
    let position: CGPoint
    @State private var expanded = false

    var body: some View {
        Circle()
            .stroke(VoltexTheme.orange.opacity(expanded ? 0 : 0.85),
                    lineWidth: expanded ? 1 : 3)
            .background(
                Circle().fill(
                    RadialGradient(colors: [VoltexTheme.orange.opacity(expanded ? 0 : 0.20), .clear],
                                   center: .center, startRadius: 0, endRadius: 60)
                )
            )
            .frame(width: expanded ? 520 : 8, height: expanded ? 520 : 8)
            .position(position)
            .onAppear {
                withAnimation(.easeOut(duration: 0.75)) { expanded = true }
            }
    }
}
