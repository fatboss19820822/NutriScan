//
//  NutritionGoalsModel.swift
//  NutriScan
//
//  Created by Raymond on 25/9/2025.
//

import Foundation
import FirebaseFirestore

/// Firestore data model for user nutrition goals
struct NutritionGoalsModel: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String
    var dailyCalorieGoal: Double
    var dailyProteinGoal: Double
    var dailyCarbsGoal: Double
    var dailyFatGoal: Double
    var createdAt: Date?
    var updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case dailyCalorieGoal
        case dailyProteinGoal
        case dailyCarbsGoal
        case dailyFatGoal
        case createdAt
        case updatedAt
    }
    
    init(
        id: String? = nil,
        userId: String,
        dailyCalorieGoal: Double = 2000,
        dailyProteinGoal: Double = 150,
        dailyCarbsGoal: Double = 250,
        dailyFatGoal: Double = 65,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.userId = userId
        self.dailyCalorieGoal = dailyCalorieGoal
        self.dailyProteinGoal = dailyProteinGoal
        self.dailyCarbsGoal = dailyCarbsGoal
        self.dailyFatGoal = dailyFatGoal
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Convenience Extensions

extension NutritionGoalsModel {
    /// Returns default nutrition goals
    static var defaultGoals: NutritionGoalsModel {
        return NutritionGoalsModel(
            userId: "",
            dailyCalorieGoal: 2000,
            dailyProteinGoal: 150,
            dailyCarbsGoal: 250,
            dailyFatGoal: 65
        )
    }
    
    /// Returns formatted calorie goal string
    var calorieGoalString: String {
        return String(format: "%.0f cal", dailyCalorieGoal)
    }
    
    /// Returns formatted protein goal string
    var proteinGoalString: String {
        return String(format: "%.0fg", dailyProteinGoal)
    }
    
    /// Returns formatted carbs goal string
    var carbsGoalString: String {
        return String(format: "%.0fg", dailyCarbsGoal)
    }
    
    /// Returns formatted fat goal string
    var fatGoalString: String {
        return String(format: "%.0fg", dailyFatGoal)
    }
}
