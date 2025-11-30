//
//  NotificationManager.swift
//  NutriScan
//
//  Created by Raymond on 25/9/2025.
//

import UIKit
import UserNotifications

class NotificationManager: NSObject {
    static let shared = NotificationManager()
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    // Notification identifiers
    enum NotificationType: String, CaseIterable {
        case breakfast = "breakfast_reminder"
        case lunch = "lunch_reminder"
        case dinner = "dinner_reminder"
        
        var title: String {
            switch self {
            case .breakfast: return "Breakfast Time! 🥞"
            case .lunch: return "Lunch Time! 🥗"
            case .dinner: return "Dinner Time! 🍽️"
            }
        }
        
        var body: String {
            switch self {
            case .breakfast: return "Start your day right with a nutritious breakfast. Don't forget to log it!"
            case .lunch: return "Time for lunch! Remember to scan and log your meal."
            case .dinner: return "Dinner time! Track your evening meal for complete nutrition monitoring."
            }
        }
        
        var defaultHour: Int {
            switch self {
            case .breakfast: return 8  // 8:00 AM
            case .lunch: return 12     // 12:00 PM
            case .dinner: return 18    // 6:00 PM
            }
        }
        
        var displayName: String {
            switch self {
            case .breakfast: return "Breakfast"
            case .lunch: return "Lunch"
            case .dinner: return "Dinner"
            }
        }
    }
    
    // UserDefaults keys
    private enum UserDefaultsKeys {
        static let notificationsEnabled = "notifications_enabled"
        static let breakfastHour = "breakfast_hour"
        static let breakfastMinute = "breakfast_minute"
        static let lunchHour = "lunch_hour"
        static let lunchMinute = "lunch_minute"
        static let dinnerHour = "dinner_hour"
        static let dinnerMinute = "dinner_minute"
    }
    
    override init() {
        super.init()
        notificationCenter.delegate = self
    }
    
    // MARK: - Permission Management
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Notification permission error: \(error)")
                    completion(false)
                } else {
                    print("Notification permission granted: \(granted)")
                    completion(granted)
                }
            }
        }
    }
    
    func checkPermissionStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        notificationCenter.getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }
    
    // MARK: - Notification State Management
    
    var areNotificationsEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: UserDefaultsKeys.notificationsEnabled)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.notificationsEnabled)
            if newValue {
                setupAllNotifications()
            } else {
                clearAllNotifications()
            }
        }
    }
    
    func toggleNotifications(completion: @escaping (Bool) -> Void) {
        checkPermissionStatus { [weak self] status in
            switch status {
            case .authorized:
                self?.areNotificationsEnabled.toggle()
                completion(self?.areNotificationsEnabled ?? false)
            case .denied:
                completion(false)
            case .notDetermined:
                self?.requestPermission { granted in
                    if granted {
                        self?.areNotificationsEnabled = true
                    }
                    completion(granted)
                }
            case .provisional:
                self?.areNotificationsEnabled.toggle()
                completion(self?.areNotificationsEnabled ?? false)
            @unknown default:
                completion(false)
            }
        }
    }
    
    // MARK: - Notification Scheduling
    
    func setupAllNotifications() {
        guard areNotificationsEnabled else { return }
        
        // Clear existing notifications
        clearAllNotifications()
        
        // Schedule all meal reminders
        for type in NotificationType.allCases {
            scheduleNotification(for: type)
        }
    }
    
    func setupDefaultNotifications() {
        areNotificationsEnabled = true
        setupAllNotifications()
    }
    
    func scheduleNotification(for type: NotificationType, at hour: Int? = nil, minute: Int? = nil) {
        let targetHour = hour ?? getSavedHour(for: type) ?? type.defaultHour
        let targetMinute = minute ?? getSavedMinute(for: type) ?? 0
        
        // Save the time
        saveTime(for: type, hour: targetHour, minute: targetMinute)
        
        let content = UNMutableNotificationContent()
        content.title = type.title
        content.body = type.body
        content.sound = .default
        content.badge = 1
        content.userInfo = [
            "type": type.rawValue,
            "meal": type.rawValue
        ]
        
        // Create date components for the notification
        var dateComponents = DateComponents()
        dateComponents.hour = targetHour
        dateComponents.minute = targetMinute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: type.rawValue, content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling \(type.rawValue) notification: \(error)")
            } else {
                print("Successfully scheduled \(type.rawValue) notification for \(targetHour):\(String(format: "%02d", targetMinute))")
            }
        }
    }
    
    func updateNotificationTime(for type: NotificationType, hour: Int, minute: Int) {
        // Remove existing notification
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [type.rawValue])
        
        // Schedule new notification with updated time
        scheduleNotification(for: type, at: hour, minute: minute)
    }
    
    // MARK: - Notification Management
    
    func clearAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
    }
    
    func clearNotification(for type: NotificationType) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [type.rawValue])
    }
    
    func getPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        notificationCenter.getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                completion(requests)
            }
        }
    }
    
    // MARK: - Time Management
    
    private func saveTime(for type: NotificationType, hour: Int, minute: Int) {
        let hourKey: String
        let minuteKey: String
        
        switch type {
        case .breakfast:
            hourKey = UserDefaultsKeys.breakfastHour
            minuteKey = UserDefaultsKeys.breakfastMinute
        case .lunch:
            hourKey = UserDefaultsKeys.lunchHour
            minuteKey = UserDefaultsKeys.lunchMinute
        case .dinner:
            hourKey = UserDefaultsKeys.dinnerHour
            minuteKey = UserDefaultsKeys.dinnerMinute
        }
        
        UserDefaults.standard.set(hour, forKey: hourKey)
        UserDefaults.standard.set(minute, forKey: minuteKey)
    }
    
    private func getSavedHour(for type: NotificationType) -> Int? {
        let key: String
        switch type {
        case .breakfast: key = UserDefaultsKeys.breakfastHour
        case .lunch: key = UserDefaultsKeys.lunchHour
        case .dinner: key = UserDefaultsKeys.dinnerHour
        }
        
        let hour = UserDefaults.standard.integer(forKey: key)
        return hour > 0 ? hour : nil
    }
    
    private func getSavedMinute(for type: NotificationType) -> Int? {
        let key: String
        switch type {
        case .breakfast: key = UserDefaultsKeys.breakfastMinute
        case .lunch: key = UserDefaultsKeys.lunchMinute
        case .dinner: key = UserDefaultsKeys.dinnerMinute
        }
        
        let minute = UserDefaults.standard.integer(forKey: key)
        return minute >= 0 ? minute : nil
    }
    
    func getSavedTime(for type: NotificationType) -> (hour: Int, minute: Int) {
        let hour = getSavedHour(for: type) ?? type.defaultHour
        let minute = getSavedMinute(for: type) ?? 0
        return (hour: hour, minute: minute)
    }
    
    // MARK: - Reset Functions
    
    func resetAllSettings() {
        // Clear UserDefaults
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.notificationsEnabled)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.breakfastHour)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.breakfastMinute)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.lunchHour)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.lunchMinute)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.dinnerHour)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.dinnerMinute)
        
        // Clear all notifications
        clearAllNotifications()
        
        // Reset to default state
        areNotificationsEnabled = false
    }
    
    func resetToDefaults() {
        // Clear all notifications
        clearAllNotifications()
        
        // Reset to default times
        for type in NotificationType.allCases {
            saveTime(for: type, hour: type.defaultHour, minute: 0)
        }
        
        // Re-enable and reschedule
        areNotificationsEnabled = true
        setupAllNotifications()
    }
    
    // MARK: - Notification Settings
    
    func openNotificationSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    // MARK: - Test Notifications
    
    func scheduleTestNotification(completion: @escaping (Bool) -> Void) {
        let content = UNMutableNotificationContent()
        content.title = "Test Notification 🔔"
        content.body = "This is a test notification from NutriScan!"
        content.sound = .default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(identifier: "test_notification", content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            DispatchQueue.main.async {
                completion(error == nil)
            }
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    
    // Handle notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.alert, .sound, .badge])
    }
    
    // Handle notification tap
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        // Handle different notification types
        if let typeString = userInfo["type"] as? String,
           let type = NotificationType(rawValue: typeString) {
            
            DispatchQueue.main.async {
                self.handleNotificationTap(for: type)
            }
        }
        
        completionHandler()
    }
    
    private func handleNotificationTap(for type: NotificationType) {
        // Clear the notification badge
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        // Navigate to appropriate screen based on notification type
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let tabBarController = window.rootViewController as? UITabBarController else {
            return
        }
        
        // Navigate to scan tab (index 0 based on typical tab bar setup)
        tabBarController.selectedIndex = 0
        
        // Present a meal-specific alert
        if let navController = tabBarController.selectedViewController as? UINavigationController,
           let topViewController = navController.topViewController {
            
            let alert = UIAlertController(
                title: type.title,
                message: "Ready to log your \(type.rawValue)?",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Scan Food", style: .default) { _ in
                // The scan functionality should be available from the current view
                // This could trigger a barcode scanner or camera view
            })
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            topViewController.present(alert, animated: true)
        }
    }
}
