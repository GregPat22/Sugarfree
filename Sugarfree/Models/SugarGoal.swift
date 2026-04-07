import Foundation
import SwiftData

@Model
final class SugarGoal {
    var dailyLimitGrams: Double
    var startDate: Date
    var currentStreakDays: Int
    var longestStreakDays: Int
    var isActive: Bool

    init(
        dailyLimitGrams: Double = 25.0,
        startDate: Date = .now,
        currentStreakDays: Int = 0,
        longestStreakDays: Int = 0,
        isActive: Bool = true
    ) {
        self.dailyLimitGrams = dailyLimitGrams
        self.startDate = startDate
        self.currentStreakDays = currentStreakDays
        self.longestStreakDays = longestStreakDays
        self.isActive = isActive
    }
}
