//
//  TrendsViewController.swift
//  NutriScan
//
//  Created by Raymond on 25/9/2025.
//

import UIKit
import SwiftUI
import Charts

class TrendsViewController: UIViewController {
    
    // MARK: - Time Period Enum
    enum TimePeriod: Int {
        case day = 0
        case week = 1
        case month = 2
        
        var title: String {
            switch self {
            case .day: return "Day"
            case .week: return "Week"
            case .month: return "Month"
            }
        }
        
        var numberOfDays: Int {
            switch self {
            case .day: return 1
            case .week: return 7
            case .month: return 30
            }
        }
    }
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = true
        return scroll
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Day", "Week", "Month"])
        control.selectedSegmentIndex = 1 // Default to Week
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private let calorieChartContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray5.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let macroChartContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray5.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let summaryContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray5.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let summaryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // Chart hosting controllers
    private var calorieChartHostingController: UIHostingController<CalorieChartView>?
    private var macroChartHostingController: UIHostingController<MacroChartView>?
    
    // MARK: - Properties
    private var currentTimePeriod: TimePeriod = .week
    private var foodEntries: [FoodEntryModel] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = "Trends"
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(segmentedControl)
        contentView.addSubview(calorieChartContainer)
        contentView.addSubview(macroChartContainer)
        contentView.addSubview(summaryContainer)
        summaryContainer.addSubview(summaryLabel)
        
        view.addSubview(loadingIndicator)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Segmented Control
            segmentedControl.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            segmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Calorie Chart Container
            calorieChartContainer.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            calorieChartContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            calorieChartContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            calorieChartContainer.heightAnchor.constraint(equalToConstant: 300),
            
            // Macro Chart Container
            macroChartContainer.topAnchor.constraint(equalTo: calorieChartContainer.bottomAnchor, constant: 20),
            macroChartContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            macroChartContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            macroChartContainer.heightAnchor.constraint(equalToConstant: 300),
            
            // Summary Container
            summaryContainer.topAnchor.constraint(equalTo: macroChartContainer.bottomAnchor, constant: 20),
            summaryContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            summaryContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            summaryContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            // Summary Label
            summaryLabel.topAnchor.constraint(equalTo: summaryContainer.topAnchor, constant: 16),
            summaryLabel.leadingAnchor.constraint(equalTo: summaryContainer.leadingAnchor, constant: 16),
            summaryLabel.trailingAnchor.constraint(equalTo: summaryContainer.trailingAnchor, constant: -16),
            summaryLabel.bottomAnchor.constraint(equalTo: summaryContainer.bottomAnchor, constant: -16),
            
            // Loading Indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupActions() {
        segmentedControl.addTarget(self, action: #selector(timePeriodChanged), for: .valueChanged)
    }
    
    // MARK: - Actions
    @objc private func timePeriodChanged() {
        guard let period = TimePeriod(rawValue: segmentedControl.selectedSegmentIndex) else { return }
        currentTimePeriod = period
        updateCharts()
    }
    
    // MARK: - Data Loading
    private func loadData() {
        loadingIndicator.startAnimating()
        
        FirestoreManager.shared.fetchFoodEntries { [weak self] result in
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
                
                switch result {
                case .success(let entries):
                    self?.foodEntries = entries
                    self?.updateCharts()
                    
                case .failure(let error):
                    self?.showError(error)
                }
            }
        }
    }
    
    // MARK: - Chart Updates
    private func updateCharts() {
        let filteredData = getFilteredData()
        let calorieData = aggregateCalorieData(from: filteredData)
        let macroData = aggregateMacroData(from: filteredData)
        
        setupCalorieChart(with: calorieData)
        setupMacroChart(with: macroData)
        updateSummary(with: filteredData)
    }
    
    private func getFilteredData() -> [FoodEntryModel] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let startDate: Date
        let endDate: Date
        
        switch currentTimePeriod {
        case .day:
            // Show today only
            startDate = today
            endDate = calendar.date(byAdding: .day, value: 1, to: today) ?? today
            
        case .week:
            // Show last 7 days including today
            startDate = calendar.date(byAdding: .day, value: -6, to: today) ?? today
            endDate = calendar.date(byAdding: .day, value: 1, to: today) ?? today
            
        case .month:
            // Show last 30 days including today
            startDate = calendar.date(byAdding: .day, value: -29, to: today) ?? today
            endDate = calendar.date(byAdding: .day, value: 1, to: today) ?? today
        }
        
        print("📅 Filtering data for period: \(currentTimePeriod.title)")
        print("   Today: \(today)")
        print("   Start: \(startDate)")
        print("   End: \(endDate)")
        print("   Total entries: \(foodEntries.count)")
        
        let filtered = foodEntries.filter { entry in
            let entryDay = calendar.startOfDay(for: entry.date)
            let isInRange = entryDay >= startDate && entryDay < endDate
            print("   Entry '\(entry.name)' on \(entryDay): \(isInRange ? "✅ included" : "❌ excluded")")
            return isInRange
        }
        
        print("   Filtered to: \(filtered.count) entries")
        
        return filtered
    }
    
    private func aggregateCalorieData(from entries: [FoodEntryModel]) -> [DailyCalorieData] {
        let calendar = Calendar.current
        var dailyCalories: [Date: Double] = [:]
        
        print("📊 Aggregating calorie data from \(entries.count) entries")
        
        if currentTimePeriod == .day {
            // For Day view: cumulative calories over time within the day
            let today = calendar.startOfDay(for: Date())
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today
            let todaysEntries = entries
                .filter { $0.date >= today && $0.date < tomorrow }
                .sorted { $0.date < $1.date }
            
            var runningTotal: Double = 0
            for entry in todaysEntries {
                runningTotal += entry.calories
                // Use the exact time of the entry for the x-axis
                dailyCalories[entry.date] = runningTotal
                print("  • [DAY] \(entry.name): +\(entry.calories) → \(runningTotal) cal at \(entry.date)")
            }
        } else {
            // For Week/Month: aggregate by day
            for entry in entries {
                let startOfDay = calendar.startOfDay(for: entry.date)
                dailyCalories[startOfDay, default: 0] += entry.calories
                print("  • \(entry.name): \(entry.calories) cal on \(startOfDay)")
            }
        }
        
        // Fill missing days only for Week/Month to keep chart continuous
        if currentTimePeriod != .day {
            let today = calendar.startOfDay(for: Date())
            let startDate: Date
            
            switch currentTimePeriod {
            case .day:
                startDate = today // not used in this branch
            case .week:
                startDate = calendar.date(byAdding: .day, value: -6, to: today) ?? today
            case .month:
                startDate = calendar.date(byAdding: .day, value: -29, to: today) ?? today
            }
            
            var currentDate = startDate
            while currentDate <= today {
                if dailyCalories[currentDate] == nil {
                    dailyCalories[currentDate] = 0
                }
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
            }
        }
        
        let result = dailyCalories.map { date, calories in
            DailyCalorieData(date: date, calories: calories)
        }.sorted { $0.date < $1.date }
        
        print("📊 Created \(result.count) data points for chart")
        for point in result {
            print("  • \(point.date): \(point.calories) cal")
        }
        
        return result
    }
    
    private func aggregateMacroData(from entries: [FoodEntryModel]) -> [DailyMacroData] {
        let calendar = Calendar.current
        var dailyMacros: [Date: (protein: Double, carbs: Double, fat: Double)] = [:]
        
        for entry in entries {
            let startOfDay = calendar.startOfDay(for: entry.date)
            let current = dailyMacros[startOfDay] ?? (0, 0, 0)
            dailyMacros[startOfDay] = (
                current.protein + entry.protein,
                current.carbs + entry.carbs,
                current.fat + entry.fat
            )
        }
        
        return dailyMacros.map { date, macros in
            DailyMacroData(date: date, protein: macros.protein, carbs: macros.carbs, fat: macros.fat)
        }.sorted { $0.date < $1.date }
    }
    
    private func setupCalorieChart(with data: [DailyCalorieData]) {
        // Remove old hosting controller if exists
        calorieChartHostingController?.view.removeFromSuperview()
        calorieChartHostingController?.removeFromParent()
        
        // Create new SwiftUI chart view
        let chartView = CalorieChartView(data: data, isDayView: currentTimePeriod == .day)
        let hostingController = UIHostingController(rootView: chartView)
        
        addChild(hostingController)
        calorieChartContainer.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: calorieChartContainer.topAnchor, constant: 16),
            hostingController.view.leadingAnchor.constraint(equalTo: calorieChartContainer.leadingAnchor, constant: 16),
            hostingController.view.trailingAnchor.constraint(equalTo: calorieChartContainer.trailingAnchor, constant: -16),
            hostingController.view.bottomAnchor.constraint(equalTo: calorieChartContainer.bottomAnchor, constant: -16)
        ])
        
        calorieChartHostingController = hostingController
    }
    
    private func setupMacroChart(with data: [DailyMacroData]) {
        // Remove old hosting controller if exists
        macroChartHostingController?.view.removeFromSuperview()
        macroChartHostingController?.removeFromParent()
        
        // Create new SwiftUI chart view
        let chartView = MacroChartView(data: data)
        let hostingController = UIHostingController(rootView: chartView)
        
        addChild(hostingController)
        macroChartContainer.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: macroChartContainer.topAnchor, constant: 16),
            hostingController.view.leadingAnchor.constraint(equalTo: macroChartContainer.leadingAnchor, constant: 16),
            hostingController.view.trailingAnchor.constraint(equalTo: macroChartContainer.trailingAnchor, constant: -16),
            hostingController.view.bottomAnchor.constraint(equalTo: macroChartContainer.bottomAnchor, constant: -16)
        ])
        
        macroChartHostingController = hostingController
    }
    
    private func updateSummary(with entries: [FoodEntryModel]) {
        let totalCalories = entries.reduce(0) { $0 + $1.calories }
        let totalProtein = entries.reduce(0) { $0 + $1.protein }
        let totalCarbs = entries.reduce(0) { $0 + $1.carbs }
        let totalFat = entries.reduce(0) { $0 + $1.fat }
        
        let avgCalories = entries.isEmpty ? 0 : totalCalories / Double(currentTimePeriod.numberOfDays)
        let avgProtein = entries.isEmpty ? 0 : totalProtein / Double(currentTimePeriod.numberOfDays)
        let avgCarbs = entries.isEmpty ? 0 : totalCarbs / Double(currentTimePeriod.numberOfDays)
        let avgFat = entries.isEmpty ? 0 : totalFat / Double(currentTimePeriod.numberOfDays)
        
        let summaryText = """
        📊 Summary for Last \(currentTimePeriod.title)
        
        Total Calories: \(String(format: "%.0f", totalCalories)) cal
        Avg Daily: \(String(format: "%.0f", avgCalories)) cal
        
        Macronutrients:
        • Protein: \(String(format: "%.1f", totalProtein))g (Avg: \(String(format: "%.1f", avgProtein))g/day)
        • Carbs: \(String(format: "%.1f", totalCarbs))g (Avg: \(String(format: "%.1f", avgCarbs))g/day)
        • Fat: \(String(format: "%.1f", totalFat))g (Avg: \(String(format: "%.1f", avgFat))g/day)
        """
        
        summaryLabel.text = summaryText
    }
    
    // MARK: - Error Handling
    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: "Failed to load data: \(error.localizedDescription)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.loadData()
        })
        present(alert, animated: true)
    }
}

// MARK: - Data Models
struct DailyCalorieData: Identifiable {
    let id = UUID()
    let date: Date
    let calories: Double
}

struct DailyMacroData: Identifiable {
    let id = UUID()
    let date: Date
    let protein: Double
    let carbs: Double
    let fat: Double
}

struct MacroDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let type: String
    let grams: Double
}

// MARK: - SwiftUI Chart Views
struct CalorieChartView: View {
    let data: [DailyCalorieData]
    let isDayView: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Daily Calorie Intake")
                .font(.headline)
            
            if data.isEmpty {
                VStack {
                    Spacer()
                    Text("No data available")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            } else {
                Chart(data) { item in
                    LineMark(
                        x: isDayView ? .value("Time", item.date) : .value("Date", item.date, unit: .day),
                        y: .value("Calories", item.calories)
                    )
                    .foregroundStyle(Color.blue)
                    .interpolationMethod(.monotone)
                    
                    AreaMark(
                        x: isDayView ? .value("Time", item.date) : .value("Date", item.date, unit: .day),
                        y: .value("Calories", item.calories)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.blue.opacity(0.0)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.monotone)
                    
                    PointMark(
                        x: isDayView ? .value("Time", item.date) : .value("Date", item.date, unit: .day),
                        y: .value("Calories", item.calories)
                    )
                    .foregroundStyle(Color.blue)
                }
                .chartXAxis {
                    if isDayView {
                        AxisMarks(values: .automatic) { value in
                            AxisGridLine()
                            AxisValueLabel(format: .dateTime.hour().minute())
                        }
                    } else {
                        AxisMarks(values: .stride(by: .day)) { value in
                            AxisGridLine()
                            AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .frame(height: 220)
            }
        }
    }
}

struct MacroChartView: View {
    let data: [DailyMacroData]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Macronutrients Breakdown")
                .font(.headline)
            
            if data.isEmpty {
                VStack {
                    Spacer()
                    Text("No data available")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            } else {
                Chart {
                    ForEach(data) { item in
                        BarMark(
                            x: .value("Date", item.date, unit: .day),
                            y: .value("Grams", item.protein),
                            stacking: .standard
                        )
                        .foregroundStyle(Color.red)
                        .position(by: .value("Nutrient", "Protein"))
                        
                        BarMark(
                            x: .value("Date", item.date, unit: .day),
                            y: .value("Grams", item.carbs),
                            stacking: .standard
                        )
                        .foregroundStyle(Color.orange)
                        .position(by: .value("Nutrient", "Carbs"))
                        
                        BarMark(
                            x: .value("Date", item.date, unit: .day),
                            y: .value("Grams", item.fat),
                            stacking: .standard
                        )
                        .foregroundStyle(Color.yellow)
                        .position(by: .value("Nutrient", "Fat"))
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartForegroundStyleScale([
                    "Protein": Color.red,
                    "Carbs": Color.orange,
                    "Fat": Color.yellow
                ])
                .frame(height: 220)
            }
        }
    }
}
