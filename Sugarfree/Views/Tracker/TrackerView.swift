import SwiftUI
import SwiftData

struct TrackerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FoodEntry.timestamp, order: .reverse) private var entries: [FoodEntry]

    @State private var showAddEntry = false

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
                        // TODO: Group entries by date, show sugar per entry
                        ForEach(entries) { entry in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(entry.name)
                                        .font(.headline)
                                    if let brand = entry.brand {
                                        Text(brand)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                                Text("\(entry.sugarGrams, specifier: "%.1f")g")
                                    .font(.title3.monospacedDigit())
                                    .foregroundStyle(entry.sugarGrams > 10 ? .red : .primary)
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
                // TODO: Manual entry form
                Text("Add Entry Form")
            }
        }
    }
}

#Preview {
    TrackerView()
        .modelContainer(for: FoodEntry.self, inMemory: true)
}
