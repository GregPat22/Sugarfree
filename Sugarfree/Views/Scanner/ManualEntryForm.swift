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

    @FocusState private var focusedField: Field?

    private enum Field { case name, brand, sugar, serving, notes }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
        && Double(sugarGrams) != nil
        && (Double(sugarGrams) ?? -1) >= 0
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
                if name.isEmpty { focusedField = .name }
                else { focusedField = .sugar }
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
            notes: notes.isEmpty ? nil : notes
        )
        modelContext.insert(entry)
        dismiss()
    }
}

#Preview {
    ManualEntryForm()
        .modelContainer(for: FoodEntry.self, inMemory: true)
}
