import Foundation
import Observation

@Observable
final class ScannerViewModel {
    var scannedBarcode: String?
    var productName: String?
    var sugarGrams: Double?
    var isLoading = false
    var errorMessage: String?
    var showManualEntry = false

    private let service = OpenFoodFactsService()

    // TODO: Call service.fetchProduct, parse sugar content, handle errors
    func lookupBarcode(_ barcode: String) async {
        scannedBarcode = barcode
        isLoading = true
        errorMessage = nil

        do {
            let result = try await service.fetchProduct(barcode: barcode)
            productName = result.product?.productName
            sugarGrams = result.product?.nutriments?.bestSugarEstimateGrams
            if sugarGrams == nil {
                showManualEntry = true
            }
        } catch {
            errorMessage = error.localizedDescription
            showManualEntry = true
        }

        isLoading = false
    }

    func reset() {
        scannedBarcode = nil
        productName = nil
        sugarGrams = nil
        isLoading = false
        errorMessage = nil
        showManualEntry = false
    }
}
