import Foundation
import SwiftData

// Kept for project file compatibility. Active implementations live in `ScannerViewModel.swift`.
struct InnovationServicesPlaceholder {
    static func log(_ message: String, context: ModelContext) {
        context.insert(FeatureEvent(name: "legacy_placeholder", metadata: message))
    }
}
