//
//  PreferencesManager.swift
//  NutriScan
//
//  Created by Raymond on 25/9/2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import UIKit

/// Manager class for handling user app preferences
class PreferencesManager: ObservableObject {
    static let shared = PreferencesManager()
    
    // MARK: - Properties
    @Published var currentPreferences: AppPreferencesModel?
    private var preferencesListener: ListenerRegistration?
    
    // MARK: - Initialization
    private init() {
        loadPreferences()
    }
    
    deinit {
        preferencesListener?.remove()
    }
    
    // MARK: - Public Methods
    
    /// Load user preferences from Firestore
    func loadPreferences() {
        guard let userId = Auth.auth().currentUser?.uid else {
            currentPreferences = AppPreferencesModel.defaultPreferences
            return
        }
        
        // Remove existing listener
        preferencesListener?.remove()
        
        preferencesListener = FirestoreManager.shared.observeAppPreferences { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let preferences):
                    self?.currentPreferences = preferences
                    self?.applyTheme(preferences?.theme ?? .system)
                case .failure(let error):
                    print("Error loading preferences: \(error)")
                    self?.currentPreferences = AppPreferencesModel.defaultPreferences
                    self?.applyTheme(.system)
                }
            }
        }
    }
    
    /// Save preferences to Firestore
    func savePreferences(_ preferences: AppPreferencesModel, completion: @escaping (Result<Void, Error>) -> Void) {
        FirestoreManager.shared.saveAppPreferences(preferences) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.currentPreferences = preferences
                    self?.applyTheme(preferences.theme)
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// Update specific preference
    func updatePreference<T>(_ keyPath: WritableKeyPath<AppPreferencesModel, T>, value: T, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "PreferencesManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])))
            return
        }
        
        var updatedPreferences = currentPreferences ?? AppPreferencesModel(userId: userId)
        updatedPreferences[keyPath: keyPath] = value
        updatedPreferences.updatedAt = Date()
        
        savePreferences(updatedPreferences, completion: completion)
    }
    
    /// Get current theme
    var currentTheme: AppTheme {
        return currentPreferences?.theme ?? .system
    }
    
    /// Get current meal times
    var currentMealTimes: MealTimes {
        return currentPreferences?.defaultMealTimes ?? MealTimes.defaultTimes
    }
    
    
    /// Get meal category for given hour
    func getMealCategory(for hour: Int) -> String {
        return currentMealTimes.getMealCategory(for: hour)
    }
    
    /// Get meal category for given date
    func getMealCategory(for date: Date) -> String {
        let hour = Calendar.current.component(.hour, from: date)
        return getMealCategory(for: hour)
    }
    
    // MARK: - Theme Management
    
    private func applyTheme(_ theme: AppTheme) {
        DispatchQueue.main.async {
            switch theme {
            case .light:
                if #available(iOS 13.0, *) {
                    UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .light
                }
            case .dark:
                if #available(iOS 13.0, *) {
                    UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .dark
                }
            case .system:
                if #available(iOS 13.0, *) {
                    UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .unspecified
                }
            }
        }
    }
    
    
    // MARK: - Convenience Methods
    
    /// Reset to default preferences
    func resetToDefaults(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "PreferencesManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])))
            return
        }
        
        let defaultPreferences = AppPreferencesModel(
            userId: userId,
            theme: .system,
            defaultMealTimes: MealTimes.defaultTimes,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        savePreferences(defaultPreferences, completion: completion)
    }
    
    /// Check if preferences are loaded
    var isPreferencesLoaded: Bool {
        return currentPreferences != nil
    }
    
    /// Get formatted meal times string
    var formattedMealTimes: String {
        return currentPreferences?.mealTimesString ?? MealTimes.defaultTimes.mealTimesString
    }
}

// MARK: - Extensions for MealTimes

extension MealTimes {
    var mealTimesString: String {
        return """
        Breakfast: \(formatTime(breakfastStart)) - \(formatTime(breakfastEnd))
        Lunch: \(formatTime(lunchStart)) - \(formatTime(lunchEnd))
        Dinner: \(formatTime(dinnerStart)) - \(formatTime(dinnerEnd))
        Snacks: \(formatTime(snackStart)) - \(formatTime(snackEnd))
        """
    }
}
