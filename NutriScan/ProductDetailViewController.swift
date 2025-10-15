//
//  ProductDetailViewController.swift
//  NutriScan
//
//  Displays detailed nutritional information for scanned products
//

import UIKit
import FirebaseAuth

class ProductDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    private let product: FoodProduct
    private var servingAmount: Double = 100.0  // Default serving amount in grams
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.backgroundColor = .systemGroupedBackground
        return scroll
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .systemGray6
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let productNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let brandLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private let barcodeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .tertiaryLabel
        label.textAlignment = .center
        return label
    }()
    
    // Serving size card
    private let servingCard: UIView = {
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
    
    private let servingSizeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Serving Size"
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private let servingTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.text = "100"
        textField.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        textField.textColor = .systemBlue
        textField.textAlignment = .right
        textField.keyboardType = .numberPad
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .systemGray6
        return textField
    }()
    
    private let servingUnitLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "g"
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    // Nutrition facts card
    private let nutritionCard: UIView = {
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
    
    private let nutritionTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Nutrition Facts"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private let nutritionStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        stack.distribution = .fill
        return stack
    }()
    
    private let mealCategoryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Meal Category"
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private let mealCategorySegment: UISegmentedControl = {
        let items = ["Breakfast", "Lunch", "Dinner", "Snacks"]
        let segment = UISegmentedControl(items: items)
        segment.translatesAutoresizingMaskIntoConstraints = false
        segment.selectedSegmentIndex = 0
        return segment
    }()
    
    // MARK: - Lifecycle
    
    init(product: FoodProduct) {
        self.product = product
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        populateData()
        loadProductImage()
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = "Product Details"
        
        // Add navigation bar button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Add",
            style: .done,
            target: self,
            action: #selector(saveButtonTapped)
        )
        
        // Add scroll view
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Add all components
        contentView.addSubview(productImageView)
        contentView.addSubview(productNameLabel)
        contentView.addSubview(brandLabel)
        contentView.addSubview(barcodeLabel)
        contentView.addSubview(servingCard)
        contentView.addSubview(nutritionCard)
        
        // Serving card subviews (including meal category)
        servingCard.addSubview(servingSizeLabel)
        servingCard.addSubview(servingTextField)
        servingCard.addSubview(servingUnitLabel)
        servingCard.addSubview(mealCategoryLabel)
        servingCard.addSubview(mealCategorySegment)
        
        // Nutrition card subviews
        nutritionCard.addSubview(nutritionTitleLabel)
        nutritionCard.addSubview(nutritionStackView)
        
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
            
            // Product Image
            productImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            productImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            productImageView.widthAnchor.constraint(equalToConstant: 200),
            productImageView.heightAnchor.constraint(equalToConstant: 200),
            
            // Product Name
            productNameLabel.topAnchor.constraint(equalTo: productImageView.bottomAnchor, constant: 20),
            productNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            productNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Brand
            brandLabel.topAnchor.constraint(equalTo: productNameLabel.bottomAnchor, constant: 8),
            brandLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            brandLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Barcode
            barcodeLabel.topAnchor.constraint(equalTo: brandLabel.bottomAnchor, constant: 4),
            barcodeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            barcodeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Serving Card
            servingCard.topAnchor.constraint(equalTo: barcodeLabel.bottomAnchor, constant: 24),
            servingCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            servingCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            servingSizeLabel.topAnchor.constraint(equalTo: servingCard.topAnchor, constant: 16),
            servingSizeLabel.leadingAnchor.constraint(equalTo: servingCard.leadingAnchor, constant: 16),
            
            servingTextField.centerYAnchor.constraint(equalTo: servingSizeLabel.centerYAnchor),
            servingTextField.trailingAnchor.constraint(equalTo: servingUnitLabel.leadingAnchor, constant: -8),
            servingTextField.widthAnchor.constraint(equalToConstant: 80),
            
            servingUnitLabel.centerYAnchor.constraint(equalTo: servingSizeLabel.centerYAnchor),
            servingUnitLabel.trailingAnchor.constraint(equalTo: servingCard.trailingAnchor, constant: -16),
            
            mealCategoryLabel.topAnchor.constraint(equalTo: servingSizeLabel.bottomAnchor, constant: 20),
            mealCategoryLabel.leadingAnchor.constraint(equalTo: servingCard.leadingAnchor, constant: 16),
            mealCategoryLabel.trailingAnchor.constraint(equalTo: servingCard.trailingAnchor, constant: -16),
            
            mealCategorySegment.topAnchor.constraint(equalTo: mealCategoryLabel.bottomAnchor, constant: 12),
            mealCategorySegment.leadingAnchor.constraint(equalTo: servingCard.leadingAnchor, constant: 16),
            mealCategorySegment.trailingAnchor.constraint(equalTo: servingCard.trailingAnchor, constant: -16),
            mealCategorySegment.bottomAnchor.constraint(equalTo: servingCard.bottomAnchor, constant: -16),
            
            // Nutrition Card
            nutritionCard.topAnchor.constraint(equalTo: servingCard.bottomAnchor, constant: 16),
            nutritionCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nutritionCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            nutritionCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
            
            nutritionTitleLabel.topAnchor.constraint(equalTo: nutritionCard.topAnchor, constant: 20),
            nutritionTitleLabel.leadingAnchor.constraint(equalTo: nutritionCard.leadingAnchor, constant: 20),
            nutritionTitleLabel.trailingAnchor.constraint(equalTo: nutritionCard.trailingAnchor, constant: -20),
            
            nutritionStackView.topAnchor.constraint(equalTo: nutritionTitleLabel.bottomAnchor, constant: 16),
            nutritionStackView.leadingAnchor.constraint(equalTo: nutritionCard.leadingAnchor, constant: 20),
            nutritionStackView.trailingAnchor.constraint(equalTo: nutritionCard.trailingAnchor, constant: -20),
            nutritionStackView.bottomAnchor.constraint(equalTo: nutritionCard.bottomAnchor, constant: -20),
        ])
    }
    
    private func setupActions() {
        servingTextField.addTarget(self, action: #selector(servingTextFieldChanged), for: .editingChanged)
        servingTextField.delegate = self
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Data Population
    
    private func populateData() {
        productNameLabel.text = product.name
        brandLabel.text = product.brand
        barcodeLabel.text = "Barcode: \(product.barcode)"
        
        updateNutritionFacts()
    }
    
    private func updateNutritionFacts() {
        // Clear existing nutrition rows
        nutritionStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Calculate values based on serving size
        let multiplier = servingAmount / 100.0
        
        // Add nutrition rows
        addNutritionRow(title: "Calories", value: product.calories * multiplier, unit: "kcal", color: .systemOrange)
        addNutritionRow(title: "Protein", value: product.protein * multiplier, unit: "g", color: .systemBlue)
        addNutritionRow(title: "Carbohydrates", value: product.carbs * multiplier, unit: "g", color: .systemGreen)
        addNutritionRow(title: "Fat", value: product.fat * multiplier, unit: "g", color: .systemPurple)
        
        if product.fiber > 0 {
            addNutritionRow(title: "Fiber", value: product.fiber * multiplier, unit: "g", color: .systemBrown)
        }
        
        if product.sugar > 0 {
            addNutritionRow(title: "Sugar", value: product.sugar * multiplier, unit: "g", color: .systemPink)
        }
        
        if product.sodium > 0 {
            addNutritionRow(title: "Sodium", value: product.sodium * multiplier, unit: "mg", color: .systemRed)
        }
    }
    
    private func addNutritionRow(title: String, value: Double, unit: String, color: UIColor) {
        let row = NutritionRowView(title: title, value: value, unit: unit, color: color)
        nutritionStackView.addArrangedSubview(row)
    }
    
    private func loadProductImage() {
        guard let imageUrlString = product.imageUrl,
              let imageUrl = URL(string: imageUrlString) else {
            productImageView.image = UIImage(systemName: "photo")
            productImageView.tintColor = .systemGray
            return
        }
        
        // Load image asynchronously
        URLSession.shared.dataTask(with: imageUrl) { [weak self] data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    self?.productImageView.image = UIImage(systemName: "photo")
                    self?.productImageView.tintColor = .systemGray
                }
                return
            }
            
            DispatchQueue.main.async {
                self?.productImageView.image = image
            }
        }.resume()
    }
    
    // MARK: - Actions
    
    @objc private func servingTextFieldChanged() {
        if let text = servingTextField.text, let value = Double(text), value > 0 {
            servingAmount = value
            updateNutritionFacts()
        }
    }
    
    @objc private func saveButtonTapped() {
        // Dismiss keyboard
        view.endEditing(true)
        
        // Check if user is logged in
        guard Auth.auth().currentUser != nil else {
            showErrorAlert(error: NSError(domain: "ProductDetailViewController", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No user logged in"]))
            return
        }
        
        // Calculate time based on selected meal category
        let selectedDate = getDateForMealCategory()
        
        // Calculate nutrition values based on serving size
        let multiplier = servingAmount / 100.0
        
        // Show loading indicator
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        // Save to Firestore using the existing addFoodEntry method
        FirestoreManager.shared.addFoodEntry(
            name: product.name,
            barcode: product.barcode,
            calories: product.calories * multiplier,
            protein: product.protein * multiplier,
            carbs: product.carbs * multiplier,
            fat: product.fat * multiplier,
            date: selectedDate
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.navigationItem.rightBarButtonItem?.isEnabled = true
                
                switch result {
                case .success:
                    // Show success message
                    self?.showSuccessAlert()
                    
                case .failure(let error):
                    // Show error message
                    self?.showErrorAlert(error: error)
                }
            }
        }
    }
    
    private func getDateForMealCategory() -> Date {
        let mealCategories = ["Breakfast", "Lunch", "Dinner", "Snacks"]
        let selectedCategory = mealCategories[mealCategorySegment.selectedSegmentIndex]
        
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        
        // Set time based on meal category
        switch selectedCategory {
        case "Breakfast":
            components.hour = 8
            components.minute = 0
        case "Lunch":
            components.hour = 12
            components.minute = 30
        case "Dinner":
            components.hour = 18
            components.minute = 30
        case "Snacks":
            components.hour = 15
            components.minute = 0
        default:
            return Date()
        }
        
        return calendar.date(from: components) ?? Date()
    }
    
    // MARK: - Helper Methods
    
    private func showSuccessAlert() {
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // Show brief success message
        let alert = UIAlertController(
            title: "✓ Added to Log",
            message: nil,
            preferredStyle: .alert
        )
        
        present(alert, animated: true)
        
        // Auto-dismiss after 0.5 seconds and navigate to log
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            alert.dismiss(animated: true) {
                self?.navigateToLog()
            }
        }
    }
    
    private func showErrorAlert(error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: "Failed to save food item: \(error.localizedDescription)",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func navigateToLog() {
        // Pop this view first
        navigationController?.popViewController(animated: false)
        
        // Navigate to Log tab
        if let nav = navigationController,
           let tabBarController = nav.tabBarController {
            tabBarController.selectedIndex = 2  // Log tab
        } else if let presented = presentingViewController {
            // If presented modally, dismiss and navigate
            dismiss(animated: false) {
                if let tabBarController = presented as? UITabBarController {
                    tabBarController.selectedIndex = 2
                } else if let nav = presented as? UINavigationController,
                          let tabBarController = nav.tabBarController {
                    tabBarController.selectedIndex = 2
                }
            }
        }
    }
}

// MARK: - Custom Nutrition Row View

class NutritionRowView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .right
        return label
    }()
    
    private let colorBar: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 2
        return view
    }()
    
    init(title: String, value: Double, unit: String, color: UIColor) {
        super.init(frame: .zero)
        
        titleLabel.text = title
        valueLabel.text = String(format: "%.1f %@", value, unit)
        valueLabel.textColor = color
        colorBar.backgroundColor = color
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemGray6
        layer.cornerRadius = 10
        
        addSubview(colorBar)
        addSubview(titleLabel)
        addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            colorBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            colorBar.topAnchor.constraint(equalTo: topAnchor),
            colorBar.bottomAnchor.constraint(equalTo: bottomAnchor),
            colorBar.widthAnchor.constraint(equalToConstant: 4),
            
            titleLabel.leadingAnchor.constraint(equalTo: colorBar.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8),
            
            heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}

// MARK: - UITextFieldDelegate

extension ProductDetailViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Allow only numbers and one decimal point
        let allowedCharacters = CharacterSet(charactersIn: "0123456789.")
        let characterSet = CharacterSet(charactersIn: string)
        
        // Check if the new text would contain more than one decimal point
        if let text = textField.text,
           let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            let decimalCount = updatedText.filter { $0 == "." }.count
            if decimalCount > 1 {
                return false
            }
        }
        
        return allowedCharacters.isSuperset(of: characterSet)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

