import SwiftUI
import SwiftData

@main
struct SugarfreeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            FoodEntry.self,
            DailyLog.self,
            SugarGoal.self,
            FeatureEvent.self
        ])
    }
}
