import Foundation
import SwiftData

@Model
final class DailyLog {
    var date: Date
    var totalSugarGrams: Double
    var entryCount: Int
    var metGoal: Bool

    init(
        date: Date = .now,
        totalSugarGrams: Double = 0,
        entryCount: Int = 0,
        metGoal: Bool = true
    ) {
        self.date = date
        self.totalSugarGrams = totalSugarGrams
        self.entryCount = entryCount
        self.metGoal = metGoal
    }
}
