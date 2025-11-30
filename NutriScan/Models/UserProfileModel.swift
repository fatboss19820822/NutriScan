//
//  UserProfileModel.swift
//  NutriScan
//
//  Created by Raymond on 25/9/2025.
//

import Foundation
import FirebaseFirestore

/// Firestore data model for user profile information
struct UserProfileModel: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String
    var displayName: String?
    var height: Double? // in centimeters
    var weight: Double? // in kilograms
    var activityLevel: ActivityLevel
    var profileImageURL: String?
    var createdAt: Date?
    var updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case displayName
        case height
        case weight
        case activityLevel
        case profileImageURL
        case createdAt
        case updatedAt
    }
    
    init(
        id: String? = nil,
        userId: String,
        displayName: String? = nil,
        height: Double? = nil,
        weight: Double? = nil,
        activityLevel: ActivityLevel = .moderatelyActive,
        profileImageURL: String? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.userId = userId
        self.displayName = displayName
        self.height = height
        self.weight = weight
        self.activityLevel = activityLevel
        self.profileImageURL = profileImageURL
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Activity Level Enum

enum ActivityLevel: String, CaseIterable, Codable {
    case sedentary = "sedentary"
    case lightlyActive = "lightly_active"
    case moderatelyActive = "moderately_active"
    case veryActive = "very_active"
    
    var displayName: String {
        switch self {
        case .sedentary:
            return "Sedentary"
        case .lightlyActive:
            return "Lightly Active"
        case .moderatelyActive:
            return "Moderately Active"
        case .veryActive:
            return "Very Active"
        }
    }
    
    var description: String {
        switch self {
        case .sedentary:
            return "Little to no exercise, desk job"
        case .lightlyActive:
            return "Light exercise 1-3 days/week"
        case .moderatelyActive:
            return "Moderate exercise 3-5 days/week"
        case .veryActive:
            return "Heavy exercise 6-7 days/week"
        }
    }
    
    var multiplier: Double {
        switch self {
        case .sedentary:
            return 1.2
        case .lightlyActive:
            return 1.375
        case .moderatelyActive:
            return 1.55
        case .veryActive:
            return 1.725
        }
    }
}

// MARK: - Convenience Extensions

extension UserProfileModel {
    /// Calculate BMI if height and weight are available
    var bmi: Double? {
        guard let height = height, let weight = weight, height > 0, weight > 0 else {
            return nil
        }
        
        let heightInMeters = height / 100.0
        return weight / (heightInMeters * heightInMeters)
    }
    
    /// Returns formatted BMI string
    var bmiString: String? {
        guard let bmi = bmi else { return nil }
        return String(format: "%.1f", bmi)
    }
    
    /// Returns BMI category
    var bmiCategory: String? {
        guard let bmi = bmi else { return nil }
        
        switch bmi {
        case ..<18.5:
            return "Underweight"
        case 18.5..<25:
            return "Normal weight"
        case 25..<30:
            return "Overweight"
        default:
            return "Obese"
        }
    }
    
    /// Returns formatted height string
    var heightString: String? {
        guard let height = height else { return nil }
        return String(format: "%.0f cm", height)
    }
    
    /// Returns formatted weight string
    var weightString: String? {
        guard let weight = weight else { return nil }
        return String(format: "%.1f kg", weight)
    }
    
    /// Calculate BMR (Basal Metabolic Rate) using Mifflin-St Jeor Equation
    var bmr: Double? {
        guard let height = height, let weight = weight, height > 0, weight > 0 else {
            return nil
        }
        
        // Using average age of 30 for calculation (could be made configurable)
        let age = 30.0
        let heightInCm = height
        let weightInKg = weight
        
        // Mifflin-St Jeor Equation (using male formula as default)
        let bmr = (10 * weightInKg) + (6.25 * heightInCm) - (5 * age) + 5
        return bmr
    }
    
    /// Calculate TDEE (Total Daily Energy Expenditure) based on activity level
    var tdee: Double? {
        guard let bmr = bmr else { return nil }
        return bmr * activityLevel.multiplier
    }
    
    /// Returns formatted TDEE string
    var tdeeString: String? {
        guard let tdee = tdee else { return nil }
        return String(format: "%.0f cal/day", tdee)
    }
}
