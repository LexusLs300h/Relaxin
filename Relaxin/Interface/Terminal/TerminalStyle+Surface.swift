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
        // The terminal uses a fixed four-sided content margin. Do not let
        // UIKit add safe-area padding on top of these exact values.
        view.contentInsetAdjustmentBehavior = .never
        view.contentInset = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
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
