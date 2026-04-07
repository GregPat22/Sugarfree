import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class DashboardViewModel {
    var todaySugarGrams: Double = 0
    var dailyLimitGrams: Double = 25.0
    var currentStreak: Int = 0
    var longestStreak: Int = 0
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

    func loadTodayData(context: ModelContext) {
        loadTodayEntries(context: context)
        loadGoal(context: context)
        calculateStreak(context: context)
    }

    private func loadTodayEntries(context: ModelContext) {
        let startOfDay = Calendar.current.startOfDay(for: .now)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        let predicate = #Predicate<FoodEntry> { entry in
            entry.timestamp >= startOfDay && entry.timestamp < endOfDay
        }

        var descriptor = FetchDescriptor(predicate: predicate, sortBy: [
            SortDescriptor(\FoodEntry.timestamp, order: .reverse)
        ])
        descriptor.fetchLimit = 50

        do {
            let entries = try context.fetch(descriptor)
            recentEntries = entries
            todaySugarGrams = entries.reduce(0) { $0 + $1.sugarGrams }
        } catch {
            recentEntries = []
            todaySugarGrams = 0
        }
    }

    private func loadGoal(context: ModelContext) {
        let predicate = #Predicate<SugarGoal> { $0.isActive }
        let descriptor = FetchDescriptor(predicate: predicate)

        if let goal = try? context.fetch(descriptor).first {
            dailyLimitGrams = goal.dailyLimitGrams
            currentStreak = goal.currentStreakDays
            longestStreak = goal.longestStreakDays
        }
    }

    private func calculateStreak(context: ModelContext) {
        let predicate = #Predicate<SugarGoal> { $0.isActive }
        guard let goal = try? context.fetch(FetchDescriptor(predicate: predicate)).first else { return }

        var streak = 0
        let calendar = Calendar.current
        var checkDate = calendar.startOfDay(for: Date.now.addingTimeInterval(-86400))

        while true {
            let nextDay = calendar.date(byAdding: .day, value: 1, to: checkDate)!
            let dayPredicate = #Predicate<FoodEntry> { entry in
                entry.timestamp >= checkDate && entry.timestamp < nextDay
            }

            guard let entries = try? context.fetch(FetchDescriptor(predicate: dayPredicate)) else { break }

            if entries.isEmpty { break }

            let dayTotal = entries.reduce(0.0) { $0 + $1.sugarGrams }
            if dayTotal > goal.dailyLimitGrams { break }

            streak += 1
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
        }

        let todayUnder = todaySugarGrams <= goal.dailyLimitGrams
        if todayUnder && todaySugarGrams > 0 {
            streak += 1
        }

        currentStreak = streak
        goal.currentStreakDays = streak
        if streak > goal.longestStreakDays {
            goal.longestStreakDays = streak
            longestStreak = streak
        }
    }
}
