import SwiftUI

struct ProductResultCard: View {
    let name: String
    let brand: String?
    let sugarGrams: Double?
    let servingSize: String?
    let suggestions: [SwapSuggestion]
    let remainingBudgetText: String?
    let riskText: String?
    let onSave: (Double) -> Void
    let onUseSwap: (String, Double) -> Void
    let onManualEntry: () -> Void
    let onRescan: () -> Void
    var onSuggestionsShown: (() -> Void)?

    @State private var servings: Double = 1.0
    @State private var didReportSuggestions = false

    private var hasSugarData: Bool { sugarGrams != nil }

    private var adjustedSugar: Double? {
        guard let base = sugarGrams else { return nil }
        return base * servings
    }

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
                sugarDisplay(perServing: sugar)
            } else {
                noSugarDataView
            }

            if let remainingBudgetText {
                Text(remainingBudgetText)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            if let riskText {
                Text(riskText)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(isHighRisk(riskText) ? .red : .orange)
            }

            if sugarGrams != nil {
                servingsControl
            }

            if let servingSize {
                Text(String(format: String(localized: "Serving: %@"), servingSize))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if !suggestions.isEmpty {
                smartSwapSection
            }

            HStack(spacing: 12) {
                Button("Scan Again", action: onRescan)
                    .buttonStyle(.bordered)

                if let total = adjustedSugar {
                    Button(String(format: String(localized: "Add %.1fg"), total)) { onSave(total) }
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
        .onAppear {
            guard !suggestions.isEmpty, !didReportSuggestions else { return }
            didReportSuggestions = true
            onSuggestionsShown?()
        }
    }

    // MARK: - Servings Control

    private var servingsControl: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Servings")
                    .font(.subheadline.weight(.medium))

                Spacer()

                HStack(spacing: 16) {
                    Button {
                        withAnimation { servings = max(0.25, servings - 0.25) }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(servings <= 0.25 ? .gray : .primary)
                    }
                    .disabled(servings <= 0.25)

                    Text("\(servings, specifier: servings.truncatingRemainder(dividingBy: 1) == 0 ? "%.0f" : "%.2g")")
                        .font(.title3.weight(.semibold).monospacedDigit())
                        .frame(minWidth: 36)

                    Button {
                        withAnimation { servings += 0.25 }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }

            presetButtons
        }
    }

    private var presetButtons: some View {
        HStack(spacing: 8) {
            ForEach([0.5, 1.0, 1.5, 2.0], id: \.self) { value in
                Button {
                    withAnimation { servings = value }
                } label: {
                    Text(value.truncatingRemainder(dividingBy: 1) == 0
                         ? "\(Int(value))"
                         : "\(value, specifier: "%.1f")")
                        .font(.caption.weight(.medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(servings == value ? Color.accentColor : Color.secondary.opacity(0.15),
                                    in: Capsule())
                        .foregroundStyle(servings == value ? .white : .primary)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Sugar Display

    private func sugarDisplay(perServing: Double) -> some View {
        VStack(spacing: 4) {
            let total = perServing * servings
            Text("\(total, specifier: "%.1f")g")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(total > 10 ? .red : .green)
                .contentTransition(.numericText())

            if servings != 1.0 {
                Text("\(perServing, specifier: "%.1f")g × \(servings, specifier: servings.truncatingRemainder(dividingBy: 1) == 0 ? "%.0f" : "%.2g") servings")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("sugar per serving")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
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

    private var smartSwapSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Better Options", systemImage: "sparkles")
                .font(.headline)

            ForEach(Array(suggestions.enumerated()), id: \.offset) { _, suggestion in
                Button {
                    onUseSwap(suggestion.title, suggestion.estimatedSugarGrams)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(suggestion.title)
                                .font(.subheadline.weight(.semibold))
                            Text(suggestion.detail)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text("\(suggestion.estimatedSugarGrams, specifier: "%.1f")g")
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.green)
                    }
                    .padding(10)
                    .background(Color.secondary.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func isHighRisk(_ text: String) -> Bool {
        let lower = text.lowercased()
        return lower.contains("high") || lower.contains("alto")
    }
}
