import Foundation
import SwiftUI

extension HomeView {
    enum Presentation {
        struct Alert: Identifiable {
            let title: String
            let message: String

            var id: String {
                "\(title)\0\(message)"
            }
        }
    }
}

private struct JailbreakRemovalCompleteView: View {
    let resourceBundle: Bundle
    let onBack: () -> Void
    let onClose: () -> Void

    var body: some View {
        ZStack {
            Theme.appBackgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 54))
                    .foregroundStyle(Theme.dashboardIcon)

                Text(
                    String(
                        localized: "Jailbreak Removal Complete",
                        bundle: resourceBundle
                    )
                )
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.dashboardText)
                .multilineTextAlignment(.center)

                Text(
                    String(
                        localized: "Jailbreak removal is complete.",
                        bundle: resourceBundle
                    )
                )
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.dashboardSecondaryText)
                .multilineTextAlignment(.center)

                HStack(spacing: 12) {
                    Button(action: onBack) {
                        Text(
                            String(
                                localized: "Back",
                                bundle: resourceBundle
                            )
                        )
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.dashboardText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            Theme.dashboardCard,
                            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                        )
                    }

                    Button(action: onClose) {
                        Text(
                            String(
                                localized: "OK",
                                bundle: resourceBundle
                            )
                        )
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            Theme.accentGradient,
                            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                        )
                    }
                }
            }
            .frame(maxWidth: 620)
            .padding(24)
            .background(
                Theme.dashboardCard,
                in: RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous)
                    .strokeBorder(Theme.dashboardIcon.opacity(0.10))
            }
            .padding(.horizontal, Theme.pagePadding)
        }
    }
}
