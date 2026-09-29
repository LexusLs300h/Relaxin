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

    // Terminal surface follows the system appearance.
    static let terminalBackground = SwiftUI.Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.045, green: 0.055, blue: 0.075, alpha: 0.96)
            : UIColor.white.withAlphaComponent(0.72)
    })
    static let terminalForeground = SwiftUI.Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.92, green: 0.94, blue: 0.98, alpha: 1)
            : UIColor(red: 0.12, green: 0.14, blue: 0.20, alpha: 1)
    })
    static let terminalDim = SwiftUI.Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.60, green: 0.64, blue: 0.72, alpha: 1)
            : UIColor(red: 0.40, green: 0.44, blue: 0.54, alpha: 1)
    })
    // Dashboard palette follows the system appearance on every screen.
    static let dashboardBackground = SwiftUI.Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.035, green: 0.045, blue: 0.07, alpha: 1)
            : UIColor(red: 0.93, green: 0.95, blue: 1.0, alpha: 1)
    })
    static let dashboardCard = SwiftUI.Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.075, green: 0.09, blue: 0.14, alpha: 0.94)
            : UIColor.white.withAlphaComponent(0.88)
    })
    static let dashboardBar = SwiftUI.Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.055, green: 0.065, blue: 0.10, alpha: 0.94)
            : UIColor.white.withAlphaComponent(0.82)
    })
    static let dashboardText = SwiftUI.Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.93, green: 0.95, blue: 0.99, alpha: 1)
            : UIColor(red: 0.10, green: 0.12, blue: 0.18, alpha: 1)
    })
    static let dashboardSecondaryText = SwiftUI.Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.62, green: 0.66, blue: 0.75, alpha: 1)
            : UIColor(red: 0.34, green: 0.38, blue: 0.48, alpha: 1)
    })
    static let dashboardIcon = SwiftUI.Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.42, green: 0.62, blue: 1.0, alpha: 1)
            : UIColor(red: 0.30, green: 0.38, blue: 0.88, alpha: 1)
    })
    static let dashboardAccent = SwiftUI.Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.45, green: 0.55, blue: 1.0, alpha: 1)
            : UIColor(red: 0.32, green: 0.40, blue: 0.95, alpha: 1)
    })

    // App-wide background also follows the system appearance.
    static let appBackgroundGradient = LinearGradient(
        colors: [
            dynamicColor(
                light: UIColor(red: 0.88, green: 0.94, blue: 1.0, alpha: 1),
                dark: UIColor(red: 0.025, green: 0.035, blue: 0.06, alpha: 1)
            ),
            dynamicColor(
                light: UIColor(red: 0.94, green: 0.90, blue: 1.0, alpha: 1),
                dark: UIColor(red: 0.035, green: 0.028, blue: 0.065, alpha: 1)
            ),
            dynamicColor(
                light: UIColor(red: 0.99, green: 0.91, blue: 0.98, alpha: 1),
                dark: UIColor(red: 0.045, green: 0.03, blue: 0.07, alpha: 1)
            ),
            dynamicColor(
                light: UIColor(red: 0.88, green: 0.93, blue: 1.0, alpha: 1),
                dark: UIColor(red: 0.025, green: 0.04, blue: 0.075, alpha: 1)
            )
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    private static func dynamicColor(light: UIColor, dark: UIColor) -> SwiftUI.Color {
        SwiftUI.Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? dark : light
        })
    }
    static let accentBlue = SwiftUI.Color(red: 0.20, green: 0.58, blue: 1.0)
    static let accentPurple = SwiftUI.Color(red: 0.47, green: 0.27, blue: 1.0)
    static let accentPink = SwiftUI.Color(red: 0.72, green: 0.31, blue: 1.0)

    static let accentGradient = LinearGradient(
        colors: [accentBlue, accentPurple, accentPink],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let darkModeAccentGradient = LinearGradient(
        colors: [
            dynamicColor(
                light: UIColor(red: 0.20, green: 0.58, blue: 1.0, alpha: 1),
                dark: UIColor(red: 0.07, green: 0.20, blue: 0.34, alpha: 1)
            ),
            dynamicColor(
                light: UIColor(red: 0.47, green: 0.27, blue: 1.0, alpha: 1),
                dark: UIColor(red: 0.16, green: 0.10, blue: 0.32, alpha: 1)
            ),
            dynamicColor(
                light: UIColor(red: 0.72, green: 0.31, blue: 1.0, alpha: 1),
                dark: UIColor(red: 0.27, green: 0.11, blue: 0.35, alpha: 1)
            )
        ],
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
