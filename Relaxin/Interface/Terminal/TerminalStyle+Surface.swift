import SwiftUI
import UIKit

extension TerminalStyle {
    static let presenterFont = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)

    @MainActor static func configure(
        _ view: TerminalView,
        colorScheme: SwiftUI.ColorScheme
    ) {
        view.backgroundColor = UIColor(Theme.terminalBackground)
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.isOpaque = false
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.linkReporting = .explicit
        view.linkHighlightMode = .always
        view.allowMouseReporting = false
        applyColors(to: view, colorScheme: colorScheme)
    }

    @MainActor static func applyColors(
        to view: TerminalView,
        colorScheme: SwiftUI.ColorScheme
    ) {
        let traits = UITraitCollection(
            userInterfaceStyle: colorScheme == .dark ? .dark : .light
        )
        // Keep the terminal palette stable even when the surrounding app is in
        // Light Mode. The terminal is a deliberately dark, high-contrast surface.
        view.nativeBackgroundColor = UIColor(Theme.terminalBackground)
        view.nativeForegroundColor = UIColor(Theme.terminalForeground)
        view.caretColor = UIColor(Theme.accentBlue)
        view.caretTextColor = UIColor(Theme.terminalBackground)

        // SwiftTerm draws ANSI/default colors itself, so the view background
        // and native foreground are the only surface-level values we override.
        _ = traits
    }
}
