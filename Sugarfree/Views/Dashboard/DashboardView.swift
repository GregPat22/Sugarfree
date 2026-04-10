import SwiftUI
import SwiftData

struct DashboardView: View {
    let refreshToken: UUID

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

                    predictiveBudgetSection

                    streakSection

                    recentEntriesSection

                    innovationMetricsSection
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
            .onChange(of: refreshToken) { _, _ in
                refresh()
            }
        }
    }

    private var streakSection: some View {
        HStack(spacing: 32) {
            StreakBadge(days: viewModel.currentStreak, label: "Current")
            StreakBadge(days: viewModel.longestStreak, label: "Best")
        }
    }

    private var predictiveBudgetSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Predictive Budget", systemImage: "calendar.badge.clock")
                .font(.headline)
            Text(viewModel.predictiveBudgetMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
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

    private var innovationMetricsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Innovation Metrics (7d)", systemImage: "chart.xyaxis.line")
                .font(.headline)

            metricRow("Scan -> Log Conversion", value: "\(viewModel.scanToLogConversion * 100, specifier: "%.0f")%")
            metricRow("Swap Adoption", value: "\(viewModel.swapAdoptionRate * 100, specifier: "%.0f")%")
            metricRow("Retention Proxy (active days)", value: "\(viewModel.weeklyRetentionProxy)")
            metricRow("Streak Recovery", value: "\(viewModel.streakRecoveryRate * 100, specifier: "%.0f")%")
            metricRow("Avg Daily Sugar", value: "\(viewModel.avgDailySugar7d, specifier: "%.1f")g")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func metricRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
            Spacer()
            Text(value)
                .font(.subheadline.monospacedDigit().weight(.semibold))
        }
    }

    private func refresh() {
        viewModel.loadTodayData(context: modelContext)
    }
}

#Preview {
    DashboardView(refreshToken: UUID())
        .modelContainer(for: [FoodEntry.self, SugarGoal.self, DailyLog.self, FeatureEvent.self], inMemory: true)
}
