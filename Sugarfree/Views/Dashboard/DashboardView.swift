import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = DashboardViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // TODO: Sugar ring/gauge showing today's intake vs limit
                    // TODO: Streak counter
                    // TODO: Recent entries list
                    ContentUnavailableView(
                        "Dashboard",
                        systemImage: "chart.bar.fill",
                        description: Text("Your daily sugar overview will appear here.")
                    )
                }
                .padding()
            }
            .navigationTitle("Sugarfree")
            .onAppear {
                viewModel.loadTodayData(context: modelContext)
            }
        }
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: FoodEntry.self, inMemory: true)
}
