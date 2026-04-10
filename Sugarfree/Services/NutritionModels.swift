import Foundation

struct ProductResult: Decodable {
    let status: Int
    let product: Product?
}

struct Product: Decodable {
    let productName: String?
    let brands: String?
    let servingSize: String?
    let nutriments: Nutriments?
    let categoriesTags: [String]?

    enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case brands
        case servingSize = "serving_size"
        case nutriments
        case categoriesTags = "categories_tags"
    }
}

struct Nutriments: Decodable {
    let sugars100g: Double?
    let sugarsServing: Double?
    let sugarsUnit: String?

    enum CodingKeys: String, CodingKey {
        case sugars100g = "sugars_100g"
        case sugarsServing = "sugars_serving"
        case sugarsUnit = "sugars_unit"
    }

    /// Best available sugar value in grams, preferring per-serving over per-100g.
    var bestSugarEstimateGrams: Double? {
        sugarsServing ?? sugars100g
    }
}
