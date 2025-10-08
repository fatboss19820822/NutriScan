# NutriScan Core Data & SwiftUI Setup Guide

## What's Been Created

I've set up a complete Core Data + SwiftUI implementation for your Food Log feature. Here's what was created:

### 1. Core Data Model
**File:** `NutriScan.xcdatamodeld/NutriScan.xcdatamodel/contents`
- Entity: `FoodEntry` with the following attributes:
  - `id` (UUID)
  - `name` (String)
  - `barcode` (String)
  - `calories` (Double)
  - `protein` (Double)
  - `carbs` (Double)
  - `fat` (Double)
  - `date` (Date)

### 2. Core Data Management
**File:** `PersistenceController.swift`
- Singleton pattern for Core Data stack
- Preview instance for SwiftUI previews
- Helper methods: `addFoodEntry()`, `deleteFoodEntry()`, `fetchAllEntries()`
- Automatic saving and error handling

### 3. SwiftUI Log View
**File:** `LogView.swift`
- Complete SwiftUI interface with:
  - List view grouped by date (Today, Yesterday, specific dates)
  - Today's nutritional totals summary
  - Search functionality
  - Add/Delete food entries
  - Empty state view
  - Macro breakdown display (Protein, Carbs, Fat)
  - Beautiful, modern UI with SF Symbols

### 4. UIKit Integration
**File:** `LogTableViewController.swift` (Updated)
- Uses `UIHostingController` to embed SwiftUI view
- Seamlessly integrates with your existing UIKit tab bar

### 5. AppDelegate Updates
**File:** `AppDelegate.swift` (Updated)
- Core Data initialization
- Save on app termination

## How to Add Files to Xcode

Since these files were created outside of Xcode, you need to add them to your project:

1. **Open Xcode** and open your NutriScan project

2. **Add the Core Data Model:**
   - Right-click on the `NutriScan` folder in the Project Navigator
   - Select "Add Files to NutriScan..."
   - Navigate to `NutriScan.xcdatamodeld` folder
   - Make sure "Copy items if needed" is **unchecked** (it's already in the right place)
   - Make sure "NutriScan" target is checked
   - Click "Add"

3. **Add the Swift Files:**
   - Right-click on the `NutriScan` folder in the Project Navigator
   - Select "Add Files to NutriScan..."
   - Select these files:
     - `PersistenceController.swift`
     - `LogView.swift`
   - Make sure "Copy items if needed" is **unchecked**
   - Make sure "NutriScan" target is checked
   - Click "Add"

4. **Verify the files are added:**
   - You should see all new files in the Project Navigator
   - Build the project (⌘+B) to ensure everything compiles

## Features Included

### 🎯 Today's Summary
- Shows total calories, protein, carbs, and fat for today
- Updates automatically as you add/remove entries

### 📝 Food Entry List
- Grouped by date (Today, Yesterday, and older dates)
- Shows all nutritional information per entry
- Swipe to delete
- Search by food name

### ➕ Add New Entries
- Tap the "+" button to add new food entries
- Enter:
  - Food name
  - Barcode (optional)
  - Calories
  - Protein, Carbs, Fat
  - Date and time
- All data is saved to Core Data

### 🎨 Modern UI
- Native iOS design with SF Symbols
- Smooth animations
- Color-coded macros (Protein=Blue, Carbs=Green, Fat=Red, Calories=Orange)
- Empty state with helpful guidance

## Testing

To test the implementation:

1. **Build and Run** the app (⌘+R)
2. Navigate to the "Log" tab
3. Try adding a food entry:
   - Tap the "+" button
   - Enter: "Coca-Cola", barcode "737628064502", calories 140, carbs 39
   - Save
4. You should see:
   - The entry appears in the "Today" section
   - Today's totals are updated
   - Entry shows time, calories, and macros
5. Try deleting an entry (swipe left or use Edit button)

## Sample Data

The app includes a preview provider with sample data for testing in Xcode previews:
- 5 sample food entries
- Various nutritional values
- Different timestamps

## Core Data Stack

The persistence layer is managed by `PersistenceController`:
```swift
// Access anywhere in your app:
let context = PersistenceController.shared.container.viewContext

// Add an entry:
PersistenceController.shared.addFoodEntry(
    name: "Apple",
    barcode: "123456",
    calories: 95,
    protein: 0.5,
    carbs: 25,
    fat: 0.3
)
```

## Integration with Scan Feature

You can easily add scanned food items to the log:
```swift
// In your ScanViewController:
PersistenceController.shared.addFoodEntry(
    name: scannedProduct.name,
    barcode: scannedBarcode,
    calories: scannedProduct.calories,
    protein: scannedProduct.protein,
    carbs: scannedProduct.carbs,
    fat: scannedProduct.fat,
    date: Date()
)
```

## Troubleshooting

### Build Errors
- Make sure all files are added to the NutriScan target
- Check that `NutriScan.xcdatamodeld` is in the project
- Clean build folder (⌘+Shift+K) and rebuild

### Core Data Issues
- If data doesn't persist, check that `PersistenceController.shared` is initialized in AppDelegate
- Check Console for Core Data errors

### SwiftUI Preview Issues
- Make sure `PersistenceController.preview` is being used in previews
- Refresh preview (⌘+Option+P)

## Next Steps

You can now:
1. ✅ Add food entries manually
2. ✅ View all your logged food
3. ✅ See nutritional totals
4. ✅ Delete entries
5. ✅ Search entries

To integrate with your Scan feature:
- Import `PersistenceController` in `ScanViewController`
- After scanning, call `addFoodEntry()` with the scanned data
- The Log view will automatically update!

## File Structure
```
NutriScan/
├── AppDelegate.swift (Updated with Core Data)
├── PersistenceController.swift (NEW - Core Data manager)
├── LogView.swift (NEW - SwiftUI interface)
├── LogTableViewController.swift (Updated - UIKit bridge)
└── NutriScan.xcdatamodeld/ (NEW - Core Data model)
    └── NutriScan.xcdatamodel/
        └── contents
```

Enjoy your new Core Data-powered Food Log! 🎉

