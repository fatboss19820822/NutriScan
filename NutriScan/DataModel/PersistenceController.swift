//
//  PersistenceController.swift
//  NutriScan
//
//  Created by Raymond on 8/10/2025.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    // Preview instance for SwiftUI previews with in-memory store
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        // Create sample data for preview
        for i in 0..<5 {
            let entry = FoodEntry(context: viewContext)
            entry.id = UUID()
            entry.name = "Sample Food \(i + 1)"
            entry.barcode = "12345678901\(i)"
            entry.calories = Double.random(in: 50...500)
            entry.protein = Double.random(in: 0...30)
            entry.carbs = Double.random(in: 0...60)
            entry.fat = Double.random(in: 0...20)
            entry.date = Date().addingTimeInterval(Double(-i * 3600))
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        return controller
    }()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "NutriScan")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                // Replace this implementation with code to handle the error appropriately.
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // MARK: - Core Data Saving support
    func save() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // MARK: - Helper methods
    func addFoodEntry(name: String, barcode: String, calories: Double, protein: Double, carbs: Double, fat: Double, date: Date = Date()) {
        let context = container.viewContext
        let entry = FoodEntry(context: context)
        entry.id = UUID()
        entry.name = name
        entry.barcode = barcode
        entry.calories = calories
        entry.protein = protein
        entry.carbs = carbs
        entry.fat = fat
        entry.date = date
        
        save()
    }
    
    func deleteFoodEntry(_ entry: FoodEntry) {
        let context = container.viewContext
        context.delete(entry)
        save()
    }
    
    func fetchAllEntries() -> [FoodEntry] {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<FoodEntry> = FoodEntry.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \FoodEntry.date, ascending: false)]
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching entries: \(error)")
            return []
        }
    }
}

