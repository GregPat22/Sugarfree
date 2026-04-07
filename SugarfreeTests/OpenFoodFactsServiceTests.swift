import Testing
import Foundation
@testable import Sugarfree

@Suite("OpenFoodFacts API Models")
struct OpenFoodFactsServiceTests {
    @Test("Decodes a valid product response")
    func decodeValidProduct() throws {
        let json = """
        {
            "status": 1,
            "product": {
                "product_name": "Coca-Cola",
                "brands": "Coca-Cola",
                "serving_size": "330ml",
                "nutriments": {
                    "sugars_100g": 10.6,
                    "sugars_serving": 35.0,
                    "sugars_unit": "g"
                }
            }
        }
        """.data(using: .utf8)!

        let result = try JSONDecoder().decode(ProductResult.self, from: json)
        #expect(result.status == 1)
        #expect(result.product?.productName == "Coca-Cola")
        #expect(result.product?.nutriments?.sugarsServing == 35.0)
        #expect(result.product?.nutriments?.bestSugarEstimateGrams == 35.0)
    }

    @Test("bestSugarEstimateGrams falls back to per-100g")
    func fallbackTo100g() throws {
        let json = """
        {
            "status": 1,
            "product": {
                "product_name": "Test Product",
                "nutriments": {
                    "sugars_100g": 8.5,
                    "sugars_unit": "g"
                }
            }
        }
        """.data(using: .utf8)!

        let result = try JSONDecoder().decode(ProductResult.self, from: json)
        #expect(result.product?.nutriments?.bestSugarEstimateGrams == 8.5)
    }

    @Test("Handles missing nutriments gracefully")
    func missingNutriments() throws {
        let json = """
        {
            "status": 1,
            "product": {
                "product_name": "Unknown Food"
            }
        }
        """.data(using: .utf8)!

        let result = try JSONDecoder().decode(ProductResult.self, from: json)
        #expect(result.product?.nutriments == nil)
    }
}
