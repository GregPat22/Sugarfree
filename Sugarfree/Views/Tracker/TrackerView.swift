import SwiftUI
import SwiftData

struct TrackerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FoodEntry.timestamp, order: .reverse) private var entries: [FoodEntry]

    @State private var showAddEntry = false

    private var groupedEntries: [(String, [FoodEntry])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: entries) { entry in
            calendar.startOfDay(for: entry.timestamp)
        }
        return grouped
            .sorted { $0.key > $1.key }
            .map { (dateKey, items) in
                let label = dateLabel(for: dateKey)
                return (label, items.sorted { $0.timestamp > $1.timestamp })
            }
    }

    var body: some View {
        NavigationStack {
            Group {
                if entries.isEmpty {
                    ContentUnavailableView(
                        "No entries yet",
                        systemImage: "fork.knife",
                        description: Text("Tap + to log your first food item.")
                    )
                } else {
                    List {
                        ForEach(groupedEntries, id: \.0) { section in
                            Section {
                                ForEach(section.1) { entry in
                                    entryRow(entry)
                                }
                                .onDelete { offsets in
                                    deleteEntries(offsets, from: section.1)
                                }
                            } header: {
                                HStack {
                                    Text(section.0)
                                    Spacer()
                                    let total = section.1.reduce(0.0) { $0 + $1.sugarGrams }
                                    Text(String(format: String(localized: "%.1fg total"), total))
                                        .font(.caption.monospacedDigit())
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Sugar Log")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddEntry = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddEntry) {
                ManualEntryForm()
            }
        }
    }

    private func entryRow(_ entry: FoodEntry) -> some View {
        HStack(spacing: 12) {
            Image(systemName: entry.isManualEntry ? "pencil.circle.fill" : "barcode.viewfinder")
                .font(.title3)
                .foregroundStyle(entry.isManualEntry ? .blue : .green)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.name)
                    .font(.subheadline.weight(.medium))

                HStack(spacing: 4) {
                    if let brand = entry.brand {
                        Text(brand)
                    }
                    if let serving = entry.servingSize {
                        if entry.brand != nil { Text("·") }
                        Text(serving)
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(entry.sugarGrams, specifier: "%.1f")g")
                    .font(.subheadline.monospacedDigit().weight(.semibold))
                    .foregroundStyle(entry.sugarGrams > 10 ? .red : .primary)

                Text(entry.timestamp, format: .dateTime.hour().minute())
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 2)
    }

    private func deleteEntries(_ offsets: IndexSet, from sectionEntries: [FoodEntry]) {
        for index in offsets {
            modelContext.delete(sectionEntries[index])
        }
    }

    private func dateLabel(for date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return String(localized: "Today") }
        if calendar.isDateInYesterday(date) { return String(localized: "Yesterday") }
        return date.formatted(.dateTime.weekday(.wide).month().day())
    }
}

#Preview {
    TrackerView()
        .modelContainer(for: FoodEntry.self, inMemory: true)
}
