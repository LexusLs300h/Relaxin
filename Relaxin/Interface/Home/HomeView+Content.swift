import SwiftUI

struct HomeContent<Action: Hashable>: View {
    let terminalText: String
    let terminalAccessibleLinks: [TerminalPresenter.AccessibleLink]
    let terminalHeight: CGFloat
    let rendersTerminalBackgroundActively: Bool
    let showsMenu: Bool
    let menuItems: [OptionListItem<Action>]
    let preferredMenuAction: Action?
    let secondaryMenuActions: Set<Action>
    let shareItems: [Action: URL]
    let loadingMenuActions: Set<Action>
    let isVolumeButtonInputEnabled: Bool
    let allowsOpeningTerminalLinks: Bool
    let screen: HomeView.Screen
    let onTerminalColumnCountChange: (Int) -> Void
    let onSelectMenuItem: (Action) -> Void
    var onTerminalLongPress: (() -> Void)?

    private var isEngine: Bool { screen == .engine }

    private var visibleMenuItems: [OptionListItem<Action>] {
        // The home screen already has the primary jailbreak button above.
        // Hide only the duplicated first action from the lower menu.
        if screen == .home {
            return Array(menuItems.dropFirst())
        }
        return menuItems
    }

    private var headerTitle: String {
        switch screen {
        case .home: "Relaxin"
        case .advancedOptions: "Advanced Options"
        case .maintenance: "Maintenance"
        case .credits: "Credits"
        case .jetsamMultiplier: "Jetsam Multiplier"
        case .confirmation: "Confirmation"
        case .engine: "Relaxin"
        }
    }

    private var headerSubtitle: String {
        switch screen {
        case .home: "RootHide jailbreak utility"
        case .advancedOptions: "Configure jailbreak options"
        case .maintenance: "Diagnostics and maintenance tools"
        case .credits: "Open source and acknowledgements"
        case .jetsamMultiplier: "Choose memory pressure multiplier"
        case .confirmation: "Review this action before continuing"
        case .engine: "Jailbreak process"
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    header

                    if screen == .home {
                        heroCard
                    } else if isEngine {
                        engineCard
                    }

                    terminalCard

                    if showsMenu {
                        menuCard
                    }
                }
                .frame(maxWidth: 620)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, Theme.pagePadding)
                .padding(.top, 12)
                .padding(.bottom, 28)
                .frame(minHeight: geometry.size.height, alignment: .top)
            }
        }
        .background {
            ZStack {
                Theme.background
                Theme.subtleGradient
                    .ignoresSafeArea()

                TerminalCharacterBackground(
                    rendersActively: rendersTerminalBackgroundActively
                )
                .opacity(isEngine ? 0.035 : 0.018)
                .ignoresSafeArea()
            }
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(Theme.accentGradient)
                    .frame(width: 46, height: 46)

                Text("R")
                    .font(.system(size: 25, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .shadow(color: Theme.accentPurple.opacity(0.28), radius: 14, y: 7)

            VStack(alignment: .leading, spacing: 2) {
                Text(headerTitle)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.foreground)

                Text(headerSubtitle)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            if isEngine {
                statusPill(title: "RUNNING", systemImage: "bolt.fill")
            } else if screen == .home {
                statusPill(title: "READY", systemImage: "checkmark.circle.fill")
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.16))
                        .frame(width: 56, height: 56)
                    Image(systemName: "bolt.horizontal.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text("准备越狱")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("保持设备连接并开始执行 Relaxin")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.78))
                }

                Spacer(minLength: 0)
            }

            Button {
                if let action = menuItems.first?.id {
                    onSelectMenuItem(action)
                }
            } label: {
                HStack {
                    Text("开始越狱")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                    Spacer()
                    Image(systemName: "arrow.right")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundStyle(Theme.accentPurple)
                .padding(.horizontal, 16)
                .frame(height: 46)
                .background(.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .disabled(menuItems.isEmpty)
        }
        .padding(18)
        .background(Theme.accentGradient, in: RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous))
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(.white.opacity(0.08))
                .frame(width: 150, height: 150)
                .offset(x: 42, y: -58)
        }
        .clipped()
        .shadow(color: Theme.accentPurple.opacity(0.20), radius: 24, y: 12)
    }

    private var engineCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(.secondary.opacity(0.18), lineWidth: 7)
                    .frame(width: 56, height: 56)
                Circle()
                    .trim(from: 0, to: 0.42)
                    .stroke(Theme.accentGradient, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                    .frame(width: 56, height: 56)
                    .rotationEffect(.degrees(-90))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("正在执行")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                Text("Relaxin Engine 正在处理任务，请勿退出应用")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous)
                .strokeBorder(.white.opacity(0.06))
        }
    }

    private var terminalCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(spacing: 10) {
                HStack(spacing: 9) {
                    HStack(spacing: 6) {
                        Circle().fill(.red.opacity(0.82)).frame(width: 7, height: 7)
                        Circle().fill(.yellow.opacity(0.82)).frame(width: 7, height: 7)
                        Circle().fill(Theme.accentBlue).frame(width: 7, height: 7)
                    }

                    Text(isEngine ? "ENGINE OUTPUT" : "RELAXIN TERMINAL")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .tracking(1.1)
                        .foregroundStyle(Theme.terminalDim)

                    Spacer()

                    Label(isEngine ? "LIVE" : "READY", systemImage: isEngine ? "waveform" : "terminal")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundStyle(isEngine ? Theme.accentBlue : Theme.terminalDim)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(.white.opacity(0.045), in: Capsule())
                }

                Rectangle()
                    .fill(.white.opacity(0.06))
                    .frame(height: 1)
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)
            .padding(.bottom, 4)

            TerminalPresenter(
                content: terminalText,
                accessibleLinks: terminalAccessibleLinks,
                allowsOpeningLinks: allowsOpeningTerminalLinks,
                onColumnCountChange: onTerminalColumnCountChange,
                onLongPress: onTerminalLongPress
            )
            .frame(
                maxWidth: .infinity,
                minHeight: terminalHeight,
                maxHeight: isEngine ? .infinity : terminalHeight,
                alignment: .topLeading
            )
            .padding(.horizontal, 10)
            .padding(.bottom, 12)
        }
        .background(Theme.terminalBackground, in: RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous)
                .strokeBorder(.white.opacity(0.055))
        }
    }

    private var menuCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(screen == .home ? "操作" : "选项")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 14)
                .padding(.top, 14)
                .padding(.bottom, 4)

            OptionList(
                entries: visibleMenuItems,
                preferredSelection: preferredMenuAction,
                secondaryActions: secondaryMenuActions,
                shareItems: shareItems,
                loadingActions: loadingMenuActions,
                isVolumeButtonInputEnabled: isVolumeButtonInputEnabled,
                onSelectionChange: { _ in },
                onSelect: onSelectMenuItem
            )
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
        }
        .background(Theme.card, in: RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous)
                .strokeBorder(.white.opacity(0.055))
        }
    }

    private func statusPill(title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .foregroundStyle(Theme.accentBlue)
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(Theme.accentBlue.opacity(0.10), in: Capsule())
    }
}
