import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = DashboardViewModel()
    @State private var showAddEntry = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    SugarGauge(
                        consumed: viewModel.todaySugarGrams,
                        limit: viewModel.dailyLimitGrams
                    )
                    .padding(.top, 8)

                    streakSection

                    recentEntriesSection
                }
                .padding()
            }
            .navigationTitle("Sugarfree")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddEntry = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddEntry, onDismiss: { refresh() }) {
                ManualEntryForm()
            }
            .onAppear { refresh() }
        }
    }

    private var streakSection: some View {
        HStack(spacing: 32) {
            StreakBadge(days: viewModel.currentStreak, label: "Current")
            StreakBadge(days: viewModel.longestStreak, label: "Best")
        }
    }

    @ViewBuilder
    private var recentEntriesSection: some View {
        if !viewModel.recentEntries.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Today")
                    .font(.headline)

                ForEach(viewModel.recentEntries) { entry in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(entry.name)
                                .font(.subheadline.weight(.medium))
                            if let brand = entry.brand {
                                Text(brand)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Spacer()

                        Text("\(entry.sugarGrams, specifier: "%.1f")g")
                            .font(.subheadline.monospacedDigit().weight(.semibold))
                            .foregroundStyle(entry.sugarGrams > 10 ? .red : .primary)

                        Text(entry.timestamp, format: .dateTime.hour().minute())
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.vertical, 6)

                    if entry.id != viewModel.recentEntries.last?.id {
                        Divider()
                    }
                }
            }
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }

    private func refresh() {
        viewModel.loadTodayData(context: modelContext)
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: [FoodEntry.self, SugarGoal.self], inMemory: true)
}
