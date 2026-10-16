import SwiftUI

/// Voltex palette: orange + black, with purple as the accent.
enum VoltexTheme {
    static let orange     = Color(red: 1.000, green: 0.498, blue: 0.141) // #FF7F24
    static let orangeDeep = Color(red: 1.000, green: 0.353, blue: 0.000) // #FF5A00
    static let purple     = Color(red: 0.655, green: 0.278, blue: 0.925) // #A747EC
    static let purpleDeep = Color(red: 0.400, green: 0.110, blue: 0.720) // #661CB8
    static let black      = Color(red: 0.047, green: 0.047, blue: 0.047) // #0C0C0C
    static let card       = Color(red: 1.000, green: 1.000, blue: 1.000).opacity(0.06)
    static let hairline   = Color.white.opacity(0.08)
    static let secondary  = Color(red: 0.720, green: 0.720, blue: 0.750)
    static let star       = Color(red: 1.000, green: 0.953, blue: 0.910) // #FFF3E8

    /// Orange -> purple, used for the "Voltex" wordmark and headings.
    static let brandGradient = LinearGradient(
        colors: [orangeDeep, orange, purple, purpleDeep],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let corner: CGFloat = 22
}
