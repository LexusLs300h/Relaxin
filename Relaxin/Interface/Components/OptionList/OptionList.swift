import SwiftUI

struct OptionList<Action: Hashable>: View {
    let entries: [OptionListItem<Action>]
    let preferredSelection: Action?
    let secondaryActions: Set<Action>
    let shareItems: [Action: URL]
    let loadingActions: Set<Action>
    let style: OptionListStyle
    let isVolumeButtonInputEnabled: Bool
    let onSelectionChange: (Action) -> Void
    let onSelect: (Action) -> Void
    @State private var selected: Action?
    @State private var pendingAction: Task<Void, Never>?
    @State private var sharePresentation: SharePresentation?

    private var selectedID: Action? {
        guard let selected, entries.contains(where: { $0.id == selected }) else {
            return defaultSelection
        }
        return selected
    }

    private var defaultSelection: Action? {
        if let preferredSelection, entries.contains(where: { $0.id == preferredSelection }) {
            return preferredSelection
        }
        return entries.first?.id
    }

    init(
        entries: [OptionListItem<Action>],
        preferredSelection: Action? = nil,
        secondaryActions: Set<Action> = [],
        shareItems: [Action: URL] = [:],
        loadingActions: Set<Action> = [],
        style: OptionListStyle = .standard,
        isVolumeButtonInputEnabled: Bool = true,
        onSelectionChange: @escaping (Action) -> Void = { _ in },
        onSelect: @escaping (Action) -> Void
    ) {
        self.entries = entries
        self.preferredSelection = preferredSelection
        self.secondaryActions = secondaryActions
        self.shareItems = shareItems
        self.loadingActions = loadingActions
        self.style = style
        self.isVolumeButtonInputEnabled = isVolumeButtonInputEnabled
        self.onSelectionChange = onSelectionChange
        self.onSelect = onSelect
        _selected = State(
            initialValue: preferredSelection.flatMap { preferred in
                entries.contains(where: { $0.id == preferred }) ? preferred : nil
            } ?? entries.first?.id
        )
    }

    var body: some View {
        VStack(spacing: 7) {
            ForEach(entries) { entry in
                let isSecondary = secondaryActions.contains(entry.id)
                let isSelected = entry.id == selectedID
                let isLoading = loadingActions.contains(entry.id)

                Button {
                    activate(entry.id)
                } label: {
                    label(for: entry, isSelected: isSelected, isSecondary: isSecondary, isLoading: isLoading)
                }
                .buttonStyle(
                    RowButtonStyle(
                        isSelected: isSelected,
                        isLoading: isLoading,
                        accent: style.accent,
                        onPress: { select(entry.id) }
                    )
                )
                .disabled(isLoading)
                .id(entry.id)
            }
        }
        .font(Theme.font)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            if isVolumeButtonInputEnabled, sharePresentation == nil {
                VolumeButtonInput(
                    onTap: moveSelection,
                    onLongPress: activateSelection
                )
                .frame(width: 0, height: 0)
                .accessibilityHidden(true)
            }
        }
        .onChange(of: entries.map(\.id)) { _ in
            select(defaultSelection)
        }
        .onChange(of: preferredSelection) { _ in
            select(defaultSelection)
        }
        .onAppear {
            if let selectedID {
                onSelectionChange(selectedID)
            }
        }
        .onDisappear {
            pendingAction?.cancel()
        }
        .sheet(item: $sharePresentation) { presentation in
            ShareSheet(url: presentation.url)
        }
    }

    private func label(
        for entry: OptionListItem<Action>,
        isSelected: Bool,
        isSecondary: Bool,
        isLoading: Bool
    ) -> some View {
        HStack(spacing: 11) {
            if isLoading {
                ProgressView()
                    .controlSize(.small)
                    .tint(style.accent)
                    .frame(width: 15)
            } else {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(
                        isSelected ? style.accent : .secondary.opacity(0.52)
                    )
                    .frame(width: 15)
            }

            Text(entry.title)
                .font(
                    .system(
                        size: 14,
                        weight: isSelected ? .semibold : .medium,
                        design: .rounded
                    )
                )
                .foregroundStyle(
                    isSelected
                        ? style.accent
                        : isSecondary ? style.secondaryForeground : style.foreground
                )
                .lineLimit(2)

            Spacer(minLength: 4)

            if isSecondary {
                Image(systemName: "chevron.left")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.secondary)
            } else if shareItems[entry.id] != nil {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.secondary.opacity(0.7))
            }
        }
        .padding(.horizontal, 13)
        .frame(minHeight: 48)
        .contentShape(Rectangle())
    }

    private func activate(_ action: Action) {
        select(action)
        pendingAction?.cancel()
        if let url = shareItems[action] {
            sharePresentation = SharePresentation(url: url)
            return
        }

        pendingAction = Task { @MainActor in
            do {
                try await Task.sleep(for: .milliseconds(50))
            } catch {
                return
            }
            guard selected == action else { return }
            onSelect(action)
        }
    }

    private func moveSelection(_ direction: VolumeButtonDirection) {
        guard
            let selectedID,
            let selectedIndex = entries.firstIndex(where: { $0.id == selectedID })
        else {
            return
        }

        let targetIndex = switch direction {
        case .up:
            max(entries.startIndex, selectedIndex - 1)
        case .down:
            min(entries.index(before: entries.endIndex), selectedIndex + 1)
        }
        select(entries[targetIndex].id)
    }

    private func activateSelection() {
        guard
            let selectedID,
            !loadingActions.contains(selectedID)
        else {
            return
        }
        activate(selectedID)
    }

    private func select(_ id: Action?) {
        guard selected != id else { return }
        withTransaction(Transaction(animation: nil)) {
            selected = id
        }
        if let id {
            onSelectionChange(id)
        }
    }
}
