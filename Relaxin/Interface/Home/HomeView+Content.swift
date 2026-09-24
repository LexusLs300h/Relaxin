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
    var onOpenAdvancedOptions: () -> Void = {}
    var onOpenMaintenance: () -> Void = {}
    var onOpenCredits: () -> Void = {}
    var onTerminalLongPress: (() -> Void)?

    private var isEngine: Bool { screen == .engine }

    private var appVersion: String {
        let info = Bundle.main.infoDictionary ?? [:]
        let marketing = info["CFBundleShortVersionString"] as? String ?? "0.0.0"
        let build = info["CFBundleVersion"] as? String ?? "0"
        return "v\(marketing)-\(build)"
    }

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
            Group {
                if screen == .home {
                    VStack(alignment: .leading, spacing: 16) {
                        header
                        heroCard
                        homeRuntimeInfo
                        homeDashboard
                    }
                    .frame(maxWidth: 620)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 26)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        header

                        if isEngine {
                            engineCard
                            terminalCard(compactHeight: max(220, geometry.size.height * 0.36))
                        } else {
                            terminalCard(compactHeight: max(260, geometry.size.height * 0.40))
                        }

                        if showsMenu {
                            menuCard
                        }
                    }
                    .frame(maxWidth: 620)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, Theme.pagePadding)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            }
        }
        .background {
            ZStack {
                Theme.appBackgroundGradient
                    .ignoresSafeArea()

                if screen != .home {
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
    }

    private var header: some View {
        HStack(spacing: 12) {
            if screen == .home {
                Text("Relaxin")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.dashboardText)

                Spacer()
            } else {
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
                        .foregroundStyle(Theme.dashboardText)

                    Text(headerSubtitle)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.dashboardSecondaryText)
                }

                Spacer(minLength: 0)

                if isEngine {
                    statusPill(title: "RUNNING", systemImage: "bolt.fill")
                }
            }
        }
        .accessibilityElement(children: .contain)
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 13) {
                ZStack {
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .fill(Theme.accentGradient)
                        .frame(width: 52, height: 52)

                    Text("R")
                        .font(.system(size: 29, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("准备越狱")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("点击下方按钮开始执行越狱流程")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.72))
                }

                Spacer(minLength: 0)
            }

            Button {
                if let action = menuItems.first?.id {
                    onSelectMenuItem(action)
                }
            } label: {
                HStack {
                    Spacer()
                    Text("开始越狱")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .bold))
                    Spacer()
                }
                .foregroundStyle(.white)
                .frame(height: 40)
                .background(
                    Theme.dashboardBackground.opacity(0.58),
                    in: Capsule()
                )
                .overlay {
                    Capsule()
                        .strokeBorder(.white.opacity(0.08))
                }
            }
            .disabled(menuItems.isEmpty)
        }
        .padding(16)
        .background(Theme.accentGradient, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(.white.opacity(0.08))
                .frame(width: 150, height: 150)
                .offset(x: 42, y: -58)
        }
        .clipped()
        .shadow(color: Theme.accentPurple.opacity(0.20), radius: 24, y: 12)
    }

    private var homeRuntimeInfo: some View {
        HStack(spacing: 0) {
            runtimeItem(title: "软件版本", value: appVersion, systemImage: "app.badge.fill")

            Divider()
                .frame(height: 34)
                .overlay(Theme.dashboardIcon.opacity(0.18))

            runtimeItem(title: "系统运行时间", value: DeviceInfo.uptime, systemImage: "clock.fill")
        }
        .padding(.horizontal, 16)
        .frame(height: 66)
        .background(Theme.dashboardCard, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Theme.dashboardIcon.opacity(0.12))
        }
    }

    private func runtimeItem(title: String, value: String, systemImage: String) -> some View {
        HStack(spacing: 9) {
            Image(systemName: systemImage)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Theme.dashboardIcon)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 9, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.dashboardSecondaryText)
                Text(value)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.dashboardText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
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
                    .foregroundStyle(Theme.dashboardText)
                Text("Relaxin Engine 正在处理任务，请勿退出应用")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.dashboardSecondaryText)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(Theme.dashboardCard, in: RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous)
                .strokeBorder(Theme.dashboardIcon.opacity(0.10))
        }
    }

    private func terminalCard(compactHeight: CGFloat) -> some View {
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
                         .foregroundStyle(Theme.dashboardSecondaryText)

                    Spacer()

                    Label(isEngine ? "LIVE" : "READY", systemImage: isEngine ? "waveform" : "terminal")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                         .foregroundStyle(Theme.dashboardIcon)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                         .background(Theme.dashboardIcon.opacity(0.08), in: Capsule())
                }

                Rectangle()
                     .fill(Theme.dashboardIcon.opacity(0.12))
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
                minHeight: compactHeight,
                maxHeight: compactHeight,
                alignment: .topLeading
            )
            .padding(.horizontal, 10)
            .padding(.bottom, 12)
        }
        .background(Theme.dashboardCard, in: RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous)
                .strokeBorder(Theme.dashboardIcon.opacity(0.10))
        }
    }

    private var homeDashboard: some View {
        VStack(spacing: 14) {
            deviceInfoCard

            HStack(spacing: 10) {
                dashboardAction(
                    title: "日志",
                    subtitle: "查看执行日志",
                    systemImage: "doc.text.fill"
                ) {
                    onOpenMaintenance()
                }

                dashboardAction(
                    title: "设置",
                    subtitle: "配置偏好选项",
                    systemImage: "gearshape.fill"
                ) {
                    onOpenAdvancedOptions()
                }

                dashboardAction(
                    title: "关于",
                    subtitle: "了解更多信息",
                    systemImage: "info.circle.fill"
                ) {
                    onOpenCredits()
                }
            }

        }
    }

    private var deviceInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            dashboardInfoRow(title: "OS", value: DeviceInfo.os, systemImage: "apple.logo")
            dashboardInfoRow(title: "host", value: DeviceInfo.host, systemImage: "iphone")
            dashboardInfoRow(title: "kernel", value: "Darwin 23.0.0", systemImage: "terminal.fill")
            dashboardInfoRow(title: "build", value: appVersion, systemImage: "hammer.fill")
            dashboardInfoRow(title: "uptime", value: DeviceInfo.uptime, systemImage: "clock.fill")
        }
        .padding(18)
        .background(Theme.dashboardCard, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Theme.dashboardIcon.opacity(0.10))
        }
    }

    private func dashboardInfoRow(title: String, value: String, systemImage: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Theme.dashboardIcon)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 9, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.dashboardSecondaryText)
                Text(value)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.dashboardText)
            }

            Spacer()
        }
    }

    private func dashboardAction(
        title: String,
        subtitle: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Theme.dashboardIcon)

                Text(title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.dashboardText)

                Text(subtitle)
                    .font(.system(size: 8, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.dashboardSecondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 88)
            .background(Theme.dashboardCard, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(.white.opacity(0.055))
            }
        }
        .buttonStyle(.plain)
    }

    private var menuCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(screen == .home ? "操作" : "选项")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.dashboardSecondaryText)
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
        .background(Theme.dashboardCard, in: RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous)
                .strokeBorder(Theme.dashboardIcon.opacity(0.10))
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
