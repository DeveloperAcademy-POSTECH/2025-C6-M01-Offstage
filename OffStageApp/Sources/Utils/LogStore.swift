
#if DEBUG_MODE
    import Foundation
    import SwiftUI

    @MainActor
    final class LogStore: ObservableObject {
        @Published private(set) var logs: [String] = []

        static let shared = LogStore()

        private init() {}

        func addLog(_ message: String) {
            let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
            logs.append("[\(timestamp)] \(message)")
        }

        func clearLogs() {
            logs.removeAll()
        }
    }

    // Helper function for easy logging
    func debugLog(_ message: String) {
        Task { @MainActor in
            LogStore.shared.addLog(message)
        }
    }#endif
