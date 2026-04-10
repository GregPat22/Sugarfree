import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class GoalsViewModel {
    var dailyLimit: Double = 25.0
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var hasActiveGoal = false
    var startDate: Date = .now
    var daysOnPlan: Int = 0
    var insuranceCredits: Int = 0

    func loadGoal(context: ModelContext) {
        let predicate = #Predicate<SugarGoal> { $0.isActive }
        let descriptor = FetchDescriptor(predicate: predicate)

        if let goal = try? context.fetch(descriptor).first {
            dailyLimit = goal.dailyLimitGrams
            currentStreak = goal.currentStreakDays
            longestStreak = goal.longestStreakDays
            insuranceCredits = goal.streakInsuranceCredits
            startDate = goal.startDate
            hasActiveGoal = true

            let days = Calendar.current.dateComponents([.day], from: goal.startDate, to: .now).day ?? 0
            daysOnPlan = max(0, days)
        } else {
            createDefaultGoal(context: context)
        }
    }

    func updateLimit(_ newLimit: Double, context: ModelContext) {
        dailyLimit = newLimit

        let predicate = #Predicate<SugarGoal> { $0.isActive }
        let descriptor = FetchDescriptor(predicate: predicate)

        if let goal = try? context.fetch(descriptor).first {
            goal.dailyLimitGrams = newLimit
        }
    }

    func claimInsuranceProgress(context: ModelContext) {
        let predicate = #Predicate<SugarGoal> { $0.isActive }
        let descriptor = FetchDescriptor(predicate: predicate)
        guard let goal = try? context.fetch(descriptor).first else { return }

        let target = max(1, goal.currentStreakDays / 10)
        if goal.streakInsuranceCredits < target {
            goal.streakInsuranceCredits = target
            insuranceCredits = target
        }
    }

    func useInsurance(context: ModelContext) -> Bool {
        let predicate = #Predicate<SugarGoal> { $0.isActive }
        let descriptor = FetchDescriptor(predicate: predicate)
        guard let goal = try? context.fetch(descriptor).first,
              goal.streakInsuranceCredits > 0 else {
            return false
        }

        goal.streakInsuranceCredits -= 1
        goal.streakInsuranceUses += 1
        insuranceCredits = goal.streakInsuranceCredits
        context.insert(FeatureEvent(name: "insurance_used", metadata: "manual_use"))
        return true
    }

    func resetStreak(context: ModelContext) {
        let predicate = #Predicate<SugarGoal> { $0.isActive }
        let descriptor = FetchDescriptor(predicate: predicate)

        if let goal = try? context.fetch(descriptor).first {
            goal.currentStreakDays = 0
            goal.startDate = .now
            currentStreak = 0
            startDate = .now
            daysOnPlan = 0
        }
    }

    private func createDefaultGoal(context: ModelContext) {
        let goal = SugarGoal(dailyLimitGrams: 25.0)
        context.insert(goal)
        dailyLimit = 25.0
        hasActiveGoal = true
        startDate = goal.startDate
        daysOnPlan = 0
        insuranceCredits = 0
    }
}
