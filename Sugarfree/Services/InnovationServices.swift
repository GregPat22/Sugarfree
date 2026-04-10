import Foundation
import SwiftData

struct SwapSuggestion: Hashable {
    let title: String
    let detail: String
    let estimatedSugarGrams: Double
}

struct SmartSwapEngine {
    func suggestions(
        for productName: String,
        categoryTags: [String],
        sugarGrams: Double?
    ) -> [SwapSuggestion] {
        guard let sugarGrams, sugarGrams >= 6 else { return [] }
        let categories = categoryTags.map { $0.lowercased() }.joined(separator: " ")
        let lowerName = productName.lowercased()

        if categories.contains("breakfast-cereal") || lowerName.contains("cereal") {
            return [
                SwapSuggestion(title: "Plain Oats", detail: "High fiber, add fruit yourself", estimatedSugarGrams: 1.0),
                SwapSuggestion(title: "Unsweetened Muesli", detail: "Crunchy without syrup coating", estimatedSugarGrams: 2.5),
                SwapSuggestion(title: "Chia Pudding Base", detail: "Add cinnamon for sweetness perception", estimatedSugarGrams: 3.0)
            ]
        }

        if categories.contains("yogurt") || lowerName.contains("yogurt") {
            return [
                SwapSuggestion(title: "Plain Greek Yogurt", detail: "Protein-rich base, add berries", estimatedSugarGrams: 4.0),
                SwapSuggestion(title: "Skyr Unsweetened", detail: "Thicker texture and lower sugar", estimatedSugarGrams: 3.5),
                SwapSuggestion(title: "Natural Kefir", detail: "Tangy profile, often lower added sugar", estimatedSugarGrams: 4.5)
            ]
        }

        if categories.contains("soft-drinks") || lowerName.contains("soda") || lowerName.contains("cola") {
            return [
                SwapSuggestion(title: "Sparkling Water + Citrus", detail: "Similar fizz without sugar hit", estimatedSugarGrams: 0.0),
                SwapSuggestion(title: "Unsweetened Iced Tea", detail: "Cold and flavorful without syrup", estimatedSugarGrams: 0.0),
                SwapSuggestion(title: "Diet Soda", detail: "Closest flavor transition", estimatedSugarGrams: 0.0)
            ]
        }

        return [
            SwapSuggestion(title: "No Added Sugar Option", detail: "Look for 'unsweetened' on front label", estimatedSugarGrams: max(0, sugarGrams * 0.2)),
            SwapSuggestion(title: "Half-Portion Strategy", detail: "Pair with protein to flatten cravings", estimatedSugarGrams: sugarGrams * 0.5),
            SwapSuggestion(title: "Whole Food Alternative", detail: "Swap processed snack for fruit + nuts", estimatedSugarGrams: 5.0)
        ]
    }
}

enum EventName: String {
    case scanFound = "scan_found"
    case scanNotFound = "scan_not_found"
    case swapShown = "swap_shown"
    case swapTapped = "swap_tapped"
    case entrySaved = "entry_saved"
    case rescueStarted = "rescue_started"
    case insuranceUsed = "insurance_used"
}

enum EventLogger {
    static func log(_ name: EventName, metadata: String? = nil, context: ModelContext) {
        context.insert(FeatureEvent(name: name.rawValue, metadata: metadata))
    }
}
