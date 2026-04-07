import Foundation
import SwiftData
import Observation

@Observable
final class DashboardViewModel {
    var todaySugarGrams: Double = 0
    var dailyLimitGrams: Double = 25.0
    var currentStreak: Int = 0
    var recentEntries: [FoodEntry] = []

    var remainingGrams: Double {
        max(0, dailyLimitGrams - todaySugarGrams)
    }

    var progressFraction: Double {
        guard dailyLimitGrams > 0 else { return 0 }
        return min(1.0, todaySugarGrams / dailyLimitGrams)
    }

    var isOverLimit: Bool {
        todaySugarGrams > dailyLimitGrams
    }

    // TODO: Load today's entries from SwiftData and compute totals
    func loadTodayData(context: ModelContext) {
    }
}
