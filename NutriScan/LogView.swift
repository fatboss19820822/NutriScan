//
//  LogView.swift
//  NutriScan
//
//  Created by Raymond on 8/10/2025.
//

import SwiftUI
import CoreData

struct LogView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \FoodEntry.date, ascending: false)],
        animation: .default)
    private var foodEntries: FetchedResults<FoodEntry>
    
    @State private var showingAddSheet = false
    @State private var searchText = ""
    @State private var selectedDate = Date()
    @State private var showingDatePicker = false
    
    var filteredEntries: [FoodEntry] {
        let entries = foodEntries.filter { entry in
            guard let entryDate = entry.date else { return false }
            return Calendar.current.isDate(entryDate, inSameDayAs: selectedDate)
        }
        
        if searchText.isEmpty {
            return Array(entries)
        } else {
            return entries.filter { entry in
                entry.name?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if filteredEntries.isEmpty {
                    emptyStateView
                } else {
                    logListView
                }
            }
            .navigationTitle("Food Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    navBarDatePicker
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Label("Add", systemImage: "plus")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddFoodEntryView(selectedDate: $selectedDate)
                    .environment(\.managedObjectContext, viewContext)
            }
            .sheet(isPresented: $showingDatePicker) {
                datePickerSheet
            }
        }
    }
    
    // MARK: - Navigation Bar Date Picker
    private var navBarDatePicker: some View {
        HStack(spacing: 12) {
            // Previous day button
            Button(action: goToPreviousDay) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.accentColor)
            }
            
            // Date display
            Button(action: { showingDatePicker = true }) {
                VStack(spacing: 1) {
                    Text(selectedDate, style: .date)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(dateStatusText)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.secondary)
                }
            }
            
            // Next day button
            Button(action: goToNextDay) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.accentColor)
            }
        }
    }
    
    private var datePickerSheet: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
                
                Spacer()
            }
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingDatePicker = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showingDatePicker = false
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "fork.knife")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Food Entries")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Tap the + button to add your first food entry for \(selectedDate, formatter: dateFormatter)")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: { showingAddSheet = true }) {
                Label("Add Food Entry", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(10)
            }
        }
    }
    
    private var logListView: some View {
        List {
            // Today's total section
            Section {
                todaysTotalView
            }
            
            // Food entries by date
            ForEach(groupedByDate(), id: \.key) { dateGroup in
                Section(header: Text(dateGroup.key)) {
                    ForEach(dateGroup.value) { entry in
                        FoodEntryRow(entry: entry)
                    }
                    .onDelete { offsets in
                        deleteItems(in: dateGroup.value, at: offsets)
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search food entries")
        .listStyle(InsetGroupedListStyle())
    }
    
    private var todaysTotalView: some View {
        let totalCalories = filteredEntries.reduce(0) { $0 + $1.calories }
        let totalProtein = filteredEntries.reduce(0) { $0 + $1.protein }
        let totalCarbs = filteredEntries.reduce(0) { $0 + $1.carbs }
        let totalFat = filteredEntries.reduce(0) { $0 + $1.fat }
        
        return VStack(spacing: 12) {
            Text(dayTotalsTitle)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 20) {
                MacroView(title: "Calories", value: String(format: "%.0f", totalCalories), color: .orange)
                MacroView(title: "Protein", value: String(format: "%.0fg", totalProtein), color: .blue)
                MacroView(title: "Carbs", value: String(format: "%.0fg", totalCarbs), color: .green)
                MacroView(title: "Fat", value: String(format: "%.0fg", totalFat), color: .red)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func groupedByDate() -> [(key: String, value: [FoodEntry])] {
        // Since we're filtering by selectedDate, we'll just group by time of day
        let grouped = Dictionary(grouping: filteredEntries) { entry -> String in
            guard let date = entry.date else { return "Unknown" }
            
            let hour = Calendar.current.component(.hour, from: date)
            switch hour {
            case 5..<11:
                return "Breakfast"
            case 11..<16:
                return "Lunch"
            case 16..<22:
                return "Dinner"
            default:
                return "Snacks"
            }
        }
        
        let order = ["Breakfast", "Lunch", "Dinner", "Snacks"]
        return grouped.sorted { pair1, pair2 in
            let index1 = order.firstIndex(of: pair1.key) ?? Int.max
            let index2 = order.firstIndex(of: pair2.key) ?? Int.max
            return index1 < index2
        }
    }
    
    private func deleteItems(in entries: [FoodEntry], at offsets: IndexSet) {
        withAnimation {
            offsets.map { entries[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                print("Error deleting: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // MARK: - Helper Functions
    private var dateStatusText: String {
        if Calendar.current.isDateInToday(selectedDate) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(selectedDate) {
            return "Yesterday"
        } else if Calendar.current.isDateInTomorrow(selectedDate) {
            return "Tomorrow"
        } else {
            return ""
        }
    }
    
    private var dayTotalsTitle: String {
        if Calendar.current.isDateInToday(selectedDate) {
            return "Today's Totals"
        } else if Calendar.current.isDateInYesterday(selectedDate) {
            return "Yesterday's Totals"
        } else if Calendar.current.isDateInTomorrow(selectedDate) {
            return "Tomorrow's Totals"
        } else {
            return "Day's Totals"
        }
    }
    
    private func goToPreviousDay() {
        withAnimation(.easeInOut(duration: 0.3)) {
            selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
        }
    }
    
    private func goToNextDay() {
        withAnimation(.easeInOut(duration: 0.3)) {
            selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
}

// MARK: - Food Entry Row
struct FoodEntryRow: View {
    let entry: FoodEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.name ?? "Unknown")
                    .font(.headline)
                
                Spacer()
                
                Text(String(format: "%.0f cal", entry.calories))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
            }
            
            HStack(spacing: 16) {
                MacroLabel(icon: "p.square.fill", value: String(format: "%.0fg", entry.protein), color: .blue)
                MacroLabel(icon: "c.square.fill", value: String(format: "%.0fg", entry.carbs), color: .green)
                MacroLabel(icon: "f.square.fill", value: String(format: "%.0fg", entry.fat), color: .red)
                
                Spacer()
                
                if let date = entry.date {
                    Text(date, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .font(.caption)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Macro Label
struct MacroLabel: View {
    let icon: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Macro View
struct MacroView: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Add Food Entry View
struct AddFoodEntryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @Binding var selectedDate: Date
    
    @State private var name = ""
    @State private var barcode = ""
    @State private var calories = ""
    @State private var protein = ""
    @State private var carbs = ""
    @State private var fat = ""
    @State private var date = Date()
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Food Information")) {
                    TextField("Food Name", text: $name)
                    TextField("Barcode", text: $barcode)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Nutritional Information")) {
                    HStack {
                        Text("Calories")
                        Spacer()
                        TextField("0", text: $calories)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Protein (g)")
                        Spacer()
                        TextField("0", text: $protein)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Carbs (g)")
                        Spacer()
                        TextField("0", text: $carbs)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Fat (g)")
                        Spacer()
                        TextField("0", text: $fat)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section(header: Text("Date & Time")) {
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                }
            }
            .onAppear {
                // Initialize date with selected date
                date = selectedDate
            }
            .navigationTitle("Add Food Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveEntry()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .alert("Error", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func saveEntry() {
        guard !name.isEmpty else {
            alertMessage = "Please enter a food name"
            showingAlert = true
            return
        }
        
        let caloriesValue = Double(calories) ?? 0
        let proteinValue = Double(protein) ?? 0
        let carbsValue = Double(carbs) ?? 0
        let fatValue = Double(fat) ?? 0
        
        let newEntry = FoodEntry(context: viewContext)
        newEntry.id = UUID()
        newEntry.name = name
        newEntry.barcode = barcode
        newEntry.calories = caloriesValue
        newEntry.protein = proteinValue
        newEntry.carbs = carbsValue
        newEntry.fat = fatValue
        newEntry.date = date
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            alertMessage = "Failed to save entry: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

// MARK: - Preview
struct LogView_Previews: PreviewProvider {
    static var previews: some View {
        LogView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

