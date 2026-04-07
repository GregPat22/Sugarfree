import Foundation
import SwiftData
import Observation

@Observable
final class GoalsViewModel {
    var dailyLimit: Double = 25.0
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var hasActiveGoal = false

    // TODO: Load the active SugarGoal from SwiftData
    func loadGoal(context: ModelContext) {
    }

    // TODO: Create or update the user's sugar goal
    func saveGoal(limit: Double, context: ModelContext) {
    }

    // TODO: Recalculate streak based on DailyLog history
    func recalculateStreak(context: ModelContext) {
    }
}
