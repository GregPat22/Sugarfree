import SwiftUI
import SwiftData

struct ManualEntryForm: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var prefillName: String?
    var prefillBrand: String?
    var prefillBarcode: String?

    @State private var name: String = ""
    @State private var brand: String = ""
    @State private var sugarGrams: String = ""
    @State private var servingSize: String = ""
    @State private var notes: String = ""
    @State private var currentDayTotal: Double = 0
    @State private var currentDailyLimit: Double = 25

    @FocusState private var focusedField: Field?

    private enum Field { case name, brand, sugar, serving, notes }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
        && Double(sugarGrams) != nil
        && (Double(sugarGrams) ?? -1) >= 0
    }

    private var predictedRemainingText: String? {
        guard let sugar = Double(sugarGrams), sugar >= 0 else { return nil }
        let remaining = currentDailyLimit - (currentDayTotal + sugar)
        if remaining >= 0 {
            return String(format: "After save: %.1fg left today", remaining)
        }
        return String(format: "After save: %.1fg over limit", -remaining)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Product") {
                    TextField("Product name", text: $name)
                        .focused($focusedField, equals: .name)
                    TextField("Brand (optional)", text: $brand)
                        .focused($focusedField, equals: .brand)
                }

                Section("Sugar Content") {
                    HStack {
                        TextField("Sugar (grams)", text: $sugarGrams)
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .sugar)
                        Text("g")
                            .foregroundStyle(.secondary)
                    }
                    TextField("Serving size (optional)", text: $servingSize)
                        .focused($focusedField, equals: .serving)

                    if let predictedRemainingText {
                        Text(predictedRemainingText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Notes") {
                    TextField("Optional notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                        .focused($focusedField, equals: .notes)
                }
            }
            .navigationTitle("Add Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .bold()
                        .disabled(!isValid)
                }
            }
            .onAppear {
                name = prefillName ?? ""
                brand = prefillBrand ?? ""
                if name.isEmpty { focusedField = .name } else { focusedField = .sugar }
                loadDayBudget()
            }
        }
    }

    private func save() {
        guard let sugar = Double(sugarGrams) else { return }

        let entry = FoodEntry(
            name: name.trimmingCharacters(in: .whitespaces),
            brand: brand.isEmpty ? nil : brand.trimmingCharacters(in: .whitespaces),
            barcode: prefillBarcode,
            sugarGrams: sugar,
            servingSize: servingSize.isEmpty ? nil : servingSize,
            isManualEntry: true,
            notes: notes.isEmpty ? nil : notes,
            predictedRemainingAfterEntry: currentDailyLimit - (currentDayTotal + sugar),
            riskAtLogTime: currentDailyLimit - (currentDayTotal + sugar) < 0 ? "high" : "low"
        )
        modelContext.insert(entry)
        EventLogger.log(.entrySaved, metadata: "manual", context: modelContext)
        dismiss()
    }

    private func loadDayBudget() {
        let startOfDay = Calendar.current.startOfDay(for: .now)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) ?? .now

        let entryPredicate = #Predicate<FoodEntry> { entry in
            entry.timestamp >= startOfDay && entry.timestamp < endOfDay
        }
        let entries = (try? modelContext.fetch(FetchDescriptor(predicate: entryPredicate))) ?? []
        currentDayTotal = entries.reduce(0) { $0 + $1.sugarGrams }

        let goalPredicate = #Predicate<SugarGoal> { $0.isActive }
        if let goal = try? modelContext.fetch(FetchDescriptor(predicate: goalPredicate)).first {
            currentDailyLimit = goal.dailyLimitGrams
        }
    }
}

#Preview {
    ManualEntryForm()
        .modelContainer(for: [FoodEntry.self, SugarGoal.self], inMemory: true)
}
