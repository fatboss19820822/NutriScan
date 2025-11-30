//
//  FirestoreManager.swift
//  NutriScan
//
//  Created by Raymond on 8/10/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

/// Manages all Firestore database operations for food entries
class FirestoreManager {
    static let shared = FirestoreManager()
    
    private let db = Firestore.firestore()
    private let usersCollection = "users"
    
    private init() {
        // Configure Firestore settings
        let settings = FirestoreSettings()
        settings.cacheSettings = PersistentCacheSettings()
        db.settings = settings
    }
    
    // MARK: - Current User
    
    private var currentUserId: String? {
        return Auth.auth().currentUser?.uid
    }
    
    // MARK: - Create
    
    /// Add a new food entry to Firestore
    func addFoodEntry(
        name: String,
        barcode: String,
        calories: Double,
        protein: Double,
        carbs: Double,
        fat: Double,
        date: Date,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let userId = currentUserId else {
            completion(.failure(NSError(domain: "FirestoreManager", code: -1, 
                userInfo: [NSLocalizedDescriptionKey: "No user logged in"])))
            return
        }
        
        let entryId = UUID().uuidString
        
        let data: [String: Any] = [
            "name": name,
            "barcode": barcode,
            "calories": calories,
            "protein": protein,
            "carbs": carbs,
            "fat": fat,
            "date": Timestamp(date: date),
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        db.collection(usersCollection)
            .document(userId)
            .collection("foodEntries")
            .document(entryId)
            .setData(data) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(entryId))
            }
        }
    }
    
    // MARK: - Read
    
    /// Fetch all food entries for the current user
    func fetchFoodEntries(completion: @escaping (Result<[FoodEntryModel], Error>) -> Void) {
        guard let userId = currentUserId else {
            completion(.failure(NSError(domain: "FirestoreManager", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No user logged in"])))
            return
        }
        
        db.collection(usersCollection)
            .document(userId)
            .collection("foodEntries")
            .order(by: "date", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                let entries = documents.compactMap { doc -> FoodEntryModel? in
                    let data = doc.data()
                    return FoodEntryModel(
                        id: doc.documentID,
                        userId: userId,
                        name: data["name"] as? String ?? "",
                        barcode: data["barcode"] as? String ?? "",
                        calories: data["calories"] as? Double ?? 0,
                        protein: data["protein"] as? Double ?? 0,
                        carbs: data["carbs"] as? Double ?? 0,
                        fat: data["fat"] as? Double ?? 0,
                        date: (data["date"] as? Timestamp)?.dateValue() ?? Date(),
                        createdAt: (data["createdAt"] as? Timestamp)?.dateValue(),
                        updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue()
                    )
                }
                
                completion(.success(entries))
            }
    }
    
    /// Fetch food entries for a specific date
    func fetchFoodEntries(for date: Date, completion: @escaping (Result<[FoodEntryModel], Error>) -> Void) {
        guard let userId = currentUserId else {
            completion(.failure(NSError(domain: "FirestoreManager", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No user logged in"])))
            return
        }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date
        
        db.collection(usersCollection)
            .document(userId)
            .collection("foodEntries")
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("date", isLessThan: Timestamp(date: endOfDay))
            .order(by: "date", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                let entries = documents.compactMap { doc -> FoodEntryModel? in
                    let data = doc.data()
                    return FoodEntryModel(
                        id: doc.documentID,
                        userId: userId,
                        name: data["name"] as? String ?? "",
                        barcode: data["barcode"] as? String ?? "",
                        calories: data["calories"] as? Double ?? 0,
                        protein: data["protein"] as? Double ?? 0,
                        carbs: data["carbs"] as? Double ?? 0,
                        fat: data["fat"] as? Double ?? 0,
                        date: (data["date"] as? Timestamp)?.dateValue() ?? Date(),
                        createdAt: (data["createdAt"] as? Timestamp)?.dateValue(),
                        updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue()
                    )
                }
                
                completion(.success(entries))
            }
    }
    
    /// Listen for real-time updates to food entries
    func observeFoodEntries(completion: @escaping (Result<[FoodEntryModel], Error>) -> Void) -> ListenerRegistration? {
        guard let userId = currentUserId else {
            completion(.failure(NSError(domain: "FirestoreManager", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No user logged in"])))
            return nil
        }
        
        let listener = db.collection(usersCollection)
            .document(userId)
            .collection("foodEntries")
            .order(by: "date", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                let entries = documents.compactMap { doc -> FoodEntryModel? in
                    let data = doc.data()
                    return FoodEntryModel(
                        id: doc.documentID,
                        userId: userId,
                        name: data["name"] as? String ?? "",
                        barcode: data["barcode"] as? String ?? "",
                        calories: data["calories"] as? Double ?? 0,
                        protein: data["protein"] as? Double ?? 0,
                        carbs: data["carbs"] as? Double ?? 0,
                        fat: data["fat"] as? Double ?? 0,
                        date: (data["date"] as? Timestamp)?.dateValue() ?? Date(),
                        createdAt: (data["createdAt"] as? Timestamp)?.dateValue(),
                        updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue()
                    )
                }
                
                completion(.success(entries))
            }
        
        return listener
    }
    
    // MARK: - Update
    
    /// Update an existing food entry
    func updateFoodEntry(
        id: String,
        name: String?,
        barcode: String?,
        calories: Double?,
        protein: Double?,
        carbs: Double?,
        fat: Double?,
        date: Date?,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let userId = currentUserId else {
            completion(.failure(NSError(domain: "FirestoreManager", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No user logged in"])))
            return
        }
        
        var data: [String: Any] = [:]
        
        if let name = name { data["name"] = name }
        if let barcode = barcode { data["barcode"] = barcode }
        if let calories = calories { data["calories"] = calories }
        if let protein = protein { data["protein"] = protein }
        if let carbs = carbs { data["carbs"] = carbs }
        if let fat = fat { data["fat"] = fat }
        if let date = date { data["date"] = Timestamp(date: date) }
        
        data["updatedAt"] = FieldValue.serverTimestamp()
        
        db.collection(usersCollection)
            .document(userId)
            .collection("foodEntries")
            .document(id)
            .updateData(data) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Delete
    
    /// Delete a food entry
    func deleteFoodEntry(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = currentUserId else {
            completion(.failure(NSError(domain: "FirestoreManager", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No user logged in"])))
            return
        }
        
        db.collection(usersCollection)
            .document(userId)
            .collection("foodEntries")
            .document(id)
            .delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    /// Delete all food entries for the current user (for testing/cleanup)
    func deleteAllUserEntries(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = currentUserId else {
            completion(.failure(NSError(domain: "FirestoreManager", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No user logged in"])))
            return
        }
        
        db.collection(usersCollection)
            .document(userId)
            .collection("foodEntries")
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success(()))
                    return
                }
                
                let batch = self.db.batch()
                documents.forEach { batch.deleteDocument($0.reference) }
                
                batch.commit { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            }
    }
    
    // MARK: - Statistics
    
    /// Get total calories for a date range
    func getTotalCalories(from startDate: Date, to endDate: Date, completion: @escaping (Result<Double, Error>) -> Void) {
        guard let userId = currentUserId else {
            completion(.failure(NSError(domain: "FirestoreManager", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No user logged in"])))
            return
        }
        
        db.collection(usersCollection)
            .document(userId)
            .collection("foodEntries")
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startDate))
            .whereField("date", isLessThanOrEqualTo: Timestamp(date: endDate))
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success(0.0))
                    return
                }
                
                let totalCalories = documents.reduce(0.0) { sum, doc in
                    let calories = doc.data()["calories"] as? Double ?? 0.0
                    return sum + calories
                }
                
                completion(.success(totalCalories))
            }
    }
    
    // MARK: - Nutrition Goals
    
    /// Save or update nutrition goals for the current user
    func saveNutritionGoals(
        calorieGoal: Double,
        proteinGoal: Double,
        carbsGoal: Double,
        fatGoal: Double,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let userId = currentUserId else {
            completion(.failure(NSError(domain: "FirestoreManager", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No user logged in"])))
            return
        }
        
        let data: [String: Any] = [
            "dailyCalorieGoal": calorieGoal,
            "dailyProteinGoal": proteinGoal,
            "dailyCarbsGoal": carbsGoal,
            "dailyFatGoal": fatGoal,
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        // Store goals as a single document in the user's goals subcollection
        db.collection(usersCollection)
            .document(userId)
            .collection("goals")
            .document("nutrition")
            .setData(data, merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    /// Calculate recommended nutrition goals based on user profile
    func calculateRecommendedGoals(
        height: Double?,
        weight: Double?,
        activityLevel: ActivityLevel,
        completion: @escaping (Result<NutritionGoalsModel, Error>) -> Void
    ) {
        guard let userId = currentUserId else {
            completion(.failure(NSError(domain: "FirestoreManager", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No user logged in"])))
            return
        }
        
        // Default values if height/weight not available
        let height = height ?? 170.0 // Default height in cm
        let weight = weight ?? 70.0  // Default weight in kg
        
        // Calculate BMR using Mifflin-St Jeor Equation (using age 30 as default)
        let age = 30.0
        let bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5
        let tdee = bmr * activityLevel.multiplier
        
        // Calculate macronutrient goals based on TDEE
        let calorieGoal = tdee
        let proteinGoal = (weight * 1.6) // 1.6g per kg body weight
        let fatGoal = (calorieGoal * 0.25) / 9 // 25% of calories from fat
        let carbsGoal = (calorieGoal - (proteinGoal * 4) - (fatGoal * 9)) / 4 // Remaining calories from carbs
        
        let goals = NutritionGoalsModel(
            userId: userId,
            dailyCalorieGoal: calorieGoal,
            dailyProteinGoal: proteinGoal,
            dailyCarbsGoal: carbsGoal,
            dailyFatGoal: fatGoal
        )
        
        completion(.success(goals))
    }
    
    /// Fetch nutrition goals for the current user
    func fetchNutritionGoals(completion: @escaping (Result<NutritionGoalsModel?, Error>) -> Void) {
        guard let userId = currentUserId else {
            completion(.failure(NSError(domain: "FirestoreManager", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No user logged in"])))
            return
        }
        
        db.collection(usersCollection)
            .document(userId)
            .collection("goals")
            .document("nutrition")
            .getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists else {
                // Return default goals if no goals are set
                let defaultGoals = NutritionGoalsModel(
                    userId: userId,
                    dailyCalorieGoal: 2000,
                    dailyProteinGoal: 150,
                    dailyCarbsGoal: 250,
                    dailyFatGoal: 65
                )
                completion(.success(defaultGoals))
                return
            }
            
            do {
                let data = document.data() ?? [:]
                let goals = NutritionGoalsModel(
                    userId: userId,
                    dailyCalorieGoal: data["dailyCalorieGoal"] as? Double ?? 2000,
                    dailyProteinGoal: data["dailyProteinGoal"] as? Double ?? 150,
                    dailyCarbsGoal: data["dailyCarbsGoal"] as? Double ?? 250,
                    dailyFatGoal: data["dailyFatGoal"] as? Double ?? 65,
                    createdAt: nil,
                    updatedAt: data["updatedAt"] as? Date
                )
                completion(.success(goals))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    /// Listen for real-time updates to nutrition goals
    func observeNutritionGoals(completion: @escaping (Result<NutritionGoalsModel?, Error>) -> Void) -> ListenerRegistration? {
        guard let userId = currentUserId else {
            completion(.failure(NSError(domain: "FirestoreManager", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No user logged in"])))
            return nil
        }
        
        let listener = db.collection(usersCollection)
            .document(userId)
            .collection("goals")
            .document("nutrition")
            .addSnapshotListener { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists else {
                // Return default goals if no goals are set
                let defaultGoals = NutritionGoalsModel(
                    userId: userId,
                    dailyCalorieGoal: 2000,
                    dailyProteinGoal: 150,
                    dailyCarbsGoal: 250,
                    dailyFatGoal: 65
                )
                completion(.success(defaultGoals))
                return
            }
            
            do {
                let data = document.data() ?? [:]
                let goals = NutritionGoalsModel(
                    userId: userId,
                    dailyCalorieGoal: data["dailyCalorieGoal"] as? Double ?? 2000,
                    dailyProteinGoal: data["dailyProteinGoal"] as? Double ?? 150,
                    dailyCarbsGoal: data["dailyCarbsGoal"] as? Double ?? 250,
                    dailyFatGoal: data["dailyFatGoal"] as? Double ?? 65,
                    createdAt: nil,
                    updatedAt: data["updatedAt"] as? Date
                )
                completion(.success(goals))
            } catch {
                completion(.failure(error))
            }
        }
        
        return listener
    }
    
    // MARK: - User Profile Management
    
    /// Save or update user profile
    func saveUserProfile(
        displayName: String?,
        height: Double?,
        weight: Double?,
        activityLevel: ActivityLevel,
        profileImageURL: String?,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let userId = currentUserId else {
            print("❌ FirestoreManager: No user logged in - cannot save profile")
            completion(.failure(NSError(domain: "FirestoreManager", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No user logged in"])))
            return
        }
        
        print("✅ FirestoreManager: Saving profile for user: \(userId)")
        
        let data: [String: Any] = [
            "displayName": displayName as Any,
            "height": height as Any,
            "weight": weight as Any,
            "activityLevel": activityLevel.rawValue,
            "profileImageURL": profileImageURL as Any,
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        // Store profile as a single document in the user's profile subcollection
        let profileRef = db.collection(usersCollection)
            .document(userId)
            .collection("profile")
            .document("main")
            
        print("📝 FirestoreManager: Saving to path: users/\(userId)/profile/main")
        print("📝 FirestoreManager: Data to save: \(data)")
        
        profileRef.setData(data, merge: true) { error in
            if let error = error {
                print("❌ FirestoreManager: Error saving profile: \(error)")
                completion(.failure(error))
            } else {
                print("✅ FirestoreManager: Profile saved successfully")
                completion(.success(()))
            }
        }
    }
    
    /// Fetch user profile
    func fetchUserProfile(completion: @escaping (Result<UserProfileModel?, Error>) -> Void) {
        guard let userId = currentUserId else {
            completion(.failure(NSError(domain: "FirestoreManager", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No user logged in"])))
            return
        }
        
        db.collection(usersCollection)
            .document(userId)
            .collection("profile")
            .document("main")
            .getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists else {
                completion(.success(nil))
                return
            }
            
                do {
                    let data = document.data() ?? [:]
                    let activityLevelString = data["activityLevel"] as? String ?? "moderately_active"
                    let activityLevel = ActivityLevel(rawValue: activityLevelString) ?? .moderatelyActive
                    
                    let profile = UserProfileModel(
                        userId: userId,
                        displayName: data["displayName"] as? String,
                        height: data["height"] as? Double,
                        weight: data["weight"] as? Double,
                        activityLevel: activityLevel,
                        profileImageURL: data["profileImageURL"] as? String,
                        createdAt: nil,
                        updatedAt: data["updatedAt"] as? Date
                    )
                    completion(.success(profile))
                } catch {
                    completion(.failure(error))
                }
        }
    }
    
    /// Listen for real-time updates to user profile
    func observeUserProfile(completion: @escaping (Result<UserProfileModel?, Error>) -> Void) -> ListenerRegistration? {
        guard let userId = currentUserId else {
            completion(.failure(NSError(domain: "FirestoreManager", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No user logged in"])))
            return nil
        }
        
        let listener = db.collection(usersCollection)
            .document(userId)
            .collection("profile")
            .document("main")
            .addSnapshotListener { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists else {
                completion(.success(nil))
                return
            }
            
                do {
                    let data = document.data() ?? [:]
                    let activityLevelString = data["activityLevel"] as? String ?? "moderately_active"
                    let activityLevel = ActivityLevel(rawValue: activityLevelString) ?? .moderatelyActive
                    
                    let profile = UserProfileModel(
                        userId: userId,
                        displayName: data["displayName"] as? String,
                        height: data["height"] as? Double,
                        weight: data["weight"] as? Double,
                        activityLevel: activityLevel,
                        profileImageURL: data["profileImageURL"] as? String,
                        createdAt: nil,
                        updatedAt: data["updatedAt"] as? Date
                    )
                    completion(.success(profile))
                } catch {
                    completion(.failure(error))
                }
        }
        
        return listener
    }
    
    /// Update only specific profile fields
    func updateUserProfile(
        displayName: String? = nil,
        height: Double? = nil,
        weight: Double? = nil,
        activityLevel: ActivityLevel? = nil,
        profileImageURL: String? = nil,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let userId = currentUserId else {
            completion(.failure(NSError(domain: "FirestoreManager", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No user logged in"])))
            return
        }
        
        var data: [String: Any] = [:]
        
        if let displayName = displayName { data["displayName"] = displayName }
        if let height = height { data["height"] = height }
        if let weight = weight { data["weight"] = weight }
        if let activityLevel = activityLevel { data["activityLevel"] = activityLevel.rawValue }
        if let profileImageURL = profileImageURL { data["profileImageURL"] = profileImageURL }
        
        data["updatedAt"] = FieldValue.serverTimestamp()
        
        db.collection(usersCollection)
            .document(userId)
            .collection("profile")
            .document("main")
            .updateData(data) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Testing Functions
    
    /// Test function to verify Firestore connection and user authentication
    func testFirestoreConnection(completion: @escaping (Result<String, Error>) -> Void) {
        guard let userId = currentUserId else {
            print("❌ Test: No user logged in")
            completion(.failure(NSError(domain: "FirestoreManager", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No user logged in"])))
            return
        }
        
        print("✅ Test: User authenticated with ID: \(userId)")
        
        // Test write operation
        let testData: [String: Any] = [
            "testField": "testValue",
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        db.collection("test")
            .document(userId)
            .setData(testData) { error in
                if let error = error {
                    print("❌ Test: Failed to write test data: \(error)")
                    completion(.failure(error))
                } else {
                    print("✅ Test: Successfully wrote test data to Firestore")
                    completion(.success("Firestore connection working! User ID: \(userId)"))
                }
            }
    }
    
    // MARK: - App Preferences
    
    /// Save app preferences to Firestore
    func saveAppPreferences(_ preferences: AppPreferencesModel, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = currentUserId else {
            completion(.failure(NSError(domain: "FirestoreManager", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No user logged in"])))
            return
        }
        
        var data: [String: Any] = [
            "userId": userId,
            "theme": preferences.theme.rawValue,
            "defaultMealTimes": [
                "breakfastStart": preferences.defaultMealTimes.breakfastStart,
                "breakfastEnd": preferences.defaultMealTimes.breakfastEnd,
                "lunchStart": preferences.defaultMealTimes.lunchStart,
                "lunchEnd": preferences.defaultMealTimes.lunchEnd,
                "dinnerStart": preferences.defaultMealTimes.dinnerStart,
                "dinnerEnd": preferences.defaultMealTimes.dinnerEnd,
                "snackStart": preferences.defaultMealTimes.snackStart,
                "snackEnd": preferences.defaultMealTimes.snackEnd
            ],
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        if let createdAt = preferences.createdAt {
            data["createdAt"] = createdAt
        } else {
            data["createdAt"] = FieldValue.serverTimestamp()
        }
        
        db.collection(usersCollection)
            .document(userId)
            .collection("preferences")
            .document("app")
            .setData(data, merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    /// Fetch app preferences from Firestore
    func fetchAppPreferences(completion: @escaping (Result<AppPreferencesModel?, Error>) -> Void) {
        guard let userId = currentUserId else {
            completion(.failure(NSError(domain: "FirestoreManager", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No user logged in"])))
            return
        }
        
        db.collection(usersCollection)
            .document(userId)
            .collection("preferences")
            .document("app")
            .getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists,
                  let data = document.data() else {
                completion(.success(nil))
                return
            }
            
            do {
                let preferences = try self.parseAppPreferences(from: data)
                completion(.success(preferences))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    /// Observe app preferences changes
    func observeAppPreferences(completion: @escaping (Result<AppPreferencesModel?, Error>) -> Void) -> ListenerRegistration {
        guard let userId = currentUserId else {
            completion(.failure(NSError(domain: "FirestoreManager", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No user logged in"])))
            return db.collection("dummy").addSnapshotListener { _, _ in }
        }
        
        return db.collection(usersCollection)
            .document(userId)
            .collection("preferences")
            .document("app")
            .addSnapshotListener { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists,
                  let data = document.data() else {
                completion(.success(nil))
                return
            }
            
            do {
                let preferences = try self.parseAppPreferences(from: data)
                completion(.success(preferences))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    /// Parse app preferences from Firestore data
    private func parseAppPreferences(from data: [String: Any]) throws -> AppPreferencesModel {
        guard let userId = data["userId"] as? String,
              let themeString = data["theme"] as? String,
              let theme = AppTheme(rawValue: themeString),
              let mealTimesData = data["defaultMealTimes"] as? [String: Any] else {
            throw NSError(domain: "FirestoreManager", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Invalid preferences data"])
        }
        
        let mealTimes = MealTimes(
            breakfastStart: mealTimesData["breakfastStart"] as? Int ?? 6,
            breakfastEnd: mealTimesData["breakfastEnd"] as? Int ?? 11,
            lunchStart: mealTimesData["lunchStart"] as? Int ?? 11,
            lunchEnd: mealTimesData["lunchEnd"] as? Int ?? 16,
            dinnerStart: mealTimesData["dinnerStart"] as? Int ?? 16,
            dinnerEnd: mealTimesData["dinnerEnd"] as? Int ?? 21,
            snackStart: mealTimesData["snackStart"] as? Int ?? 21,
            snackEnd: mealTimesData["snackEnd"] as? Int ?? 6
        )
        
        return AppPreferencesModel(
            id: nil,
            userId: userId,
            theme: theme,
            defaultMealTimes: mealTimes,
            createdAt: data["createdAt"] as? Date,
            updatedAt: data["updatedAt"] as? Date
        )
    }
}

