//
//  HomeViewController.swift
//  NutriScan
//
//  Created by Raymond on 25/9/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    private var foodEntries: [FoodEntryModel] = []
    private var todayEntries: [FoodEntryModel] = []
    private var weekData: [(date: Date, calories: Double)] = []
    private var nutritionGoals: NutritionGoalsModel?
    private var goalsListener: ListenerRegistration?
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.backgroundColor = UIColor.systemGroupedBackground
        scroll.showsVerticalScrollIndicator = true
        return scroll
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Greeting Header
    private let greetingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    // Summary Card
    private let summaryCard: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        return view
    }()
    
    private let caloriesProgressView: MacroProgressView = {
        let view = MacroProgressView(title: "Calories", color: .systemOrange)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let proteinProgressView: MacroProgressView = {
        let view = MacroProgressView(title: "Protein", color: .systemBlue)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let carbsProgressView: MacroProgressView = {
        let view = MacroProgressView(title: "Carbs", color: .systemGreen)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let fatProgressView: MacroProgressView = {
        let view = MacroProgressView(title: "Fat", color: .systemPurple)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Recent Log Preview
    private let recentLogCard: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        return view
    }()
    
    private let recentLogTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Recent Entries"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private let recentLogStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        stack.distribution = .fill
        return stack
    }()
    
    private let viewAllButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("View All", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return button
    }()
    
    // Mini Chart Widget
    private let chartCard: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        return view
    }()
    
    private let chartTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "7-Day Calorie Trend"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private let miniChartView: MiniChartView = {
        let view = MiniChartView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Reminders / Insights
    private let insightsCard: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        return view
    }()
    
    private let insightsTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Today's Insights"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private let insightsStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        stack.distribution = .fill
        return stack
    }()
    
    private let refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refresh
    }()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        view.backgroundColor = .systemGroupedBackground
        
        setupUI()
        setupActions()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
        loadNutritionGoals()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        goalsListener?.remove()
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Add scroll view
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.refreshControl = refreshControl
        
        // Add all sections
        contentView.addSubview(greetingLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(summaryCard)
        contentView.addSubview(recentLogCard)
        contentView.addSubview(chartCard)
        contentView.addSubview(insightsCard)
        
        // Summary Card subviews
        summaryCard.addSubview(caloriesProgressView)
        summaryCard.addSubview(proteinProgressView)
        summaryCard.addSubview(carbsProgressView)
        summaryCard.addSubview(fatProgressView)
        
        // Recent Log Card subviews
        recentLogCard.addSubview(recentLogTitleLabel)
        recentLogCard.addSubview(recentLogStackView)
        recentLogCard.addSubview(viewAllButton)
        
        // Chart Card subviews
        chartCard.addSubview(chartTitleLabel)
        chartCard.addSubview(miniChartView)
        
        // Insights Card subviews
        insightsCard.addSubview(insightsTitleLabel)
        insightsCard.addSubview(insightsStackView)
        
        setupConstraints()
        updateGreeting()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Greeting Header
            greetingLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            greetingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            greetingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            dateLabel.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: greetingLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: greetingLabel.trailingAnchor),
            
            // Summary Card
            summaryCard.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 24),
            summaryCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            summaryCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            caloriesProgressView.topAnchor.constraint(equalTo: summaryCard.topAnchor, constant: 20),
            caloriesProgressView.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 20),
            caloriesProgressView.trailingAnchor.constraint(equalTo: summaryCard.trailingAnchor, constant: -20),
            caloriesProgressView.heightAnchor.constraint(equalToConstant: 80),
            
            proteinProgressView.topAnchor.constraint(equalTo: caloriesProgressView.bottomAnchor, constant: 16),
            proteinProgressView.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 20),
            proteinProgressView.trailingAnchor.constraint(equalTo: summaryCard.trailingAnchor, constant: -20),
            proteinProgressView.heightAnchor.constraint(equalToConstant: 50),
            
            carbsProgressView.topAnchor.constraint(equalTo: proteinProgressView.bottomAnchor, constant: 12),
            carbsProgressView.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 20),
            carbsProgressView.trailingAnchor.constraint(equalTo: summaryCard.trailingAnchor, constant: -20),
            carbsProgressView.heightAnchor.constraint(equalToConstant: 50),
            
            fatProgressView.topAnchor.constraint(equalTo: carbsProgressView.bottomAnchor, constant: 12),
            fatProgressView.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 20),
            fatProgressView.trailingAnchor.constraint(equalTo: summaryCard.trailingAnchor, constant: -20),
            fatProgressView.heightAnchor.constraint(equalToConstant: 50),
            fatProgressView.bottomAnchor.constraint(equalTo: summaryCard.bottomAnchor, constant: -20),
            
            // Chart Card
            chartCard.topAnchor.constraint(equalTo: summaryCard.bottomAnchor, constant: 20),
            chartCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            chartCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            chartTitleLabel.topAnchor.constraint(equalTo: chartCard.topAnchor, constant: 20),
            chartTitleLabel.leadingAnchor.constraint(equalTo: chartCard.leadingAnchor, constant: 20),
            chartTitleLabel.trailingAnchor.constraint(equalTo: chartCard.trailingAnchor, constant: -20),
            
            miniChartView.topAnchor.constraint(equalTo: chartTitleLabel.bottomAnchor, constant: 16),
            miniChartView.leadingAnchor.constraint(equalTo: chartCard.leadingAnchor, constant: 20),
            miniChartView.trailingAnchor.constraint(equalTo: chartCard.trailingAnchor, constant: -20),
            miniChartView.heightAnchor.constraint(equalToConstant: 200),
            miniChartView.bottomAnchor.constraint(equalTo: chartCard.bottomAnchor, constant: -20),
            
            // Recent Log Card
            recentLogCard.topAnchor.constraint(equalTo: chartCard.bottomAnchor, constant: 20),
            recentLogCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            recentLogCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            recentLogTitleLabel.topAnchor.constraint(equalTo: recentLogCard.topAnchor, constant: 20),
            recentLogTitleLabel.leadingAnchor.constraint(equalTo: recentLogCard.leadingAnchor, constant: 20),
            
            viewAllButton.centerYAnchor.constraint(equalTo: recentLogTitleLabel.centerYAnchor),
            viewAllButton.trailingAnchor.constraint(equalTo: recentLogCard.trailingAnchor, constant: -20),
            
            recentLogStackView.topAnchor.constraint(equalTo: recentLogTitleLabel.bottomAnchor, constant: 16),
            recentLogStackView.leadingAnchor.constraint(equalTo: recentLogCard.leadingAnchor, constant: 20),
            recentLogStackView.trailingAnchor.constraint(equalTo: recentLogCard.trailingAnchor, constant: -20),
            recentLogStackView.bottomAnchor.constraint(equalTo: recentLogCard.bottomAnchor, constant: -20),
            
            // Insights Card
            insightsCard.topAnchor.constraint(equalTo: recentLogCard.bottomAnchor, constant: 20),
            insightsCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            insightsCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            insightsCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            insightsTitleLabel.topAnchor.constraint(equalTo: insightsCard.topAnchor, constant: 20),
            insightsTitleLabel.leadingAnchor.constraint(equalTo: insightsCard.leadingAnchor, constant: 20),
            insightsTitleLabel.trailingAnchor.constraint(equalTo: insightsCard.trailingAnchor, constant: -20),
            
            insightsStackView.topAnchor.constraint(equalTo: insightsTitleLabel.bottomAnchor, constant: 16),
            insightsStackView.leadingAnchor.constraint(equalTo: insightsCard.leadingAnchor, constant: 20),
            insightsStackView.trailingAnchor.constraint(equalTo: insightsCard.trailingAnchor, constant: -20),
            insightsStackView.bottomAnchor.constraint(equalTo: insightsCard.bottomAnchor, constant: -20),
        ])
    }
    
    private func setupActions() {
        viewAllButton.addTarget(self, action: #selector(viewAllTapped), for: .touchUpInside)
    }
    
    // MARK: - Data Loading
    private func loadData() {
        fetchTodayEntries()
        fetchWeekData()
    }
    
    private func loadNutritionGoals() {
        goalsListener = FirestoreManager.shared.observeNutritionGoals { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let goals):
                    self?.nutritionGoals = goals
                    self?.updateSummaryCard()
                case .failure(let error):
                    print("Error loading nutrition goals: \(error.localizedDescription)")
                    // Use default goals if loading fails
                    self?.nutritionGoals = NutritionGoalsModel.defaultGoals
                    self?.updateSummaryCard()
                }
            }
        }
    }
    
    @objc private func refreshData() {
        loadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }
    
    private func fetchTodayEntries() {
        FirestoreManager.shared.fetchFoodEntries(for: Date()) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let entries):
                    self?.todayEntries = entries
                    self?.updateSummaryCard()
                    self?.updateRecentLog()
                    self?.updateInsights()
                case .failure(let error):
                    print("Error fetching today's entries: \(error.localizedDescription)")
                    self?.todayEntries = []
                    self?.updateSummaryCard()
                    self?.updateRecentLog()
                    self?.updateInsights()
                }
            }
        }
    }
    
    private func fetchWeekData() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -6, to: today)!
        
        var tempWeekData: [(date: Date, calories: Double)] = []
        let dispatchGroup = DispatchGroup()
        
        for dayOffset in 0...6 {
            dispatchGroup.enter()
            let date = calendar.date(byAdding: .day, value: dayOffset, to: sevenDaysAgo)!
            
            FirestoreManager.shared.fetchFoodEntries(for: date) { result in
                switch result {
                case .success(let entries):
                    let totalCalories = entries.reduce(0) { $0 + $1.calories }
                    tempWeekData.append((date: date, calories: totalCalories))
                case .failure:
                    tempWeekData.append((date: date, calories: 0))
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.weekData = tempWeekData.sorted { $0.date < $1.date }
            self?.miniChartView.setData(self?.weekData ?? [])
        }
    }
    
    // MARK: - UI Updates
    private func updateGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        let greeting: String
        
        switch hour {
        case 5..<12:
            greeting = "Good Morning"
        case 12..<17:
            greeting = "Good Afternoon"
        case 17..<22:
            greeting = "Good Evening"
        default:
            greeting = "Good Night"
        }
        
        if let userName = Auth.auth().currentUser?.displayName, !userName.isEmpty {
            greetingLabel.text = "\(greeting), \(userName)!"
        } else {
            greetingLabel.text = "\(greeting)!"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d, yyyy"
        dateLabel.text = dateFormatter.string(from: Date())
    }
    
    private func updateSummaryCard() {
        let totalCalories = todayEntries.reduce(0) { $0 + $1.calories }
        let totalProtein = todayEntries.reduce(0) { $0 + $1.protein }
        let totalCarbs = todayEntries.reduce(0) { $0 + $1.carbs }
        let totalFat = todayEntries.reduce(0) { $0 + $1.fat }
        
        let goals = nutritionGoals ?? NutritionGoalsModel.defaultGoals
        
        caloriesProgressView.setProgress(current: totalCalories, goal: goals.dailyCalorieGoal, unit: "cal")
        proteinProgressView.setProgress(current: totalProtein, goal: goals.dailyProteinGoal, unit: "g")
        carbsProgressView.setProgress(current: totalCarbs, goal: goals.dailyCarbsGoal, unit: "g")
        fatProgressView.setProgress(current: totalFat, goal: goals.dailyFatGoal, unit: "g")
    }
    
    private func updateRecentLog() {
        // Clear existing entries
        recentLogStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if todayEntries.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "No entries yet today. Start logging!"
            emptyLabel.textColor = .secondaryLabel
            emptyLabel.font = UIFont.systemFont(ofSize: 14)
            emptyLabel.textAlignment = .center
            recentLogStackView.addArrangedSubview(emptyLabel)
        } else {
            let recentEntries = Array(todayEntries.prefix(3))
            for entry in recentEntries {
                let entryView = FoodEntryRowView(entry: entry)
                recentLogStackView.addArrangedSubview(entryView)
            }
        }
    }
    
    private func updateInsights() {
        // Clear existing insights
        insightsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let insights = generateInsights()
        
        if insights.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "Keep logging to see personalized insights!"
            emptyLabel.textColor = .secondaryLabel
            emptyLabel.font = UIFont.systemFont(ofSize: 14)
            emptyLabel.textAlignment = .center
            emptyLabel.numberOfLines = 0
            insightsStackView.addArrangedSubview(emptyLabel)
        } else {
            for insight in insights {
                let insightView = InsightRowView(emoji: insight.emoji, text: insight.text)
                insightsStackView.addArrangedSubview(insightView)
            }
        }
    }
    
    private func generateInsights() -> [(emoji: String, text: String)] {
        var insights: [(emoji: String, text: String)] = []
        
        let totalCalories = todayEntries.reduce(0) { $0 + $1.calories }
        let totalProtein = todayEntries.reduce(0) { $0 + $1.protein }
        let totalCarbs = todayEntries.reduce(0) { $0 + $1.carbs }
        let totalFat = todayEntries.reduce(0) { $0 + $1.fat }
        
        let goals = nutritionGoals ?? NutritionGoalsModel.defaultGoals
        let calorieProgress = totalCalories / goals.dailyCalorieGoal
        
        // Calorie insights
        if calorieProgress < 0.3 {
            insights.append((emoji: "🍽️", text: "You have \(Int(goals.dailyCalorieGoal - totalCalories)) calories remaining today"))
        } else if calorieProgress < 0.7 {
            insights.append((emoji: "💪", text: "Great progress! \(Int((calorieProgress * 100)))% of your calorie goal reached"))
        } else if calorieProgress < 1.0 {
            insights.append((emoji: "🎯", text: "Almost there! Only \(Int(goals.dailyCalorieGoal - totalCalories)) calories to go"))
        } else if calorieProgress > 1.2 {
            insights.append((emoji: "⚠️", text: "You've exceeded your calorie goal by \(Int(totalCalories - goals.dailyCalorieGoal)) calories"))
        } else {
            insights.append((emoji: "🎉", text: "Excellent! You've hit your calorie goal for today"))
        }
        
        // Protein insights
        if totalProtein >= goals.dailyProteinGoal {
            insights.append((emoji: "💪", text: "Protein goal achieved! Great job!"))
        } else if totalProtein < goals.dailyProteinGoal * 0.5 {
            insights.append((emoji: "🥩", text: "Consider adding more protein to your meals"))
        }
        
        // Water reminder
        let hour = Calendar.current.component(.hour, from: Date())
        if hour >= 8 && hour <= 20 && todayEntries.count < 4 {
            insights.append((emoji: "💧", text: "Stay hydrated! Don't forget to drink water"))
        }
        
        // Encouragement
        if todayEntries.count >= 3 {
            insights.append((emoji: "📊", text: "Consistent logging helps you reach your goals!"))
        }
        
        return insights
    }
    
    // MARK: - Actions
    @objc private func viewAllTapped() {
        // Switch to Log tab (index 2: Home=0, Scan=1, Log=2)
        tabBarController?.selectedIndex = 2
    }
    
}

// MARK: - Custom Views

class MacroProgressView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private let progressBar: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.trackTintColor = UIColor.systemGray5
        progress.layer.cornerRadius = 4
        progress.clipsToBounds = true
        return progress
    }()
    
    private let remainingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .tertiaryLabel
        return label
    }()
    
    private var color: UIColor
    
    init(title: String, color: UIColor) {
        self.color = color
        super.init(frame: .zero)
        titleLabel.text = title
        progressBar.progressTintColor = color
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(titleLabel)
        addSubview(valueLabel)
        addSubview(progressBar)
        addSubview(remainingLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            valueLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            progressBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            progressBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            progressBar.heightAnchor.constraint(equalToConstant: 8),
            
            remainingLabel.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 4),
            remainingLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            remainingLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            remainingLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func setProgress(current: Double, goal: Double, unit: String) {
        let progress = min(current / goal, 1.0)
        let remaining = max(goal - current, 0)
        
        valueLabel.text = "\(Int(current)) / \(Int(goal)) \(unit)"
        progressBar.setProgress(Float(progress), animated: true)
        
        if current >= goal {
            remainingLabel.text = "Goal reached! 🎉"
            remainingLabel.textColor = color
        } else {
            remainingLabel.text = "\(Int(remaining)) \(unit) remaining"
            remainingLabel.textColor = .tertiaryLabel
        }
    }
}

class FoodEntryRowView: UIView {
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = .label
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let caloriesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .systemOrange
        return label
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        label.textColor = .white
        label.backgroundColor = .systemBlue
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        return label
    }()
    
    init(entry: FoodEntryModel) {
        super.init(frame: .zero)
        setupUI()
        configure(with: entry)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.systemGray6
        layer.cornerRadius = 12
        
        addSubview(categoryLabel)
        addSubview(nameLabel)
        addSubview(timeLabel)
        addSubview(caloriesLabel)
        
        NSLayoutConstraint.activate([
            categoryLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            categoryLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            categoryLabel.widthAnchor.constraint(equalToConstant: 70),
            categoryLabel.heightAnchor.constraint(equalToConstant: 24),
            
            nameLabel.leadingAnchor.constraint(equalTo: categoryLabel.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: caloriesLabel.leadingAnchor, constant: -8),
            
            timeLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            timeLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            timeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            
            caloriesLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            caloriesLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            heightAnchor.constraint(greaterThanOrEqualToConstant: 60)
        ])
    }
    
    private func configure(with entry: FoodEntryModel) {
        nameLabel.text = entry.name
        caloriesLabel.text = "\(Int(entry.calories)) cal"
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        timeLabel.text = timeFormatter.string(from: entry.date)
        
        categoryLabel.text = entry.mealCategory
    }
}

class InsightRowView: UIView {
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24)
        return label
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    init(emoji: String, text: String) {
        super.init(frame: .zero)
        emojiLabel.text = emoji
        textLabel.text = text
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.systemGray6
        layer.cornerRadius = 12
        
        addSubview(emojiLabel)
        addSubview(textLabel)
        
        NSLayoutConstraint.activate([
            emojiLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            emojiLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 30),
            
            textLabel.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 12),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            textLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            
            heightAnchor.constraint(greaterThanOrEqualToConstant: 50)
        ])
    }
}

class MiniChartView: UIView {
    private var dataPoints: [(date: Date, calories: Double)] = []
    private let goalLine: Double = 2000
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setData(_ data: [(date: Date, calories: Double)]) {
        self.dataPoints = data
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        guard !dataPoints.isEmpty else {
            drawEmptyState(in: rect)
            return
        }
        
        let context = UIGraphicsGetCurrentContext()
        
        // Calculate dimensions
        let chartInset: CGFloat = 40
        let chartWidth = rect.width - (chartInset * 2)
        let chartHeight = rect.height - (chartInset * 2)
        let chartOriginY = chartInset
        
        // Find max value for scaling
        let maxCalories = max(dataPoints.map { $0.calories }.max() ?? goalLine, goalLine)
        let scale = chartHeight / CGFloat(maxCalories)
        
        // Draw goal line
        let goalY = chartOriginY + chartHeight - (CGFloat(goalLine) * scale)
        context?.setStrokeColor(UIColor.systemGreen.withAlphaComponent(0.3).cgColor)
        context?.setLineWidth(2)
        context?.setLineDash(phase: 0, lengths: [5, 5])
        context?.move(to: CGPoint(x: chartInset, y: goalY))
        context?.addLine(to: CGPoint(x: rect.width - chartInset, y: goalY))
        context?.strokePath()
        
        // Draw goal label
        let goalText = "Goal: \(Int(goalLine))"
        let goalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.secondaryLabel
        ]
        goalText.draw(at: CGPoint(x: chartInset - 35, y: goalY - 6), withAttributes: goalAttributes)
        
        // Draw bars
        let barWidth = chartWidth / CGFloat(dataPoints.count) * 0.6
        let spacing = chartWidth / CGFloat(dataPoints.count)
        
        for (index, point) in dataPoints.enumerated() {
            let barHeight = CGFloat(point.calories) * scale
            let x = chartInset + (spacing * CGFloat(index)) + (spacing - barWidth) / 2
            let y = chartOriginY + chartHeight - barHeight
            
            let barColor = point.calories >= goalLine ? UIColor.systemGreen : UIColor.systemOrange
            let barRect = CGRect(x: x, y: y, width: barWidth, height: barHeight)
            
            let path = UIBezierPath(roundedRect: barRect, cornerRadius: 4)
            barColor.setFill()
            path.fill()
            
            // Draw day label
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "E"
            let dayText = dateFormatter.string(from: point.date)
            let dayAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 11),
                .foregroundColor: UIColor.secondaryLabel
            ]
            let textSize = dayText.size(withAttributes: dayAttributes)
            dayText.draw(at: CGPoint(x: x + (barWidth - textSize.width) / 2, y: rect.height - 25), withAttributes: dayAttributes)
        }
    }
    
    private func drawEmptyState(in rect: CGRect) {
        let text = "No data available"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.secondaryLabel
        ]
        let textSize = text.size(withAttributes: attributes)
        let x = (rect.width - textSize.width) / 2
        let y = (rect.height - textSize.height) / 2
        text.draw(at: CGPoint(x: x, y: y), withAttributes: attributes)
    }
}
