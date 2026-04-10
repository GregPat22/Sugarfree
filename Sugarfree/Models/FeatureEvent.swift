import Foundation
import SwiftData

// Kept for project file compatibility; the active `FeatureEvent` model is in `DailyLog.swift`.
@Model
final class FeatureEventMirror {
    var name: String
    var metadata: String?
    var timestamp: Date

    init(
        name: String,
        metadata: String? = nil,
        timestamp: Date = .now
    ) {
        self.name = name
        self.metadata = metadata
        self.timestamp = timestamp
    }
}
