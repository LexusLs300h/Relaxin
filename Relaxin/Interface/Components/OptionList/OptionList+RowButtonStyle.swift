import SwiftUI

extension OptionList {
    /// Modern card row. Selection and loading indicators are rendered by the label,
    /// while this style owns press feedback and the selected surface.
    struct RowButtonStyle: ButtonStyle {
        let isSelected: Bool
        let isLoading: Bool
        let accent: SwiftUI.Color
        let onPress: () -> Void

        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding(.horizontal, 2)
                .padding(.vertical, 2)
                .background {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            isSelected
                                ? accent.opacity(configuration.isPressed ? 0.15 : 0.09)
                                : configuration.isPressed ? .primary.opacity(0.05) : .clear
                        )
                }
                .overlay {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(accent.opacity(0.16))
                    }
                }
                .opacity(isLoading ? 0.65 : 1)
                .contentShape(Rectangle())
                .transaction { $0.animation = nil }
                .onChange(of: configuration.isPressed) { isPressed in
                    guard isPressed else { return }
                    onPress()
                }
        }
    }
}
