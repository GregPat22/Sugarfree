import SwiftUI

struct ProductResultCard: View {
    let name: String
    let brand: String?
    let sugarGrams: Double?
    let servingSize: String?
    let onSave: (Double) -> Void
    let onManualEntry: () -> Void
    let onRescan: () -> Void

    @State private var manualSugar: String = ""

    private var hasSugarData: Bool { sugarGrams != nil }

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 4) {
                Text(name)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)

                if let brand {
                    Text(brand)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            if let sugar = sugarGrams {
                sugarDisplay(grams: sugar)
            } else {
                noSugarDataView
            }

            if let servingSize {
                Text("Serving: \(servingSize)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                Button("Scan Again", action: onRescan)
                    .buttonStyle(.bordered)

                if let sugar = sugarGrams {
                    Button("Add to Log") { onSave(sugar) }
                        .buttonStyle(.borderedProminent)
                } else {
                    Button("Enter Manually", action: onManualEntry)
                        .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding(24)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
        .padding()
    }

    private func sugarDisplay(grams: Double) -> some View {
        VStack(spacing: 4) {
            Text("\(grams, specifier: "%.1f")g")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(grams > 10 ? .red : .green)
            Text("sugar per serving")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var noSugarDataView: some View {
        VStack(spacing: 4) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title)
                .foregroundStyle(.orange)
            Text("Sugar data not available")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
