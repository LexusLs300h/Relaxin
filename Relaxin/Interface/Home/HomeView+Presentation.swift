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
