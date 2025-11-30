//
//  AppPreferencesModel.swift
//  NutriScan
//
//  Created by Raymond on 25/9/2025.
//

import Foundation
import FirebaseFirestore

/// Firestore data model for user app preferences
struct AppPreferencesModel: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String
    var theme: AppTheme
    var defaultMealTimes: MealTimes
    var createdAt: Date?
    var updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case theme
        case defaultMealTimes
        case createdAt
        case updatedAt
    }
    
    init(
        id: String? = nil,
        userId: String,
        theme: AppTheme = .system,
        defaultMealTimes: MealTimes = MealTimes.defaultTimes,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.userId = userId
        self.theme = theme
        self.defaultMealTimes = defaultMealTimes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - App Theme Enum

enum AppTheme: String, CaseIterable, Codable {
    case light = "light"
    case dark = "dark"
    case system = "system"
    
    var displayName: String {
        switch self {
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        case .system:
            return "System"
        }
    }
    
    var description: String {
        switch self {
        case .light:
            return "Always use light appearance"
        case .dark:
            return "Always use dark appearance"
        case .system:
            return "Follow system setting"
        }
    }
}


// MARK: - Meal Times Struct

struct MealTimes: Codable {
    var breakfastStart: Int // Hour (0-23)
    var breakfastEnd: Int
    var lunchStart: Int
    var lunchEnd: Int
    var dinnerStart: Int
    var dinnerEnd: Int
    var snackStart: Int
    var snackEnd: Int
    
    static var defaultTimes: MealTimes {
        return MealTimes(
            breakfastStart: 6,
            breakfastEnd: 11,
            lunchStart: 11,
            lunchEnd: 16,
            dinnerStart: 16,
            dinnerEnd: 21,
            snackStart: 21,
            snackEnd: 6
        )
    }
    
    func getMealCategory(for hour: Int) -> String {
        if hour >= breakfastStart && hour < breakfastEnd {
            return "Breakfast"
        } else if hour >= lunchStart && hour < lunchEnd {
            return "Lunch"
        } else if hour >= dinnerStart && hour < dinnerEnd {
            return "Dinner"
        } else {
            return "Snacks"
        }
    }
    
    func formatTime(_ hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let date = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: Date()) ?? Date()
        return formatter.string(from: date)
    }
}

// MARK: - Convenience Extensions

extension AppPreferencesModel {
    /// Returns default preferences
    static var defaultPreferences: AppPreferencesModel {
        return AppPreferencesModel(
            userId: "",
            theme: .system,
            defaultMealTimes: MealTimes.defaultTimes
        )
    }
    
    /// Returns formatted meal times string
    var mealTimesString: String {
        return """
        Breakfast: \(defaultMealTimes.formatTime(defaultMealTimes.breakfastStart)) - \(defaultMealTimes.formatTime(defaultMealTimes.breakfastEnd))
        Lunch: \(defaultMealTimes.formatTime(defaultMealTimes.lunchStart)) - \(defaultMealTimes.formatTime(defaultMealTimes.lunchEnd))
        Dinner: \(defaultMealTimes.formatTime(defaultMealTimes.dinnerStart)) - \(defaultMealTimes.formatTime(defaultMealTimes.dinnerEnd))
        Snacks: \(defaultMealTimes.formatTime(defaultMealTimes.snackStart)) - \(defaultMealTimes.formatTime(defaultMealTimes.snackEnd))
        """
    }
}
