//
//  ProfileViewController.swift
//  NutriScan
//
//  Created by Raymond on 25/9/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import UserNotifications

class ProfileViewController: UIViewController, TimePickerDelegate {
    
    // MARK: - Properties
    
    private var userProfile: UserProfileModel?
    private var profileListener: ListenerRegistration?
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = .systemGray4
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 60
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = UIColor.systemBlue.cgColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let providerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUserData()
        startProfileListener()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUserData()
    }
    
    deinit {
        profileListener?.remove()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Profile"
        
        // Create profile settings button
        let settingsButton = UIButton(type: .system)
        settingsButton.setTitle("Profile Settings", for: .normal)
        settingsButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        settingsButton.backgroundColor = .systemGray6
        settingsButton.layer.cornerRadius = 8
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        
        // Create notification button
        let notificationButton = UIButton(type: .system)
        notificationButton.setTitle("🔔 Meal Reminders", for: .normal)
        notificationButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        notificationButton.backgroundColor = .systemBlue
        notificationButton.setTitleColor(.white, for: .normal)
        notificationButton.layer.cornerRadius = 8
        notificationButton.translatesAutoresizingMaskIntoConstraints = false
        notificationButton.addTarget(self, action: #selector(notificationButtonTapped), for: .touchUpInside)
        
        // Create goals button
        let goalsButton = UIButton(type: .system)
        goalsButton.setTitle("Nutritional Goals", for: .normal)
        goalsButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        goalsButton.backgroundColor = .systemGray6
        goalsButton.layer.cornerRadius = 8
        goalsButton.translatesAutoresizingMaskIntoConstraints = false
        goalsButton.addTarget(self, action: #selector(goalsButtonTapped), for: .touchUpInside)
        
        // Create app preferences button
        let preferencesButton = UIButton(type: .system)
        preferencesButton.setTitle("⚙️ App Preferences", for: .normal)
        preferencesButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        preferencesButton.backgroundColor = .systemGray6
        preferencesButton.layer.cornerRadius = 8
        preferencesButton.translatesAutoresizingMaskIntoConstraints = false
        preferencesButton.addTarget(self, action: #selector(preferencesButtonTapped), for: .touchUpInside)
        
        // Create logout button
        let logoutButton = UIButton(type: .system)
        logoutButton.setTitle("Log Out", for: .normal)
        logoutButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        logoutButton.backgroundColor = .systemRed
        logoutButton.setTitleColor(.white, for: .normal)
        logoutButton.layer.cornerRadius = 8
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(emailLabel)
        view.addSubview(providerLabel)
        view.addSubview(settingsButton)
        view.addSubview(notificationButton)
        view.addSubview(goalsButton)
        view.addSubview(preferencesButton)
        view.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            profileImageView.heightAnchor.constraint(equalToConstant: 120),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            providerLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 4),
            providerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            providerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            settingsButton.topAnchor.constraint(equalTo: providerLabel.bottomAnchor, constant: 40),
            settingsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            settingsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            settingsButton.heightAnchor.constraint(equalToConstant: 44),
            
            notificationButton.topAnchor.constraint(equalTo: settingsButton.bottomAnchor, constant: 16),
            notificationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            notificationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            notificationButton.heightAnchor.constraint(equalToConstant: 44),
            
            goalsButton.topAnchor.constraint(equalTo: notificationButton.bottomAnchor, constant: 16),
            goalsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            goalsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            goalsButton.heightAnchor.constraint(equalToConstant: 44),
            
            preferencesButton.topAnchor.constraint(equalTo: goalsButton.bottomAnchor, constant: 16),
            preferencesButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            preferencesButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            preferencesButton.heightAnchor.constraint(equalToConstant: 44),
            
            logoutButton.topAnchor.constraint(equalTo: preferencesButton.bottomAnchor, constant: 40),
            logoutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            logoutButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func loadUserData() {
        guard let user = Auth.auth().currentUser else {
            // If no user is logged in, show login screen
            return
        }
        
        // Set user display name or email
        if let displayName = user.displayName, !displayName.isEmpty {
            nameLabel.text = displayName
        } else {
            nameLabel.text = "NutriScan User"
        }
        
        // Set email
        emailLabel.text = user.email ?? "No email"
        
        // Determine authentication provider
        var providers: [String] = []
        for userInfo in user.providerData {
            if userInfo.providerID == "google.com" {
                providers.append("Google")
            } else if userInfo.providerID == "password" {
                providers.append("Email")
            }
        }
        
        if !providers.isEmpty {
            providerLabel.text = "Signed in with: \(providers.joined(separator: ", "))"
        } else {
            providerLabel.text = ""
        }
        
        // Load profile image if available
        if let profileImageURL = userProfile?.profileImageURL {
            loadProfileImage(from: profileImageURL)
        }
    }
    
    private func startProfileListener() {
        profileListener = FirestoreManager.shared.observeUserProfile { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    self?.userProfile = profile
                    self?.updateProfileDisplay()
                case .failure(let error):
                    print("Error observing user profile: \(error)")
                }
            }
        }
    }
    
    private func updateProfileDisplay() {
        guard let profile = userProfile else { return }
        
        // Update display name if available
        if let displayName = profile.displayName, !displayName.isEmpty {
            nameLabel.text = displayName
        }
        
        // Load profile image if available
        if let profileImageURL = profile.profileImageURL, !profileImageURL.isEmpty {
            loadProfileImage(from: profileImageURL)
        } else {
            // Reset to default image if no profile image
            profileImageView.image = UIImage(systemName: "person.circle.fill")
            profileImageView.tintColor = .systemGray4
        }
    }
    
    private func loadProfileImage(from imageData: String) {
        // Check if it's a base64 string or URL
        if imageData.hasPrefix("data:") || imageData.hasPrefix("http") {
            // It's a URL, load from URL
            guard let url = URL(string: imageData) else { return }
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let data = data, let image = UIImage(data: data) else { return }
                DispatchQueue.main.async {
                    self?.profileImageView.image = image
                    self?.profileImageView.tintColor = .clear // Remove tint when showing real image
                }
            }.resume()
        } else {
            // It's base64 data
            guard let data = Data(base64Encoded: imageData),
                  let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                self.profileImageView.image = image
                self.profileImageView.tintColor = .clear // Remove tint when showing real image
            }
        }
    }
    
    @objc private func settingsButtonTapped() {
        // Test Firestore connection first
        testFirestoreConnection()
        
        // Then proceed with settings
        let settingsVC = ProfileSettingsViewController()
        settingsVC.modalPresentationStyle = .fullScreen
        present(settingsVC, animated: true)
    }
    
    private func testFirestoreConnection() {
        FirestoreManager.shared.testFirestoreConnection { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let message):
                    print("✅ Test Result: \(message)")
                    // You can show an alert here if you want
                case .failure(let error):
                    print("❌ Test Failed: \(error)")
                    // You can show an alert here if you want
                }
            }
        }
    }
    
    @objc private func settingsButtonTappedOriginal() {
        let settingsVC = ProfileSettingsViewController()
        let navController = UINavigationController(rootViewController: settingsVC)
        present(navController, animated: true)
    }
    
    @objc private func notificationButtonTapped() {
        showNotificationManagement()
    }
    
    // MARK: - Notification Management
    
    private func showNotificationManagement() {
        let alert = UIAlertController(title: "🔔 Meal Reminders", message: "Manage your daily meal notifications", preferredStyle: .actionSheet)
        
        // Toggle notifications
        let toggleTitle = NotificationManager.shared.areNotificationsEnabled ? "Turn Off Notifications" : "Turn On Notifications"
        let toggleAction = UIAlertAction(title: toggleTitle, style: .default) { [weak self] _ in
            self?.toggleNotifications()
        }
        alert.addAction(toggleAction)
        
        // Schedule/Configure times
        let scheduleAction = UIAlertAction(title: "Schedule Reminders", style: .default) { [weak self] _ in
            self?.showMealScheduling()
        }
        alert.addAction(scheduleAction)
        
        // Test notifications
        let testAction = UIAlertAction(title: "Test Notification", style: .default) { [weak self] _ in
            self?.testNotification()
        }
        alert.addAction(testAction)
        
        // Reset to defaults
        let resetAction = UIAlertAction(title: "Reset to Defaults", style: .destructive) { [weak self] _ in
            self?.resetToDefaults()
        }
        alert.addAction(resetAction)
        
        // Open iOS settings
        let settingsAction = UIAlertAction(title: "iOS Settings", style: .default) { [weak self] _ in
            NotificationManager.shared.openNotificationSettings()
        }
        alert.addAction(settingsAction)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // For iPad support
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }
    
    private func toggleNotifications() {
        NotificationManager.shared.toggleNotifications { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    let status = NotificationManager.shared.areNotificationsEnabled ? "enabled" : "disabled"
                    self?.showAlert(title: "Success", message: "Notifications have been \(status)")
                } else {
                    self?.showAlert(title: "Permission Required", message: "Please enable notifications in iOS Settings to receive meal reminders.")
                }
            }
        }
    }
    
    private func showMealScheduling() {
        let alert = UIAlertController(title: "Schedule Meal Reminders", message: "Choose a meal to configure", preferredStyle: .actionSheet)
        
        for type in NotificationManager.NotificationType.allCases {
            let savedTime = NotificationManager.shared.getSavedTime(for: type)
            let timeString = String(format: "%d:%02d", savedTime.hour, savedTime.minute)
            let actionTitle = "\(type.displayName) (\(timeString))"
            
            let action = UIAlertAction(title: actionTitle, style: .default) { [weak self] _ in
                self?.configureMealTime(type)
            }
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // For iPad support
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }
    
    private func configureMealTime(_ type: NotificationManager.NotificationType) {
        let savedTime = NotificationManager.shared.getSavedTime(for: type)
        
        TimePickerViewController.present(
            for: type,
            currentTime: savedTime,
            from: self,
            delegate: self
        )
    }
    
    private func testNotification() {
        NotificationManager.shared.scheduleTestNotification { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    self?.showAlert(title: "Test Sent", message: "Test notification will appear in 2 seconds!")
                } else {
                    self?.showAlert(title: "Error", message: "Failed to send test notification. Please check notification permissions.")
                }
            }
        }
    }
    
    private func resetToDefaults() {
        let alert = UIAlertController(title: "Reset to Defaults", message: "This will reset all notification times to default values and clear all scheduled notifications.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { _ in
            NotificationManager.shared.resetToDefaults()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    // MARK: - TimePickerDelegate
    
    func timePicker(_ picker: TimePickerViewController, didSelectTime hour: Int, minute: Int) {
        // Find the meal type from the picker
        guard let mealType = picker.mealType else {
            print("Error: mealType is nil")
            return
        }
        
        // Update the notification time
        NotificationManager.shared.updateNotificationTime(for: mealType, hour: hour, minute: minute)
        
        // Show success message
        let timeString = String(format: "%d:%02d", hour, minute)
        showAlert(title: "Success", message: "\(mealType.displayName) reminder set for \(timeString)")
    }
    
    func timePickerDidCancel(_ picker: TimePickerViewController) {
        // User cancelled, no action needed
    }
    
    @objc private func goalsButtonTapped() {
        let goalsVC = NutritionGoalsViewController()
        let navController = UINavigationController(rootViewController: goalsVC)
        present(navController, animated: true)
    }
    
    @objc private func preferencesButtonTapped() {
        let preferencesVC = AppPreferencesViewController()
        let navController = UINavigationController(rootViewController: preferencesVC)
        present(navController, animated: true)
    }
    
    @objc private func logoutButtonTapped() {
        let alert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive) { [weak self] _ in
            self?.performLogout()
        })
        
        present(alert, animated: true)
    }
    
    private func performLogout() {
        AuthenticationManager.shared.signOut { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // Navigate to login screen
                    self?.navigateToLogin()
                case .failure(let error):
                    self?.showAlert(title: "Logout Failed", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func navigateToLogin() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate else {
            return
        }
        
        sceneDelegate.showLoginScreen()
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
