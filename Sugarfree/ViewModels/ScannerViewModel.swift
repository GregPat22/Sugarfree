import Foundation
import SwiftData
import Observation

enum ScannerState: Equatable {
    case scanning
    case loading
    case found(
        name: String,
        brand: String?,
        barcode: String,
        sugarGrams: Double?,
        servingSize: String?,
        categoryTags: [String]
    )
    case notFound(barcode: String)
    case error(String)
}

@MainActor
@Observable
final class ScannerViewModel {
    var state: ScannerState = .scanning
    var showManualEntry = false
    var todaySugarGrams: Double = 0
    var dailyLimitGrams: Double = 25
    var rescueModeMessage: String?

    private let service = OpenFoodFactsService()
    private let swapEngine = SmartSwapEngine()

    var isScanning: Bool {
        state == .scanning
    }

    var currentRiskLevel: String {
        let fraction = dailyLimitGrams > 0 ? todaySugarGrams / dailyLimitGrams : 0
        if fraction >= 1.0 { return "high" }
        if fraction >= 0.75 { return "medium" }
        return "low"
    }

    func suggestions(
        productName: String,
        categoryTags: [String],
        sugarGrams: Double?
    ) -> [SwapSuggestion] {
        swapEngine.suggestions(for: productName, categoryTags: categoryTags, sugarGrams: sugarGrams)
    }

    func predictedRemaining(after addingSugar: Double) -> Double {
        dailyLimitGrams - (todaySugarGrams + addingSugar)
    }

    func streakRiskText(for addedSugar: Double) -> String {
        let remaining = predictedRemaining(after: addedSugar)
        if remaining < 0 { return "High streak risk" }
        if remaining < 5 { return "Medium streak risk" }
        return "Low streak risk"
    }

    func lookupBarcode(_ barcode: String, context: ModelContext) async {
        state = .loading

        do {
            let result = try await service.fetchProduct(barcode: barcode)
            loadDailyBudget(context: context)

            guard let product = result.product, result.status == 1 else {
                state = .notFound(barcode: barcode)
                EventLogger.log(.scanNotFound, metadata: barcode, context: context)
                return
            }

            state = .found(
                name: product.productName ?? "Unknown Product",
                brand: product.brands,
                barcode: barcode,
                sugarGrams: product.nutriments?.bestSugarEstimateGrams,
                servingSize: product.servingSize,
                categoryTags: product.categoriesTags ?? []
            )
            EventLogger.log(.scanFound, metadata: product.productName, context: context)
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func saveEntry(
        name: String,
        brand: String?,
        barcode: String?,
        sugarGrams: Double,
        servingSize: String?,
        swapUsed: Bool,
        context: ModelContext
    ) {
        let remaining = predictedRemaining(after: sugarGrams)
        let entry = FoodEntry(
            name: name,
            brand: brand,
            barcode: barcode,
            sugarGrams: sugarGrams,
            servingSize: servingSize,
            isManualEntry: false,
            swapRecommendationUsed: swapUsed,
            predictedRemainingAfterEntry: remaining,
            riskAtLogTime: streakRiskText(for: sugarGrams)
        )
        context.insert(entry)
        EventLogger.log(.entrySaved, metadata: "scan:\(swapUsed)", context: context)
        reset()
    }

    func startRescueMode(context: ModelContext) {
        let options = [
            "Take 90 seconds. Drink water first, then decide.",
            "Try a protein snack first and re-check craving in 10 minutes.",
            "Pick one Smart Swap option to protect today’s streak."
        ]
        rescueModeMessage = options.randomElement()
        EventLogger.log(.rescueStarted, metadata: currentRiskLevel, context: context)
    }

    func reset() {
        state = .scanning
        showManualEntry = false
    }

    private func loadDailyBudget(context: ModelContext) {
        let startOfDay = Calendar.current.startOfDay(for: .now)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) ?? .now

        let dayPredicate = #Predicate<FoodEntry> { entry in
            entry.timestamp >= startOfDay && entry.timestamp < endOfDay
        }
        let dayDescriptor = FetchDescriptor(predicate: dayPredicate)
        let todayEntries = (try? context.fetch(dayDescriptor)) ?? []
        todaySugarGrams = todayEntries.reduce(0) { $0 + $1.sugarGrams }

        let goalPredicate = #Predicate<SugarGoal> { $0.isActive }
        let goalDescriptor = FetchDescriptor(predicate: goalPredicate)
        if let goal = try? context.fetch(goalDescriptor).first {
            dailyLimitGrams = goal.dailyLimitGrams
        }
    }
}
