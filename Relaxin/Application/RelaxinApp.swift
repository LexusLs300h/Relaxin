import Foundation
import SwiftUI
import UIKit

private let networkAccessProbeURL = URL(
    string: "https://captive.apple.com/hotspot-detect.html"
)!

@MainActor
final class RelaxinAppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        if shortcutItem.type == "com.relaxin.jailbreak" {
            UserDefaults.standard.set(true, forKey: "RelaxinQuickJailbreakPending")
            NotificationCenter.default.post(name: .relaxinQuickJailbreak, object: nil)
            completionHandler(true)
        } else {
            completionHandler(false)
        }
    }
}

extension Notification.Name {
    static let relaxinQuickJailbreak = Notification.Name("RelaxinQuickJailbreak")
}

struct RelaxinApp: App {
    @UIApplicationDelegateAdaptor(RelaxinAppDelegate.self) private var appDelegate
    private let runtime: RelaxinRuntime

    init() {
        let runtime = RelaxinRuntime.native
        self.runtime = runtime
        AppLog.bootstrap(dataDirectory: runtime.dataDirectory)
        AppLog.connectEngineLogging()
        AppLog.connectPostJailbreakLogging()
        AppLog.removeStaleExportArchives(in: runtime.temporaryDirectory)
        AppLog.info(
            Self.self,
            "app init version=\(AppInfo.version(in: runtime.resourceBundle)) "
                + "build=\(AppInfo.build(in: runtime.resourceBundle)) arch=\(AppInfo.arch)"
        )
        AppLog.info(Self.self, "target \(JailbreakTarget.current.logDescription)")
        TerminalCharacterBackgroundImage.prepare()
        requestNetworkAccess()
    }

    var body: some Scene {
        WindowGroup(id: "main") {
            RootView(runtime: runtime)
        }
        .commandsReplaced {
            CommandGroup(replacing: .newItem) {}
        }
    }

    private func requestNetworkAccess() {
        Task.detached {
            try? await Task.sleep(for: .seconds(1))
            _ = try? await URLSession.shared.data(from: networkAccessProbeURL)
        }
    }
}
