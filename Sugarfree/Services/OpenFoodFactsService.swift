import Foundation

struct OpenFoodFactsService: Sendable {
    private let baseURL = URL(string: "https://world.openfoodfacts.org/api/v2")!

    func fetchProduct(barcode: String) async throws -> ProductResult {
        let url = baseURL
            .appendingPathComponent("product")
            .appendingPathComponent(barcode)
            .appending(queryItems: [
                URLQueryItem(name: "fields", value: "product_name,brands,nutriments,serving_size")
            ])

        var request = URLRequest(url: url)
        request.setValue("Sugarfree iOS App", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw OpenFoodFactsError.productNotFound
        }

        return try JSONDecoder().decode(ProductResult.self, from: data)
    }
}

enum OpenFoodFactsError: LocalizedError {
    case productNotFound
    case networkError
    case decodingError

    var errorDescription: String? {
        switch self {
        case .productNotFound: "Product not found in the database."
        case .networkError: "Unable to connect. Check your internet connection."
        case .decodingError: "Unexpected response format."
        }
    }
}
