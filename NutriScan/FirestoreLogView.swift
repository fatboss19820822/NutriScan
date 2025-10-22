//
//  FirestoreLogView.swift
//  NutriScan
//
//  Created by Raymond on 8/10/2025.
//

import SwiftUI
import FirebaseAuth

struct FirestoreLogView: View {
    @State private var foodEntries: [FoodEntryModel] = []
    @State private var showingAddSheet = false
    @State private var searchText = ""
    @State private var selectedDate = Date()
    @State private var showingDatePicker = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingError = false
    @State private var prefilledBarcode: String?
    
    private var currentUserId: String? {
        return Auth.auth().currentUser?.uid
    }
    
    var filteredEntries: [FoodEntryModel] {
        // Filter by search text only (date filtering is done server-side)
        if searchText.isEmpty {
            return foodEntries
        } else {
            return foodEntries.filter { entry in
                entry.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if isLoading && foodEntries.isEmpty {
                    ProgressView("Loading...")
                } else if filteredEntries.isEmpty {
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
            }
            .sheet(isPresented: $showingAddSheet) {
                FirestoreAddFoodEntryView(
                    selectedDate: $selectedDate,
                    prefilledBarcode: prefilledBarcode,
                    onSave: {
                        loadEntries()
                        prefilledBarcode = nil  // Clear after use
                    }
                )
            }
            .sheet(isPresented: $showingDatePicker) {
                datePickerSheet
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "Unknown error occurred")
            }
            .onAppear {
                loadEntries()
                setupNotificationObserver()
            }
            .onChange(of: selectedDate) { _ in
                loadEntries()
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
            
            // Food entries by meal
            ForEach(groupedByMeal(), id: \.key) { mealGroup in
                Section(header: Text(mealGroup.key)) {
                    ForEach(mealGroup.value) { entry in
                        FirestoreFoodEntryRow(entry: entry)
                    }
                    .onDelete { offsets in
                        deleteItems(in: mealGroup.value, at: offsets)
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search food entries")
        .listStyle(InsetGroupedListStyle())
        .refreshable {
            loadEntries()
        }
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
    
    private func groupedByMeal() -> [(key: String, value: [FoodEntryModel])] {
        let grouped = Dictionary(grouping: filteredEntries) { entry in
            return entry.mealCategory
        }
        
        let order = ["Breakfast", "Lunch", "Dinner", "Snacks"]
        return grouped.sorted { pair1, pair2 in
            let index1 = order.firstIndex(of: pair1.key) ?? Int.max
            let index2 = order.firstIndex(of: pair2.key) ?? Int.max
            return index1 < index2
        }
    }
    
    private func deleteItems(in entries: [FoodEntryModel], at offsets: IndexSet) {
        offsets.map { entries[$0] }.forEach { entry in
            guard let id = entry.id else { return }
            
            FirestoreManager.shared.deleteFoodEntry(id: id) { result in
                switch result {
                case .success:
                    loadEntries()
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }
        }
    }
    
    private func loadEntries() {
        guard currentUserId != nil else {
            errorMessage = "You must be logged in to view entries"
            showingError = true
            return
        }
        
        isLoading = true
        
        FirestoreManager.shared.fetchFoodEntries(for: selectedDate) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let entries):
                    print("✅ Loaded \(entries.count) food entries for \(selectedDate)")
                    self.foodEntries = entries
                case .failure(let error):
                    print("❌ Error loading food entries: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                    self.showingError = true
                }
            }
        }
    }
    
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("OpenManualEntry"),
            object: nil,
            queue: .main
        ) { notification in
            if let barcode = notification.userInfo?["barcode"] as? String {
                prefilledBarcode = barcode
                showingAddSheet = true
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

// MARK: - Firestore Food Entry Row
struct FirestoreFoodEntryRow: View {
    let entry: FoodEntryModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.name)
                    .font(.headline)
                
                Spacer()
                
                Text(entry.caloriesString)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
            }
            
            HStack(spacing: 16) {
                MacroLabel(icon: "p.square.fill", value: entry.proteinString, color: .blue)
                MacroLabel(icon: "c.square.fill", value: entry.carbsString, color: .green)
                MacroLabel(icon: "f.square.fill", value: entry.fatString, color: .red)
                
                Spacer()
                
                Text(entry.date, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .font(.caption)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Add Food Entry View
struct FirestoreAddFoodEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDate: Date
    var prefilledBarcode: String?
    var onSave: () -> Void
    
    @State private var name = ""
    @State private var barcode = ""
    @State private var calories = ""
    @State private var protein = ""
    @State private var carbs = ""
    @State private var fat = ""
    @State private var date = Date()
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isSaving = false
    
    init(selectedDate: Binding<Date>, prefilledBarcode: String? = nil, onSave: @escaping () -> Void) {
        self._selectedDate = selectedDate
        self.prefilledBarcode = prefilledBarcode
        self.onSave = onSave
        self._date = State(initialValue: selectedDate.wrappedValue)
        self._barcode = State(initialValue: prefilledBarcode ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Food Information")) {
                    TextField("Food Name", text: $name)
                    
                    if prefilledBarcode != nil {
                        HStack {
                            Text("Barcode (Scanned)")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(barcode)
                                .foregroundColor(.primary)
                        }
                    } else {
                        TextField("Barcode (Optional)", text: $barcode)
                            .keyboardType(.numberPad)
                    }
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
            .navigationTitle("Add Food Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isSaving)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Button("Save") {
                            saveEntry()
                        }
                        .disabled(name.isEmpty)
                    }
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
        
        guard let userId = Auth.auth().currentUser?.uid else {
            alertMessage = "You must be logged in to add entries"
            showingAlert = true
            return
        }
        
        let caloriesValue = Double(calories) ?? 0
        let proteinValue = Double(protein) ?? 0
        let carbsValue = Double(carbs) ?? 0
        let fatValue = Double(fat) ?? 0
        
        isSaving = true
        
        FirestoreManager.shared.addFoodEntry(
            name: name,
            barcode: barcode,
            calories: caloriesValue,
            protein: proteinValue,
            carbs: carbsValue,
            fat: fatValue,
            date: date
        ) { result in
            DispatchQueue.main.async {
                isSaving = false
                
                switch result {
                case .success:
                    onSave()
                    dismiss()
                case .failure(let error):
                    alertMessage = "Failed to save entry: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
        }
    }
}

// MARK: - Preview
struct FirestoreLogView_Previews: PreviewProvider {
    static var previews: some View {
        FirestoreLogView()
    }
}

