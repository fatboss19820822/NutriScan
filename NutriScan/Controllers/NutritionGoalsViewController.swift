//
//  NutritionGoalsViewController.swift
//  NutriScan
//
//  Created by Raymond on 25/9/2025.
//

import UIKit

class NutritionGoalsViewController: UIViewController {
    
    // MARK: - Properties
    private var currentGoals: NutritionGoalsModel?
    private var isLoading = false
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.backgroundColor = .systemGroupedBackground
        scroll.keyboardDismissMode = .onDrag
        return scroll
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Daily Nutrition Goals"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Set your daily nutrition targets to track your progress"
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private let goalsCard: UIView = {
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
    
    // Calorie Goal
    private let calorieLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Calories"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private let calorieTextField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.placeholder = "2000"
        field.keyboardType = .numberPad
        field.borderStyle = .roundedRect
        field.font = UIFont.systemFont(ofSize: 16)
        field.textAlignment = .center
        return field
    }()
    
    private let calorieUnitLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "cal"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()
    
    // Protein Goal
    private let proteinLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Protein"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private let proteinTextField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.placeholder = "150"
        field.keyboardType = .numberPad
        field.borderStyle = .roundedRect
        field.font = UIFont.systemFont(ofSize: 16)
        field.textAlignment = .center
        return field
    }()
    
    private let proteinUnitLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "g"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()
    
    // Carbs Goal
    private let carbsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Carbohydrates"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private let carbsTextField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.placeholder = "250"
        field.keyboardType = .numberPad
        field.borderStyle = .roundedRect
        field.font = UIFont.systemFont(ofSize: 16)
        field.textAlignment = .center
        return field
    }()
    
    private let carbsUnitLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "g"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()
    
    // Fat Goal
    private let fatLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Fat"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private let fatTextField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.placeholder = "65"
        field.keyboardType = .numberPad
        field.borderStyle = .roundedRect
        field.font = UIFont.systemFont(ofSize: 16)
        field.textAlignment = .center
        return field
    }()
    
    private let fatUnitLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "g"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Save Goals", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        return button
    }()
    
    private let calculateButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Calculate Based on Profile", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.systemGreen, for: .normal)
        return button
    }()
    
    private let resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Reset to Defaults", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        loadCurrentGoals()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = "Nutrition Goals"
        
        // Add close button
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )
        
        // Add scroll view
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Add all components
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(goalsCard)
        contentView.addSubview(saveButton)
        contentView.addSubview(calculateButton)
        contentView.addSubview(resetButton)
        contentView.addSubview(loadingIndicator)
        
        // Goals card subviews
        goalsCard.addSubview(calorieLabel)
        goalsCard.addSubview(calorieTextField)
        goalsCard.addSubview(calorieUnitLabel)
        goalsCard.addSubview(proteinLabel)
        goalsCard.addSubview(proteinTextField)
        goalsCard.addSubview(proteinUnitLabel)
        goalsCard.addSubview(carbsLabel)
        goalsCard.addSubview(carbsTextField)
        goalsCard.addSubview(carbsUnitLabel)
        goalsCard.addSubview(fatLabel)
        goalsCard.addSubview(fatTextField)
        goalsCard.addSubview(fatUnitLabel)
        
        setupConstraints()
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
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Goals Card
            goalsCard.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
            goalsCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            goalsCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Calorie Goal
            calorieLabel.topAnchor.constraint(equalTo: goalsCard.topAnchor, constant: 20),
            calorieLabel.leadingAnchor.constraint(equalTo: goalsCard.leadingAnchor, constant: 20),
            calorieLabel.trailingAnchor.constraint(equalTo: goalsCard.trailingAnchor, constant: -20),
            
            calorieTextField.topAnchor.constraint(equalTo: calorieLabel.bottomAnchor, constant: 8),
            calorieTextField.leadingAnchor.constraint(equalTo: goalsCard.leadingAnchor, constant: 20),
            calorieTextField.widthAnchor.constraint(equalToConstant: 100),
            calorieTextField.heightAnchor.constraint(equalToConstant: 44),
            
            calorieUnitLabel.leadingAnchor.constraint(equalTo: calorieTextField.trailingAnchor, constant: 8),
            calorieUnitLabel.centerYAnchor.constraint(equalTo: calorieTextField.centerYAnchor),
            
            // Protein Goal
            proteinLabel.topAnchor.constraint(equalTo: calorieTextField.bottomAnchor, constant: 20),
            proteinLabel.leadingAnchor.constraint(equalTo: goalsCard.leadingAnchor, constant: 20),
            proteinLabel.trailingAnchor.constraint(equalTo: goalsCard.trailingAnchor, constant: -20),
            
            proteinTextField.topAnchor.constraint(equalTo: proteinLabel.bottomAnchor, constant: 8),
            proteinTextField.leadingAnchor.constraint(equalTo: goalsCard.leadingAnchor, constant: 20),
            proteinTextField.widthAnchor.constraint(equalToConstant: 100),
            proteinTextField.heightAnchor.constraint(equalToConstant: 44),
            
            proteinUnitLabel.leadingAnchor.constraint(equalTo: proteinTextField.trailingAnchor, constant: 8),
            proteinUnitLabel.centerYAnchor.constraint(equalTo: proteinTextField.centerYAnchor),
            
            // Carbs Goal
            carbsLabel.topAnchor.constraint(equalTo: proteinTextField.bottomAnchor, constant: 20),
            carbsLabel.leadingAnchor.constraint(equalTo: goalsCard.leadingAnchor, constant: 20),
            carbsLabel.trailingAnchor.constraint(equalTo: goalsCard.trailingAnchor, constant: -20),
            
            carbsTextField.topAnchor.constraint(equalTo: carbsLabel.bottomAnchor, constant: 8),
            carbsTextField.leadingAnchor.constraint(equalTo: goalsCard.leadingAnchor, constant: 20),
            carbsTextField.widthAnchor.constraint(equalToConstant: 100),
            carbsTextField.heightAnchor.constraint(equalToConstant: 44),
            
            carbsUnitLabel.leadingAnchor.constraint(equalTo: carbsTextField.trailingAnchor, constant: 8),
            carbsUnitLabel.centerYAnchor.constraint(equalTo: carbsTextField.centerYAnchor),
            
            // Fat Goal
            fatLabel.topAnchor.constraint(equalTo: carbsTextField.bottomAnchor, constant: 20),
            fatLabel.leadingAnchor.constraint(equalTo: goalsCard.leadingAnchor, constant: 20),
            fatLabel.trailingAnchor.constraint(equalTo: goalsCard.trailingAnchor, constant: -20),
            
            fatTextField.topAnchor.constraint(equalTo: fatLabel.bottomAnchor, constant: 8),
            fatTextField.leadingAnchor.constraint(equalTo: goalsCard.leadingAnchor, constant: 20),
            fatTextField.widthAnchor.constraint(equalToConstant: 100),
            fatTextField.heightAnchor.constraint(equalToConstant: 44),
            fatTextField.bottomAnchor.constraint(equalTo: goalsCard.bottomAnchor, constant: -20),
            
            fatUnitLabel.leadingAnchor.constraint(equalTo: fatTextField.trailingAnchor, constant: 8),
            fatUnitLabel.centerYAnchor.constraint(equalTo: fatTextField.centerYAnchor),
            
            // Buttons
            saveButton.topAnchor.constraint(equalTo: goalsCard.bottomAnchor, constant: 30),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            
            calculateButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 16),
            calculateButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            resetButton.topAnchor.constraint(equalTo: calculateButton.bottomAnchor, constant: 16),
            resetButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            resetButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            // Loading Indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: saveButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: saveButton.centerYAnchor)
        ])
    }
    
    private func setupActions() {
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        calculateButton.addTarget(self, action: #selector(calculateTapped), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)
    }
    
    // MARK: - Data Loading
    private func loadCurrentGoals() {
        loadingIndicator.startAnimating()
        saveButton.isEnabled = false
        
        FirestoreManager.shared.fetchNutritionGoals { [weak self] result in
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
                self?.saveButton.isEnabled = true
                
                switch result {
                case .success(let goals):
                    self?.currentGoals = goals
                    self?.populateFields(with: goals)
                case .failure(let error):
                    print("Error loading goals: \(error.localizedDescription)")
                    self?.showAlert(title: "Error", message: "Failed to load current goals. Using defaults.")
                    self?.populateFields(with: NutritionGoalsModel.defaultGoals)
                }
            }
        }
    }
    
    private func populateFields(with goals: NutritionGoalsModel?) {
        let goalsToUse = goals ?? NutritionGoalsModel.defaultGoals
        
        calorieTextField.text = String(format: "%.0f", goalsToUse.dailyCalorieGoal)
        proteinTextField.text = String(format: "%.0f", goalsToUse.dailyProteinGoal)
        carbsTextField.text = String(format: "%.0f", goalsToUse.dailyCarbsGoal)
        fatTextField.text = String(format: "%.0f", goalsToUse.dailyFatGoal)
    }
    
    // MARK: - Actions
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func saveTapped() {
        guard !isLoading else { return }
        
        // Validate inputs
        guard let calorieText = calorieTextField.text, !calorieText.isEmpty,
              let proteinText = proteinTextField.text, !proteinText.isEmpty,
              let carbsText = carbsTextField.text, !carbsText.isEmpty,
              let fatText = fatTextField.text, !fatText.isEmpty,
              let calorieGoal = Double(calorieText), calorieGoal > 0,
              let proteinGoal = Double(proteinText), proteinGoal > 0,
              let carbsGoal = Double(carbsText), carbsGoal > 0,
              let fatGoal = Double(fatText), fatGoal > 0 else {
            showAlert(title: "Invalid Input", message: "Please enter valid numbers for all goals.")
            return
        }
        
        // Validate reasonable ranges
        guard calorieGoal >= 1000 && calorieGoal <= 5000,
              proteinGoal >= 20 && proteinGoal <= 500,
              carbsGoal >= 50 && carbsGoal <= 1000,
              fatGoal >= 20 && fatGoal <= 300 else {
            showAlert(title: "Invalid Range", message: "Please enter values within reasonable ranges:\n• Calories: 1000-5000\n• Protein: 20-500g\n• Carbs: 50-1000g\n• Fat: 20-300g")
            return
        }
        
        saveGoals(calorieGoal: calorieGoal, proteinGoal: proteinGoal, carbsGoal: carbsGoal, fatGoal: fatGoal)
    }
    
    @objc private func calculateTapped() {
        // Load user profile and calculate recommended goals
        FirestoreManager.shared.fetchUserProfile { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    if let profile = profile,
                       let height = profile.height,
                       let weight = profile.weight {
                        // Calculate goals based on user profile
                        FirestoreManager.shared.calculateRecommendedGoals(
                            height: height,
                            weight: weight,
                            activityLevel: profile.activityLevel
                        ) { result in
                            DispatchQueue.main.async {
                                switch result {
                                case .success(let recommendedGoals):
                                    self?.populateFields(with: recommendedGoals)
                                    self?.showAlert(
                                        title: "Goals Calculated",
                                        message: "Goals have been calculated based on your profile:\n• Height: \(profile.heightString ?? "N/A")\n• Weight: \(profile.weightString ?? "N/A")\n• Activity Level: \(profile.activityLevel.displayName)"
                                    )
                                case .failure(let error):
                                    self?.showAlert(title: "Error", message: "Failed to calculate goals: \(error.localizedDescription)")
                                }
                            }
                        }
                    } else {
                        self?.showAlert(
                            title: "Profile Incomplete",
                            message: "Please complete your profile (height, weight, and activity level) in Profile Settings to calculate personalized nutrition goals."
                        )
                    }
                case .failure(let error):
                    self?.showAlert(title: "Error", message: "Failed to load profile: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc private func resetTapped() {
        let alert = UIAlertController(
            title: "Reset to Defaults",
            message: "Are you sure you want to reset all goals to default values?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { [weak self] _ in
            self?.populateFields(with: NutritionGoalsModel.defaultGoals)
        })
        
        present(alert, animated: true)
    }
    
    private func saveGoals(calorieGoal: Double, proteinGoal: Double, carbsGoal: Double, fatGoal: Double) {
        isLoading = true
        loadingIndicator.startAnimating()
        saveButton.isEnabled = false
        saveButton.setTitle("Saving...", for: .normal)
        
        FirestoreManager.shared.saveNutritionGoals(
            calorieGoal: calorieGoal,
            proteinGoal: proteinGoal,
            carbsGoal: carbsGoal,
            fatGoal: fatGoal
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.loadingIndicator.stopAnimating()
                self?.saveButton.isEnabled = true
                self?.saveButton.setTitle("Save Goals", for: .normal)
                
                switch result {
                case .success:
                    self?.showAlert(title: "Success", message: "Your nutrition goals have been updated!") {
                        self?.dismiss(animated: true)
                    }
                case .failure(let error):
                    print("Error saving goals: \(error.localizedDescription)")
                    self?.showAlert(title: "Error", message: "Failed to save goals. Please try again.")
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
