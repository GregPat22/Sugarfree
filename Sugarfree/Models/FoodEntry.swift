import Foundation
import SwiftData

@Model
final class FoodEntry {
    var name: String
    var brand: String?
    var barcode: String?
    var sugarGrams: Double
    var servingSize: String?
    var isManualEntry: Bool
    var timestamp: Date
    var notes: String?
    var swapRecommendationUsed: Bool
    var predictedRemainingAfterEntry: Double?
    var riskAtLogTime: String?

    init(
        name: String,
        brand: String? = nil,
        barcode: String? = nil,
        sugarGrams: Double,
        servingSize: String? = nil,
        isManualEntry: Bool = false,
        timestamp: Date = .now,
        notes: String? = nil,
        swapRecommendationUsed: Bool = false,
        predictedRemainingAfterEntry: Double? = nil,
        riskAtLogTime: String? = nil
    ) {
        self.name = name
        self.brand = brand
        self.barcode = barcode
        self.sugarGrams = sugarGrams
        self.servingSize = servingSize
        self.isManualEntry = isManualEntry
        self.timestamp = timestamp
        self.notes = notes
        self.swapRecommendationUsed = swapRecommendationUsed
        self.predictedRemainingAfterEntry = predictedRemainingAfterEntry
        self.riskAtLogTime = riskAtLogTime
    }
}
