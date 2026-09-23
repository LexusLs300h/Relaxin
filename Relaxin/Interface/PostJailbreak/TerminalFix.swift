import SwiftUI
import UIKit

// =========================================================================
// 文件名: TerminalFix.swift
// 作用: 修复 PostJailbreakHomeView.swift 第 121 行 missing argument 'screen' 编译报错
// =========================================================================

extension AppleTerminalView {
    /// 自动补全默认的 screen 参数，兼容旧版构造器调用形式
    @inlinable
    public init(allowsOpeningTerminalLinks: Bool) {
        self.init(
            screen: UIScreen.main,
            allowsOpeningTerminalLinks: allowsOpeningTerminalLinks
        )
    }
}
