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
        // Keep the rounded terminal surface, but inset the glyph grid so the first
        // row and column never touch the clipped corners.
        view.contentInset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
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
        // Keep the terminal readable while matching the app's light dashboard surface.
        view.nativeBackgroundColor = UIColor(Theme.terminalBackground)
        view.nativeForegroundColor = UIColor(Theme.terminalForeground)
        view.caretColor = UIColor(Theme.accentBlue)
        view.caretTextColor = UIColor(Theme.terminalBackground)

        // SwiftTerm draws ANSI/default colors itself, so the view background
        // and native foreground are the only surface-level values we override.
        _ = traits
    }
}
