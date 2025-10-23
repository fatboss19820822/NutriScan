//
//  AppPreferencesViewController.swift
//  NutriScan
//
//  Created by Raymond on 25/9/2025.
//

import UIKit
import FirebaseAuth

class AppPreferencesViewController: UIViewController {
    
    // MARK: - Properties
    private var currentPreferences: AppPreferencesModel?
    private var preferencesManager = PreferencesManager.shared
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    // Theme Section
    private let themeSectionView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray5.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let themeTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Appearance"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let themeSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: AppTheme.allCases.map { $0.displayName })
        control.selectedSegmentIndex = 2 // Default to System
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private let themeDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    // Meal Times Section
    private let mealTimesSectionView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray5.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let mealTimesTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Default Meal Times"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let mealTimesDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = "Set your preferred meal times for automatic categorization of food entries."
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let mealTimesStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // Action Buttons
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save Preferences", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reset to Defaults", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.systemRed, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        loadCurrentPreferences()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = "App Preferences"
        
        // Add navigation bar buttons
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelButtonTapped)
        )
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(themeSectionView)
        contentView.addSubview(mealTimesSectionView)
        contentView.addSubview(saveButton)
        contentView.addSubview(resetButton)
        
        // Theme section
        themeSectionView.addSubview(themeTitleLabel)
        themeSectionView.addSubview(themeSegmentedControl)
        themeSectionView.addSubview(themeDescriptionLabel)
        
        // Meal times section
        mealTimesSectionView.addSubview(mealTimesTitleLabel)
        mealTimesSectionView.addSubview(mealTimesDescriptionLabel)
        mealTimesSectionView.addSubview(mealTimesStackView)
        
        setupConstraints()
        setupMealTimesViews()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Theme section
            themeSectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            themeSectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            themeSectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            themeTitleLabel.topAnchor.constraint(equalTo: themeSectionView.topAnchor, constant: 16),
            themeTitleLabel.leadingAnchor.constraint(equalTo: themeSectionView.leadingAnchor, constant: 16),
            themeTitleLabel.trailingAnchor.constraint(equalTo: themeSectionView.trailingAnchor, constant: -16),
            
            themeSegmentedControl.topAnchor.constraint(equalTo: themeTitleLabel.bottomAnchor, constant: 12),
            themeSegmentedControl.leadingAnchor.constraint(equalTo: themeSectionView.leadingAnchor, constant: 16),
            themeSegmentedControl.trailingAnchor.constraint(equalTo: themeSectionView.trailingAnchor, constant: -16),
            
            themeDescriptionLabel.topAnchor.constraint(equalTo: themeSegmentedControl.bottomAnchor, constant: 8),
            themeDescriptionLabel.leadingAnchor.constraint(equalTo: themeSectionView.leadingAnchor, constant: 16),
            themeDescriptionLabel.trailingAnchor.constraint(equalTo: themeSectionView.trailingAnchor, constant: -16),
            themeDescriptionLabel.bottomAnchor.constraint(equalTo: themeSectionView.bottomAnchor, constant: -16),
            
            // Meal times section
            mealTimesSectionView.topAnchor.constraint(equalTo: themeSectionView.bottomAnchor, constant: 20),
            mealTimesSectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mealTimesSectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            mealTimesTitleLabel.topAnchor.constraint(equalTo: mealTimesSectionView.topAnchor, constant: 16),
            mealTimesTitleLabel.leadingAnchor.constraint(equalTo: mealTimesSectionView.leadingAnchor, constant: 16),
            mealTimesTitleLabel.trailingAnchor.constraint(equalTo: mealTimesSectionView.trailingAnchor, constant: -16),
            
            mealTimesDescriptionLabel.topAnchor.constraint(equalTo: mealTimesTitleLabel.bottomAnchor, constant: 8),
            mealTimesDescriptionLabel.leadingAnchor.constraint(equalTo: mealTimesSectionView.leadingAnchor, constant: 16),
            mealTimesDescriptionLabel.trailingAnchor.constraint(equalTo: mealTimesSectionView.trailingAnchor, constant: -16),
            
            mealTimesStackView.topAnchor.constraint(equalTo: mealTimesDescriptionLabel.bottomAnchor, constant: 16),
            mealTimesStackView.leadingAnchor.constraint(equalTo: mealTimesSectionView.leadingAnchor, constant: 16),
            mealTimesStackView.trailingAnchor.constraint(equalTo: mealTimesSectionView.trailingAnchor, constant: -16),
            mealTimesStackView.bottomAnchor.constraint(equalTo: mealTimesSectionView.bottomAnchor, constant: -16),
            
            // Action buttons
            saveButton.topAnchor.constraint(equalTo: mealTimesSectionView.bottomAnchor, constant: 30),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            
            resetButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 16),
            resetButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            resetButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupMealTimesViews() {
        let meals = [
            ("Breakfast", "breakfastStart", "breakfastEnd"),
            ("Lunch", "lunchStart", "lunchEnd"),
            ("Dinner", "dinnerStart", "dinnerEnd"),
            ("Snacks", "snackStart", "snackEnd")
        ]
        
        for (mealName, startKey, endKey) in meals {
            let mealView = createMealTimeView(name: mealName, startKey: startKey, endKey: endKey)
            mealTimesStackView.addArrangedSubview(mealView)
        }
    }
    
    private func createMealTimeView(name: String, startKey: String, endKey: String) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let startPicker = UIDatePicker()
        startPicker.datePickerMode = .time
        startPicker.preferredDatePickerStyle = .compact
        startPicker.tag = 1000 + startKey.hashValue
        startPicker.translatesAutoresizingMaskIntoConstraints = false
        
        let endPicker = UIDatePicker()
        endPicker.datePickerMode = .time
        endPicker.preferredDatePickerStyle = .compact
        endPicker.tag = 2000 + endKey.hashValue
        endPicker.translatesAutoresizingMaskIntoConstraints = false
        
        let toLabel = UILabel()
        toLabel.text = "to"
        toLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        toLabel.textColor = .secondaryLabel
        toLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(nameLabel)
        containerView.addSubview(startPicker)
        containerView.addSubview(toLabel)
        containerView.addSubview(endPicker)
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            nameLabel.widthAnchor.constraint(equalToConstant: 80),
            
            startPicker.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 16),
            startPicker.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            toLabel.leadingAnchor.constraint(equalTo: startPicker.trailingAnchor, constant: 8),
            toLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            endPicker.leadingAnchor.constraint(equalTo: toLabel.trailingAnchor, constant: 8),
            endPicker.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            endPicker.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor),
            
            containerView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        return containerView
    }
    
    private func setupActions() {
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        
        themeSegmentedControl.addTarget(self, action: #selector(themeChanged), for: .valueChanged)
    }
    
    // MARK: - Data Loading
    
    private func loadCurrentPreferences() {
        currentPreferences = preferencesManager.currentPreferences ?? AppPreferencesModel.defaultPreferences
        updateUI()
    }
    
    private func updateUI() {
        guard let preferences = currentPreferences else { return }
        
        // Update theme
        if let themeIndex = AppTheme.allCases.firstIndex(of: preferences.theme) {
            themeSegmentedControl.selectedSegmentIndex = themeIndex
        }
        themeDescriptionLabel.text = preferences.theme.description
        
        // Update meal times
        updateMealTimesUI()
    }
    
    private func updateMealTimesUI() {
        guard let preferences = currentPreferences else { return }
        
        let mealTimes = preferences.defaultMealTimes
        let meals = [
            ("breakfastStart", "breakfastEnd"),
            ("lunchStart", "lunchEnd"),
            ("dinnerStart", "dinnerEnd"),
            ("snackStart", "snackEnd")
        ]
        
        for (index, (startKey, endKey)) in meals.enumerated() {
            if let startPicker = view.viewWithTag(1000 + startKey.hashValue) as? UIDatePicker,
               let endPicker = view.viewWithTag(2000 + endKey.hashValue) as? UIDatePicker {
                
                let startHour = getHourForMeal(mealTimes, key: startKey)
                let endHour = getHourForMeal(mealTimes, key: endKey)
                
                let startDate = Calendar.current.date(bySettingHour: startHour, minute: 0, second: 0, of: Date()) ?? Date()
                let endDate = Calendar.current.date(bySettingHour: endHour, minute: 0, second: 0, of: Date()) ?? Date()
                
                startPicker.date = startDate
                endPicker.date = endDate
            }
        }
    }
    
    private func getHourForMeal(_ mealTimes: MealTimes, key: String) -> Int {
        switch key {
        case "breakfastStart": return mealTimes.breakfastStart
        case "breakfastEnd": return mealTimes.breakfastEnd
        case "lunchStart": return mealTimes.lunchStart
        case "lunchEnd": return mealTimes.lunchEnd
        case "dinnerStart": return mealTimes.dinnerStart
        case "dinnerEnd": return mealTimes.dinnerEnd
        case "snackStart": return mealTimes.snackStart
        case "snackEnd": return mealTimes.snackEnd
        default: return 0
        }
    }
    
    // MARK: - Actions
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func saveButtonTapped() {
        savePreferences()
    }
    
    @objc private func resetButtonTapped() {
        let alert = UIAlertController(
            title: "Reset to Defaults",
            message: "This will reset all preferences to their default values. Are you sure?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { [weak self] _ in
            self?.resetToDefaults()
        })
        
        present(alert, animated: true)
    }
    
    @objc private func themeChanged() {
        let selectedTheme = AppTheme.allCases[themeSegmentedControl.selectedSegmentIndex]
        themeDescriptionLabel.text = selectedTheme.description
    }
    
    // MARK: - Save Preferences
    
    private func savePreferences() {
        guard let userId = Auth.auth().currentUser?.uid else {
            showAlert(title: "Error", message: "No user logged in")
            return
        }
        
        let selectedTheme = AppTheme.allCases[themeSegmentedControl.selectedSegmentIndex]
        
        let mealTimes = getMealTimesFromUI()
        
        let preferences = AppPreferencesModel(
            userId: userId,
            theme: selectedTheme,
            defaultMealTimes: mealTimes,
            createdAt: currentPreferences?.createdAt,
            updatedAt: Date()
        )
        
        preferencesManager.savePreferences(preferences) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.showAlert(title: "Success", message: "Preferences saved successfully") {
                        self?.dismiss(animated: true)
                    }
                case .failure(let error):
                    self?.showAlert(title: "Error", message: "Failed to save preferences: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func getMealTimesFromUI() -> MealTimes {
        let meals = [
            ("breakfastStart", "breakfastEnd"),
            ("lunchStart", "lunchEnd"),
            ("dinnerStart", "dinnerEnd"),
            ("snackStart", "snackEnd")
        ]
        
        var mealTimes = MealTimes.defaultTimes
        
        for (startKey, endKey) in meals {
            if let startPicker = view.viewWithTag(1000 + startKey.hashValue) as? UIDatePicker,
               let endPicker = view.viewWithTag(2000 + endKey.hashValue) as? UIDatePicker {
                
                let startHour = Calendar.current.component(.hour, from: startPicker.date)
                let endHour = Calendar.current.component(.hour, from: endPicker.date)
                
                switch startKey {
                case "breakfastStart": mealTimes.breakfastStart = startHour; mealTimes.breakfastEnd = endHour
                case "lunchStart": mealTimes.lunchStart = startHour; mealTimes.lunchEnd = endHour
                case "dinnerStart": mealTimes.dinnerStart = startHour; mealTimes.dinnerEnd = endHour
                case "snackStart": mealTimes.snackStart = startHour; mealTimes.snackEnd = endHour
                default: break
                }
            }
        }
        
        return mealTimes
    }
    
    private func resetToDefaults() {
        preferencesManager.resetToDefaults { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.loadCurrentPreferences()
                    self?.showAlert(title: "Success", message: "Preferences reset to defaults")
                case .failure(let error):
                    self?.showAlert(title: "Error", message: "Failed to reset preferences: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}

