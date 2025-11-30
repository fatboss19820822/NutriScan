//
//  FoodEntryModel.swift
//  NutriScan
//
//  Created by Raymond on 8/10/2025.
//

import Foundation
import FirebaseFirestore

/// Firestore data model for food entries
struct FoodEntryModel: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String
    var name: String
    var barcode: String
    var calories: Double
    var protein: Double
    var carbs: Double
    var fat: Double
    var date: Date
    var createdAt: Date?
    var updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case name
        case barcode
        case calories
        case protein
        case carbs
        case fat
        case date
        case createdAt
        case updatedAt
    }
    
    init(
        id: String? = nil,
        userId: String,
        name: String,
        barcode: String = "",
        calories: Double,
        protein: Double,
        carbs: Double,
        fat: Double,
        date: Date = Date(),
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.userId = userId
        self.name = name
        self.barcode = barcode
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.date = date
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Convenience Extensions

extension FoodEntryModel {
    /// Returns formatted calorie string
    var caloriesString: String {
        return String(format: "%.0f cal", calories)
    }
    
    /// Returns formatted protein string
    var proteinString: String {
        return String(format: "%.0fg", protein)
    }
    
    /// Returns formatted carbs string
    var carbsString: String {
        return String(format: "%.0fg", carbs)
    }
    
    /// Returns formatted fat string
    var fatString: String {
        return String(format: "%.0fg", fat)
    }
    
    /// Returns meal category based on time of day using user preferences
    var mealCategory: String {
        let hour = Calendar.current.component(.hour, from: date)
        return PreferencesManager.shared.getMealCategory(for: hour)
    }
}

