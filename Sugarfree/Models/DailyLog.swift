import Foundation
import SwiftData

@Model
final class DailyLog {
    var date: Date
    var totalSugarGrams: Double
    var entryCount: Int
    var metGoal: Bool
    var forecastRemainingGrams: Double
    var riskLevel: String
    var usedRescueMode: Bool
    var usedInsurance: Bool

    init(
        date: Date = .now,
        totalSugarGrams: Double = 0,
        entryCount: Int = 0,
        metGoal: Bool = true,
        forecastRemainingGrams: Double = 0,
        riskLevel: String = "low",
        usedRescueMode: Bool = false,
        usedInsurance: Bool = false
    ) {
        self.date = date
        self.totalSugarGrams = totalSugarGrams
        self.entryCount = entryCount
        self.metGoal = metGoal
        self.forecastRemainingGrams = forecastRemainingGrams
        self.riskLevel = riskLevel
        self.usedRescueMode = usedRescueMode
        self.usedInsurance = usedInsurance
    }
}
