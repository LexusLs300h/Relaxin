import SwiftUI
import UIKit

enum Theme {
    static let accent = SwiftUI.Color(.accent)
    static let foreground = SwiftUI.Color.primary
    static let background = SwiftUI.Color(uiColor: .systemBackground)
    static let failureBackground = SwiftUI.Color(red: 0.72, green: 0, blue: 0)

    // Relaxin visual system: deep charcoal + blue/purple gradient accents.
    static let card = SwiftUI.Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.075, green: 0.09, blue: 0.14, alpha: 1)
            : UIColor.secondarySystemBackground
    })
    static let cardElevated = SwiftUI.Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.105, green: 0.12, blue: 0.18, alpha: 1)
            : UIColor.systemBackground
    })
    static let secondaryBackground = SwiftUI.Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.055, green: 0.065, blue: 0.10, alpha: 1)
            : UIColor.tertiarySystemBackground
    })

    // The terminal is intentionally dark in both system appearances so its
    // output remains visually distinct from the surrounding SwiftUI cards.
    static let terminalBackground = SwiftUI.Color(red: 0.035, green: 0.045, blue: 0.075)
    static let terminalForeground = SwiftUI.Color(red: 0.93, green: 0.95, blue: 1.0)
    static let terminalDim = SwiftUI.Color(red: 0.50, green: 0.55, blue: 0.66)
    // Light dashboard palette: soft white cards over a blue-violet gradient.
    static let dashboardBackground = SwiftUI.Color(red: 0.93, green: 0.95, blue: 1.0)
    static let dashboardCard = SwiftUI.Color.white.opacity(0.88)
    static let dashboardBar = SwiftUI.Color.white.opacity(0.82)
    static let dashboardText = SwiftUI.Color(red: 0.10, green: 0.12, blue: 0.18)
    static let dashboardSecondaryText = SwiftUI.Color(red: 0.34, green: 0.38, blue: 0.48)
    static let dashboardIcon = SwiftUI.Color(red: 0.30, green: 0.38, blue: 0.88)
    static let dashboardAccent = SwiftUI.Color(red: 0.32, green: 0.40, blue: 0.95)

    // App-wide background: light blue flowing into soft violet.
    static let appBackgroundGradient = LinearGradient(
        colors: [
            SwiftUI.Color(red: 0.88, green: 0.94, blue: 1.0),
            SwiftUI.Color(red: 0.94, green: 0.90, blue: 1.0),
            SwiftUI.Color(red: 0.99, green: 0.91, blue: 0.98),
            SwiftUI.Color(red: 0.88, green: 0.93, blue: 1.0)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let accentBlue = SwiftUI.Color(red: 0.20, green: 0.58, blue: 1.0)
    static let accentPurple = SwiftUI.Color(red: 0.47, green: 0.27, blue: 1.0)
    static let accentPink = SwiftUI.Color(red: 0.72, green: 0.31, blue: 1.0)

    static let accentGradient = LinearGradient(
        colors: [accentBlue, accentPurple, accentPink],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let subtleGradient = LinearGradient(
        colors: [accentBlue.opacity(0.18), accentPurple.opacity(0.10), .clear],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let pagePadding: CGFloat = 20
    static let cardRadius: CGFloat = 22
    static let smallCardRadius: CGFloat = 16

    static let fontSize: CGFloat = 14
    static let font = Font.system(size: fontSize, weight: .regular, design: .monospaced)
    static let uiFont = UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
}
