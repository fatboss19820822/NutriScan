//
//  ProfileSettingsViewController.swift
//  NutriScan
//
//  Created by Raymond on 25/9/2025.
//

import UIKit
import FirebaseAuth
import PhotosUI

class ProfileSettingsViewController: UIViewController {
    
    // MARK: - Properties
    
    private var userProfile: UserProfileModel?
    private var profileImage: UIImage?
    
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
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = .systemGray4
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let changePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change Photo", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let displayNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Display Name"
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let heightTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Height (cm)"
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.keyboardType = .decimalPad
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let weightTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Weight (kg)"
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.keyboardType = .decimalPad
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let activityLevelSegmentedControl: UISegmentedControl = {
        let items = ActivityLevel.allCases.map { $0.displayName }
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 2 // Default to moderately active
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()
    
    private let bmiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tdeeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save Changes", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        loadUserProfile()
        setupKeyboardHandling()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Profile Settings"
        
        // Add navigation bar buttons
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelButtonTapped)
        )
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(changePhotoButton)
        contentView.addSubview(displayNameTextField)
        contentView.addSubview(heightTextField)
        contentView.addSubview(weightTextField)
        contentView.addSubview(activityLevelSegmentedControl)
        contentView.addSubview(bmiLabel)
        contentView.addSubview(tdeeLabel)
        contentView.addSubview(saveButton)
        
        setupConstraints()
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
            
            // Profile image
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            
            // Change photo button
            changePhotoButton.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            changePhotoButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            // Display name
            displayNameTextField.topAnchor.constraint(equalTo: changePhotoButton.bottomAnchor, constant: 30),
            displayNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            displayNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            displayNameTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Height
            heightTextField.topAnchor.constraint(equalTo: displayNameTextField.bottomAnchor, constant: 16),
            heightTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            heightTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            heightTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Weight
            weightTextField.topAnchor.constraint(equalTo: heightTextField.bottomAnchor, constant: 16),
            weightTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            weightTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            weightTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Activity level
            activityLevelSegmentedControl.topAnchor.constraint(equalTo: weightTextField.bottomAnchor, constant: 20),
            activityLevelSegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            activityLevelSegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            activityLevelSegmentedControl.heightAnchor.constraint(equalToConstant: 32),
            
            // BMI label
            bmiLabel.topAnchor.constraint(equalTo: activityLevelSegmentedControl.bottomAnchor, constant: 20),
            bmiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            bmiLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // TDEE label
            tdeeLabel.topAnchor.constraint(equalTo: bmiLabel.bottomAnchor, constant: 8),
            tdeeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            tdeeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Save button
            saveButton.topAnchor.constraint(equalTo: tdeeLabel.bottomAnchor, constant: 30),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupActions() {
        changePhotoButton.addTarget(self, action: #selector(changePhotoButtonTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        // Add tap gesture to profile image
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImageView.addGestureRecognizer(tapGesture)
        
        // Add text field change observers
        heightTextField.addTarget(self, action: #selector(updateBMIDisplay), for: .editingChanged)
        weightTextField.addTarget(self, action: #selector(updateBMIDisplay), for: .editingChanged)
        activityLevelSegmentedControl.addTarget(self, action: #selector(updateTDEE), for: .valueChanged)
        
        // Add Done button to number pad keyboards
        addDoneButtonToNumberPad()
        
        // Add tap gesture to dismiss keyboard
        let tapToDismiss = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapToDismiss.cancelsTouchesInView = false
        view.addGestureRecognizer(tapToDismiss)
    }
    
    private func setupKeyboardHandling() {
        // Add keyboard observers
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Data Loading
    
    private func loadUserProfile() {
        FirestoreManager.shared.fetchUserProfile { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    self?.userProfile = profile
                    self?.populateFields()
                case .failure(let error):
                    print("Error loading user profile: \(error)")
                    // Continue with empty profile
                    self?.userProfile = nil
                }
            }
        }
    }
    
    private func populateFields() {
        guard let profile = userProfile else { return }
        
        displayNameTextField.text = profile.displayName
        
        heightTextField.text = profile.height != nil ? String(format: "%.0f", profile.height!) : ""
        weightTextField.text = profile.weight != nil ? String(format: "%.1f", profile.weight!) : ""
        
        if let activityIndex = ActivityLevel.allCases.firstIndex(of: profile.activityLevel) {
            activityLevelSegmentedControl.selectedSegmentIndex = activityIndex
        }
        
        updateBMIDisplay()
        updateTDEE()
        
        // Load profile image if available
        if let imageData = profile.profileImageURL {
            loadProfileImage(from: imageData)
        }
    }
    
    private func loadProfileImage(from base64String: String) {
        // Check if it's a base64 string or URL
        if base64String.hasPrefix("data:") || base64String.hasPrefix("http") {
            // It's a URL, load from URL
            guard let url = URL(string: base64String) else { return }
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let data = data, let image = UIImage(data: data) else { return }
                DispatchQueue.main.async {
                    self?.profileImageView.image = image
                    self?.profileImage = image
                }
            }.resume()
        } else {
            // It's base64 data
            guard let imageData = Data(base64Encoded: base64String),
                  let image = UIImage(data: imageData) else { return }
            
            DispatchQueue.main.async {
                self.profileImageView.image = image
                self.profileImage = image
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func changePhotoButtonTapped() {
        showImagePicker()
    }
    
    @objc private func profileImageTapped() {
        showImagePicker()
    }
    
    @objc private func saveButtonTapped() {
        saveProfile()
    }
    
    @objc private func updateBMIDisplay() {
        guard let heightText = heightTextField.text,
              let weightText = weightTextField.text,
              let height = Double(heightText),
              let weight = Double(weightText),
              height > 0, weight > 0 else {
            bmiLabel.text = ""
            return
        }
        
        let heightInMeters = height / 100.0
        let bmi = weight / (heightInMeters * heightInMeters)
        
        var category = ""
        switch bmi {
        case ..<18.5:
            category = "Underweight"
        case 18.5..<25:
            category = "Normal weight"
        case 25..<30:
            category = "Overweight"
        default:
            category = "Obese"
        }
        
        bmiLabel.text = String(format: "BMI: %.1f (%@)", bmi, category)
        updateTDEE()
    }
    
    @objc private func updateTDEE() {
        guard let heightText = heightTextField.text,
              let weightText = weightTextField.text,
              let height = Double(heightText),
              let weight = Double(weightText),
              height > 0, weight > 0 else {
            tdeeLabel.text = ""
            return
        }
        
        let activityLevel = ActivityLevel.allCases[activityLevelSegmentedControl.selectedSegmentIndex]
        
        // Calculate BMR using Mifflin-St Jeor Equation (using age 30 as default)
        let age = 30.0
        let bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5
        let tdee = bmr * activityLevel.multiplier
        
        tdeeLabel.text = String(format: "Estimated daily calories: %.0f cal", tdee)
    }
    
    // MARK: - Image Picker
    
    private func showImagePicker() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    // MARK: - Save Profile
    
    private func saveProfile() {
        guard let userId = Auth.auth().currentUser?.uid else {
            showAlert(title: "Error", message: "No user logged in")
            return
        }
        
        let displayName = displayNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let height = Double(heightTextField.text ?? "")
        let weight = Double(weightTextField.text ?? "")
        let activityLevel = ActivityLevel.allCases[activityLevelSegmentedControl.selectedSegmentIndex]
        
        // Update Firebase Auth display name if changed
        if let displayName = displayName, !displayName.isEmpty {
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = displayName
            changeRequest?.commitChanges { [weak self] error in
                if let error = error {
                    print("Error updating display name: \(error)")
                }
            }
        }
        
        // Convert profile image to base64 if changed
        var profileImageData: String? = nil
        if let image = profileImage {
            if let base64Image = convertImageToBase64(image) {
                profileImageData = base64Image
            } else {
                showAlert(title: "Image Too Large", message: "The selected image is too large to save. Please choose a smaller image or take a new photo.")
                return
            }
        } else {
            profileImageData = userProfile?.profileImageURL
        }
        
        saveProfileToFirestore(
            displayName: displayName,
            height: height,
            weight: weight,
            activityLevel: activityLevel,
            profileImageURL: profileImageData
        )
    }
    
    private func convertImageToBase64(_ image: UIImage) -> String? {
        // Resize image to a maximum dimension of 300px to reduce file size
        let resizedImage = resizeImage(image, to: CGSize(width: 300, height: 300))
        
        // Try different compression qualities until we get under 1MB limit
        let compressionQualities: [CGFloat] = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]
        let maxSizeBytes = 1_000_000 // 1MB limit for Firestore
        
        for quality in compressionQualities {
            guard let imageData = resizedImage.jpegData(compressionQuality: quality) else { continue }
            
            // Check if the raw data is under 750KB (base64 encoding increases size by ~33%)
            if imageData.count < 750_000 {
                return imageData.base64EncodedString()
            }
        }
        
        // If still too large, return nil and show error
        return nil
    }
    
    private func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage {
        let aspectRatio = image.size.width / image.size.height
        var newSize = size
        
        if aspectRatio > 1 {
            // Landscape
            newSize.height = size.width / aspectRatio
        } else {
            // Portrait
            newSize.width = size.height * aspectRatio
        }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage ?? image
    }
    
    private func saveProfileToFirestore(
        displayName: String?,
        height: Double?,
        weight: Double?,
        activityLevel: ActivityLevel,
        profileImageURL: String?
    ) {
        FirestoreManager.shared.saveUserProfile(
            displayName: displayName,
            height: height,
            weight: weight,
            activityLevel: activityLevel,
            profileImageURL: profileImageURL
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.showAlert(title: "Success", message: "Profile updated successfully") {
                        self?.dismiss(animated: true)
                    }
                case .failure(let error):
                    self?.showAlert(title: "Error", message: "Failed to save profile: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Keyboard Handling
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardHeight = keyboardFrame.cgRectValue.height
        
        // Add padding for the keyboard
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight + 20, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        // Scroll to the active text field
        if let activeTextField = getActiveTextField() {
            scrollToTextField(activeTextField, keyboardHeight: keyboardHeight)
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        // Reset scroll view insets
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func getActiveTextField() -> UITextField? {
        if displayNameTextField.isFirstResponder {
            return displayNameTextField
        } else if heightTextField.isFirstResponder {
            return heightTextField
        } else if weightTextField.isFirstResponder {
            return weightTextField
        }
        return nil
    }
    
    private func scrollToTextField(_ textField: UITextField, keyboardHeight: CGFloat) {
        let textFieldFrame = textField.convert(textField.bounds, to: scrollView)
        let visibleHeight = scrollView.frame.height - keyboardHeight - 20
        
        if textFieldFrame.maxY > visibleHeight {
            let scrollPoint = CGPoint(x: 0, y: textFieldFrame.maxY - visibleHeight + 20)
            scrollView.setContentOffset(scrollPoint, animated: true)
        }
    }
    
    private func addDoneButtonToNumberPad() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        
        toolbar.items = [flexibleSpace, doneButton]
        
        heightTextField.inputAccessoryView = toolbar
        weightTextField.inputAccessoryView = toolbar
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

// MARK: - PHPickerViewControllerDelegate

extension ProfileSettingsViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let result = results.first else { return }
        
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            guard let image = object as? UIImage else { return }
            
            DispatchQueue.main.async {
                self?.profileImageView.image = image
                self?.profileImage = image
            }
        }
    }
}
