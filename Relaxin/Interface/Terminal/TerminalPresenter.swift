import Foundation
import SwiftUI

/// Read-only SwiftTerm surface used for banners and engine output. It follows
/// streaming output automatically while still allowing the user to scroll back
/// through earlier output. It never accepts keyboard focus or text selection.
struct TerminalPresenter: UIViewRepresentable {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.openURL) private var openURL

    let content: String
    let accessibleLinks: [AccessibleLink]
    let allowsOpeningLinks: Bool
    let onColumnCountChange: (Int) -> Void
    var onLongPress: (() -> Void)?

    func makeUIView(context _: Context) -> ReadOnlyView {
        let view = ReadOnlyView(frame: .zero, font: TerminalStyle.presenterFont)
        view.onColumnCountChange = onColumnCountChange
        view.onOpenLink = allowsOpeningLinks ? { [openURL] in openURL($0) } : nil
        view.onLongPress = onLongPress
        view.accessibleLinks = allowsOpeningLinks ? accessibleLinks : []
        // Keep the scroll view enabled so streaming output can follow the newest
        // line while the user can still scroll back through earlier output.
        view.isScrollEnabled = true
        view.isDirectionalLockEnabled = true
        view.alwaysBounceHorizontal = false
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        // Read-only surfaces never gain focus, so cursor rendering must remain independent of responder state.
        view.caretViewTracksFocus = false
        TerminalStyle.configure(view, colorScheme: colorScheme)
        view.render(content)
        return view
    }

    func updateUIView(_ view: ReadOnlyView, context _: Context) {
        view.onColumnCountChange = onColumnCountChange
        view.onOpenLink = allowsOpeningLinks ? { [openURL] in openURL($0) } : nil
        view.onLongPress = onLongPress
        view.accessibleLinks = allowsOpeningLinks ? accessibleLinks : []
        TerminalStyle.applyColors(to: view, colorScheme: colorScheme)
        view.render(content)
    }
}

extension TerminalPresenter {
    struct AccessibleLink: Equatable {
        let label: String
        let destination: URL
    }

    final class ReadOnlyView: TerminalView {
        private let terminalContentInset = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)

        var onColumnCountChange: ((Int) -> Void)?
        var onOpenLink: ((URL) -> Void)?
        var onLongPress: (() -> Void)?
        var accessibleLinks: [AccessibleLink] = [] {
            didSet {
                guard accessibleLinks != oldValue else { return }
                accessibilityCustomActions = accessibleLinks.map { link in
                    UIAccessibilityCustomAction(name: link.label) { [weak self] _ in
                        guard let self else { return false }
                        onOpenLink?(link.destination)
                        return true
                    }
                }
            }
        }

        private var renderedContent: String?
        private var reportedColumnCount: Int?


        override var canBecomeFirstResponder: Bool {
            false
        }

        override var contentSize: CGSize {
            get { super.contentSize }
            set {
                guard bounds.width > 0 else {
                    super.contentSize = newValue
                    return
                }
                let viewportWidth = max(
                    0,
                    bounds.width - adjustedContentInset.left - adjustedContentInset.right
                )
                // SwiftTerm owns the height, but this screen must never expose
                // its terminal-column width as a horizontal scroll range.
                super.contentSize = CGSize(width: viewportWidth, height: newValue.height)
            }
        }

        override func layoutSubviews() {
            super.layoutSubviews()

            // The terminal owns its four-sided content margin. Disable UIKit's
            // safe-area adjustment so 10/16 always means exactly 10/16.
            contentInsetAdjustmentBehavior = .never
            // SwiftTerm can recalculate its scroll geometry during layout, so
            // re-apply the exact inset here as well as during initial setup.
            contentInset = terminalContentInset
            scrollIndicatorInsets = terminalContentInset
            clipsToBounds = true
            updateScrollBehavior()
            let columnCount = getTerminal().cols
            guard columnCount != reportedColumnCount else { return }
            reportedColumnCount = columnCount
            DispatchQueue.main.async { [weak self] in
                guard self?.reportedColumnCount == columnCount else { return }
                self?.onColumnCountChange?(columnCount)
            }
        }

        override func canPerformAction(_: Selector, withSender _: Any?) -> Bool {
            false
        }

        override func singleTap(_ gestureRecognizer: UITapGestureRecognizer) {
            guard gestureRecognizer.state == .ended else { return }
            let position = calculateTapHit(gesture: gestureRecognizer).grid
            guard let link = getTerminal().link(
                at: .buffer(position),
                mode: .explicitOnly
            ) else {
                return
            }
            guard let destination = URL(string: link) else {
                preconditionFailure("Invalid terminal hyperlink: \(link)")
            }
            onOpenLink?(destination)
        }

        override func copy(_: Any?) {}

        override func select(_: Any?) {}

        override func selectAll(_: Any?) {}

        override func longPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
            guard gestureRecognizer.state == .began else { return }
            onLongPress?()
        }

        override func doubleTap(_: UITapGestureRecognizer) {}

        override func tripleTap(_: UITapGestureRecognizer) {}

        override func showContextMenu(forRegion _: CGRect, pos _: Position) {}

        private func updateScrollBehavior() {
            guard bounds.height > 0 else { return }

            // contentSize is the terminal's actual glyph area. The 10pt top/bottom
            // margins are added by contentInset, so a terminal that fits inside
            // the view must be tested against the full bounds, not against the
            // inset-reduced viewport. Otherwise even a one-screen terminal gets
            // an artificial 20pt scroll range.
            let availableContentHeight = max(
                0,
                bounds.height - adjustedContentInset.top - adjustedContentInset.bottom
            )
            let contentHeight = contentSize.height
            let needsVerticalScroll = contentHeight > availableContentHeight + 1

            isDirectionalLockEnabled = true
            alwaysBounceHorizontal = false
            alwaysBounceVertical = needsVerticalScroll
            showsHorizontalScrollIndicator = false
            showsVerticalScrollIndicator = needsVerticalScroll
            isScrollEnabled = needsVerticalScroll
            bounces = needsVerticalScroll
            // When the output fits, disable both scrolling and bouncing. This
            // is intentionally stricter than just hiding the indicators:
            // SwiftTerm can still write contentOffset programmatically.
            // setContentOffset() below also enforces the same fixed position.

            // SwiftTerm sizes the scroll content from its terminal column count.
            // That internal width must never become a horizontal scrolling area:
            // the execution/removal screens are a vertical log only.
            let viewportWidth = max(
                0,
                bounds.width - adjustedContentInset.left - adjustedContentInset.right
            )
            if contentSize.width != viewportWidth {
                contentSize = CGSize(width: viewportWidth, height: contentSize.height)
            }

            if !needsVerticalScroll {
                // When all output fits, keep the complete four-sided margin
                // visible and make the surface completely static.
                super.setContentOffset(
                    CGPoint(x: -terminalContentInset.left, y: -terminalContentInset.top),
                    animated: false
                )
            }
        }

        func render(_ content: String) {
            guard content != renderedContent else {
                updateScrollBehavior()
                return
            }
            renderedContent = content
            feed(text: content)
            selection.selectNone()
            disableSelectionPanGesture()

            // SwiftTerm updates contentSize while feeding the terminal. Defer
            // the measurement until that layout pass has completed.
            DispatchQueue.main.async { [weak self] in
                self?.updateScrollBehavior()
            }
        }
    }
}
