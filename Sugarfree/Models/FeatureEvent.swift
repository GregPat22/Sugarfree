import Foundation
import SwiftData

@Model
final class FeatureEvent {
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
