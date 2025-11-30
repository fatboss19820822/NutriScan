//
//  OpenFoodFactsService.swift
//  NutriScan
//
//  Service to fetch nutritional data from Open Food Facts API
//

import Foundation

// MARK: - Product Models

struct OpenFoodFactsResponse: Codable {
    let status: Int
    let product: Product?
}

struct Product: Codable {
    let productName: String?
    let brands: String?
    let imageUrl: String?
    let nutriments: Nutriments?
    let servingSize: String?
    let categories: String?
    
    enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case brands
        case imageUrl = "image_url"
        case nutriments
        case servingSize = "serving_size"
        case categories
    }
}

struct Nutriments: Codable {
    let energyKcal100g: Double?
    let proteins100g: Double?
    let carbohydrates100g: Double?
    let fat100g: Double?
    let fiber100g: Double?
    let sugars100g: Double?
    let salt100g: Double?
    let sodium100g: Double?
    
    enum CodingKeys: String, CodingKey {
        case energyKcal100g = "energy-kcal_100g"
        case proteins100g = "proteins_100g"
        case carbohydrates100g = "carbohydrates_100g"
        case fat100g = "fat_100g"
        case fiber100g = "fiber_100g"
        case sugars100g = "sugars_100g"
        case salt100g = "salt_100g"
        case sodium100g = "sodium_100g"
    }
}

// MARK: - Food Product Model (for our app)

struct FoodProduct {
    let barcode: String
    let name: String
    let brand: String
    let imageUrl: String?
    let servingSize: String
    let categories: String
    
    // Nutritional values (per 100g)
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let fiber: Double
    let sugar: Double
    let sodium: Double
    
    init(barcode: String, apiProduct: Product) {
        self.barcode = barcode
        self.name = apiProduct.productName ?? "Unknown Product"
        self.brand = apiProduct.brands ?? "Unknown Brand"
        self.imageUrl = apiProduct.imageUrl
        self.servingSize = apiProduct.servingSize ?? "100g"
        self.categories = apiProduct.categories ?? "Food"
        
        // Extract nutritional values (default to 0 if not available)
        self.calories = apiProduct.nutriments?.energyKcal100g ?? 0
        self.protein = apiProduct.nutriments?.proteins100g ?? 0
        self.carbs = apiProduct.nutriments?.carbohydrates100g ?? 0
        self.fat = apiProduct.nutriments?.fat100g ?? 0
        self.fiber = apiProduct.nutriments?.fiber100g ?? 0
        self.sugar = apiProduct.nutriments?.sugars100g ?? 0
        self.sodium = apiProduct.nutriments?.sodium100g ?? 0
    }
}

// MARK: - API Service

class OpenFoodFactsService {
    static let shared = OpenFoodFactsService()
    
    private let baseURL = "https://world.openfoodfacts.org/api/v0/product"
    private let session: URLSession
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
    }
    
    /// Fetch product information by barcode
    func fetchProduct(barcode: String, completion: @escaping (Result<FoodProduct, Error>) -> Void) {
        let urlString = "\(baseURL)/\(barcode).json"
        
        print("🔍 Fetching product from: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            completion(.failure(OpenFoodFactsError.invalidURL))
            return
        }
        
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid HTTP response")
                completion(.failure(OpenFoodFactsError.invalidResponse))
                return
            }
            
            print("📡 HTTP Status: \(httpResponse.statusCode)")
            
            guard httpResponse.statusCode == 200 else {
                print("❌ HTTP error: \(httpResponse.statusCode)")
                completion(.failure(OpenFoodFactsError.httpError(statusCode: httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                print("❌ No data received")
                completion(.failure(OpenFoodFactsError.noData))
                return
            }
            
            print("📦 Received \(data.count) bytes of data")
            
            // Debug: Print raw JSON
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📄 Raw JSON (first 500 chars): \(String(jsonString.prefix(500)))")
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(OpenFoodFactsResponse.self, from: data)
                
                print("✅ Decoded response - Status: \(response.status)")
                
                // Check if product was found
                guard response.status == 1, let product = response.product else {
                    print("❌ Product not found in database")
                    completion(.failure(OpenFoodFactsError.productNotFound))
                    return
                }
                
                print("✅ Product found: \(product.productName ?? "Unknown")")
                
                // Create our FoodProduct model
                let foodProduct = FoodProduct(barcode: barcode, apiProduct: product)
                completion(.success(foodProduct))
                
            } catch {
                print("❌ Decoding error: \(error)")
                completion(.failure(OpenFoodFactsError.decodingError(error)))
            }
        }
        
        task.resume()
        print("🚀 API request started")
    }
}

// MARK: - Custom Errors

enum OpenFoodFactsError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case noData
    case productNotFound
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .noData:
            return "No data received"
        case .productNotFound:
            return "Product not found in database. This barcode may not be registered yet."
        case .decodingError(let error):
            return "Error parsing data: \(error.localizedDescription)"
        }
    }
}

