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
