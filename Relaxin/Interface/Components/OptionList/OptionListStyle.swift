import SwiftUI

enum OptionListLayout {
    static let markerWidth = Theme.fontSize
    static let markerSpacing: CGFloat = 4
    static let markerGutter = markerWidth + markerSpacing
}

struct OptionListStyle {
    let foreground: SwiftUI.Color
    let secondaryForeground: SwiftUI.Color
    let accent: SwiftUI.Color

    static let standard = OptionListStyle(
        foreground: SwiftUI.Color(red: 0.10, green: 0.12, blue: 0.20),
        secondaryForeground: SwiftUI.Color(red: 0.36, green: 0.39, blue: 0.48),
        accent: Theme.accentPurple
    )

    static let failure = OptionListStyle(
        foreground: .white,
        secondaryForeground: .white,
        accent: .white
    )
}
