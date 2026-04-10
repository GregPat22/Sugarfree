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
    var scanToLogConversion: Double = 0
    var swapAdoptionRate: Double = 0
    var weeklyRetentionProxy: Int = 0
    var streakRecoveryRate: Double = 0
    var avgDailySugar7d: Double = 0
    private var hasLoggedToday = false

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

    var predictiveBudgetMessage: String {
        let projectedRemaining = remainingGrams - 6 // default snack simulation
        if projectedRemaining >= 0 {
            return String(format: "If your next snack is ~6g sugar, you'll still have %.1fg left.", projectedRemaining)
        }
        return String(format: "A ~6g snack now would push today over by %.1fg.", -projectedRemaining)
    }

    func loadTodayData(context: ModelContext) {
        loadTodayEntries(context: context)
        loadGoal(context: context)
        calculateStreak(context: context)
        refreshDailyLog(context: context)
        loadMetrics(context: context)
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
            hasLoggedToday = !entries.isEmpty
        } catch {
            recentEntries = []
            todaySugarGrams = 0
            hasLoggedToday = false
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

        // Streak policy: today counts only if user has logged at least one entry and stayed under limit.
        let todayUnder = todaySugarGrams <= goal.dailyLimitGrams
        if todayUnder && hasLoggedToday {
            streak += 1
        }

        currentStreak = streak
        goal.currentStreakDays = streak
        if streak > goal.longestStreakDays {
            goal.longestStreakDays = streak
            longestStreak = streak
        }
    }

    private func refreshDailyLog(context: ModelContext) {
        let dayStart = Calendar.current.startOfDay(for: .now)
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: dayStart) ?? .now

        let predicate = #Predicate<DailyLog> { log in
            log.date >= dayStart && log.date < nextDay
        }
        let descriptor = FetchDescriptor(predicate: predicate)
        let dayLog = (try? context.fetch(descriptor).first) ?? DailyLog(date: dayStart)

        dayLog.totalSugarGrams = todaySugarGrams
        dayLog.entryCount = recentEntries.count
        dayLog.metGoal = !isOverLimit
        dayLog.forecastRemainingGrams = remainingGrams - 6
        dayLog.riskLevel = isOverLimit ? "high" : (remainingGrams < 5 ? "medium" : "low")

        if dayLog.modelContext == nil {
            context.insert(dayLog)
        }
    }

    private func loadMetrics(context: ModelContext) {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: .now) ?? .now
        let eventPredicate = #Predicate<FeatureEvent> { event in
            event.timestamp >= sevenDaysAgo
        }
        let events = (try? context.fetch(FetchDescriptor(predicate: eventPredicate))) ?? []

        let scans = Double(events.filter { $0.name == EventName.scanFound.rawValue }.count)
        let logs = Double(events.filter { $0.name == EventName.entrySaved.rawValue }.count)
        let swapsShown = Double(events.filter { $0.name == EventName.swapShown.rawValue }.count)
        let swapsTapped = Double(events.filter { $0.name == EventName.swapTapped.rawValue }.count)
        let rescues = Double(events.filter { $0.name == EventName.rescueStarted.rawValue }.count)
        let recoveries = Double(events.filter { $0.name == EventName.insuranceUsed.rawValue }.count)

        scanToLogConversion = scans > 0 ? logs / scans : 0
        swapAdoptionRate = swapsShown > 0 ? swapsTapped / swapsShown : 0
        weeklyRetentionProxy = Set(events.map { Calendar.current.startOfDay(for: $0.timestamp) }).count
        streakRecoveryRate = rescues > 0 ? recoveries / rescues : 0

        let logPredicate = #Predicate<DailyLog> { log in
            log.date >= sevenDaysAgo
        }
        let recentLogs = (try? context.fetch(FetchDescriptor(predicate: logPredicate))) ?? []
        let total = recentLogs.reduce(0.0) { $0 + $1.totalSugarGrams }
        avgDailySugar7d = recentLogs.isEmpty ? 0 : total / Double(recentLogs.count)
    }
}
