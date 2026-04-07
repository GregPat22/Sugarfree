import SwiftUI
import SwiftData

struct GoalsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = GoalsViewModel()

    var body: some View {
        NavigationStack {
            Form {
                Section("Daily Sugar Limit") {
                    // TODO: Stepper or slider to set daily gram limit
                    // Default: 25g (WHO recommendation for added sugars)
                    Text("\(viewModel.dailyLimit, specifier: "%.0f")g per day")
                }

                Section("Streak") {
                    LabeledContent("Current Streak") {
                        Text("\(viewModel.currentStreak) days")
                    }
                    LabeledContent("Longest Streak") {
                        Text("\(viewModel.longestStreak) days")
                    }
                }

                // TODO: Weekly/monthly history chart
                // TODO: Achievement badges
            }
            .navigationTitle("Goals")
            .onAppear {
                viewModel.loadGoal(context: modelContext)
            }
        }
    }
}

#Preview {
    GoalsView()
        .modelContainer(for: SugarGoal.self, inMemory: true)
}
