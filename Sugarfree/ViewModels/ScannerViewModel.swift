import Foundation
import SwiftData
import Observation

enum ScannerState: Equatable {
    case scanning
    case loading
    case found(name: String, brand: String?, sugarGrams: Double?, servingSize: String?)
    case notFound(barcode: String)
    case error(String)
}

@MainActor
@Observable
final class ScannerViewModel {
    var state: ScannerState = .scanning
    var showManualEntry = false

    private let service = OpenFoodFactsService()

    var isScanning: Bool {
        state == .scanning
    }

    func lookupBarcode(_ barcode: String) async {
        state = .loading

        do {
            let result = try await service.fetchProduct(barcode: barcode)

            guard let product = result.product, result.status == 1 else {
                state = .notFound(barcode: barcode)
                return
            }

            state = .found(
                name: product.productName ?? "Unknown Product",
                brand: product.brands,
                sugarGrams: product.nutriments?.bestSugarEstimateGrams,
                servingSize: product.servingSize
            )
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
        context: ModelContext
    ) {
        let entry = FoodEntry(
            name: name,
            brand: brand,
            barcode: barcode,
            sugarGrams: sugarGrams,
            servingSize: servingSize,
            isManualEntry: false
        )
        context.insert(entry)
        reset()
    }

    func reset() {
        state = .scanning
        showManualEntry = false
    }
}
