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
    private let foodEntriesCollection = "foodEntries"
    
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
            "id": entryId,
            "userId": userId,
            "name": name,
            "barcode": barcode,
            "calories": calories,
            "protein": protein,
            "carbs": carbs,
            "fat": fat,
            "date": Timestamp(date: date),
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        db.collection(foodEntriesCollection).document(entryId).setData(data) { error in
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
        
        db.collection(foodEntriesCollection)
            .whereField("userId", isEqualTo: userId)
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
                    return try? doc.data(as: FoodEntryModel.self)
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
        
        db.collection(foodEntriesCollection)
            .whereField("userId", isEqualTo: userId)
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
                    return try? doc.data(as: FoodEntryModel.self)
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
        
        let listener = db.collection(foodEntriesCollection)
            .whereField("userId", isEqualTo: userId)
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
                    return try? doc.data(as: FoodEntryModel.self)
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
        var data: [String: Any] = [:]
        
        if let name = name { data["name"] = name }
        if let barcode = barcode { data["barcode"] = barcode }
        if let calories = calories { data["calories"] = calories }
        if let protein = protein { data["protein"] = protein }
        if let carbs = carbs { data["carbs"] = carbs }
        if let fat = fat { data["fat"] = fat }
        if let date = date { data["date"] = Timestamp(date: date) }
        
        data["updatedAt"] = FieldValue.serverTimestamp()
        
        db.collection(foodEntriesCollection).document(id).updateData(data) { error in
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
        db.collection(foodEntriesCollection).document(id).delete { error in
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
        
        db.collection(foodEntriesCollection)
            .whereField("userId", isEqualTo: userId)
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
        
        db.collection(foodEntriesCollection)
            .whereField("userId", isEqualTo: userId)
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
}

