import SwiftUI
import SwiftData

struct GoalsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = GoalsViewModel()
    @State private var showResetConfirmation = false

    private let limitRange: ClosedRange<Double> = 0...100
    private let limitStep: Double = 5

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(spacing: 16) {
                        Text("\(viewModel.dailyLimit, specifier: "%.0f")g")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(colorForLimit(viewModel.dailyLimit))
                            .contentTransition(.numericText())
                            .animation(.snappy, value: viewModel.dailyLimit)

                        Text("daily sugar limit")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Slider(value: $viewModel.dailyLimit, in: limitRange, step: limitStep) {
                            Text("Daily limit")
                        } minimumValueLabel: {
                            Text("0g")
                                .font(.caption2)
                        } maximumValueLabel: {
                            Text("100g")
                                .font(.caption2)
                        }
                        .onChange(of: viewModel.dailyLimit) { _, newValue in
                            viewModel.updateLimit(newValue, context: modelContext)
                        }

                        Text("WHO recommends under 25g of added sugar per day")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 8)
                }

                Section("Streaks") {
                    HStack {
                        Label("Current Streak", systemImage: "flame.fill")
                            .foregroundStyle(.orange)
                        Spacer()
                        Text(streakText(viewModel.currentStreak))
                            .font(.headline.monospacedDigit())
                    }

                    HStack {
                        Label("Longest Streak", systemImage: "trophy.fill")
                            .foregroundStyle(.yellow)
                        Spacer()
                        Text(streakText(viewModel.longestStreak))
                            .font(.headline.monospacedDigit())
                    }
                }

                Section("Journey") {
                    LabeledContent("Started") {
                        Text(viewModel.startDate, format: .dateTime.month().day().year())
                    }
                    LabeledContent("Days on plan") {
                        Text("\(viewModel.daysOnPlan)")
                            .monospacedDigit()
                    }
                }

                Section {
                    Button("Reset Streak & Start Over", role: .destructive) {
                        showResetConfirmation = true
                    }
                }
            }
            .navigationTitle("Goals")
            .onAppear {
                viewModel.loadGoal(context: modelContext)
            }
            .confirmationDialog(
                "Reset your streak?",
                isPresented: $showResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Reset", role: .destructive) {
                    viewModel.resetStreak(context: modelContext)
                }
            } message: {
                Text("This will reset your current streak and start date. Your longest streak record is kept.")
            }
        }
    }

    private func colorForLimit(_ limit: Double) -> Color {
        if limit <= 25 { return .green }
        if limit <= 50 { return .orange }
        return .red
    }

    private func streakText(_ days: Int) -> String {
        days == 1 ? "1 day" : "\(days) days"
    }
}

#Preview {
    GoalsView()
        .modelContainer(for: [SugarGoal.self, FoodEntry.self], inMemory: true)
}
