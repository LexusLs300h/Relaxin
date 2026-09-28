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

        override func layoutSubviews() {
            super.layoutSubviews()

            // Keep the terminal glyph grid safely inside the rounded surface.
            // SwiftTerm can recalculate its scroll geometry during layout, so
            // apply the inset here as well as during initial configuration.
            // Preserve the original four-sided terminal content margins:
            // top 10, left 16, bottom 10, right 16. These are the margins
            // around the first row/column, not font padding.
            contentInset = terminalContentInset
            scrollIndicatorInsets = terminalContentInset
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

        override func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
            // This terminal is intentionally a vertical log surface. Keep the
            // horizontal position fixed even if SwiftTerm calculates a wider
            // content area for its terminal grid.
            let fixedX = -adjustedContentInset.left
            super.setContentOffset(
                CGPoint(x: fixedX, y: contentOffset.y),
                animated: animated
            )
        }

        private func updateScrollBehavior() {
            guard bounds.height > 0 else { return }

            let viewportHeight = bounds.height - adjustedContentInset.top - adjustedContentInset.bottom
            let contentHeight = contentSize.height
            let needsVerticalScroll = contentHeight > viewportHeight + 1

            isDirectionalLockEnabled = true
            alwaysBounceHorizontal = false
            showsHorizontalScrollIndicator = false
            showsVerticalScrollIndicator = needsVerticalScroll
            isScrollEnabled = needsVerticalScroll

            if !needsVerticalScroll {
                // When all output fits, disable scrolling and keep the complete
                // four-sided margin visible instead of allowing a rubber-band
                // movement.
                super.setContentOffset(
                    CGPoint(x: -adjustedContentInset.left, y: -adjustedContentInset.top),
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
