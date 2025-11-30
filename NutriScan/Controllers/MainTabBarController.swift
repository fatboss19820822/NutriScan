//
//  MainTabBarController.swift
//  NutriScan
//
//  Created by Raymond on 25/9/2025.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupViewControllers()
    }
    
    private func setupTabBar() {
        tabBar.tintColor = .systemBlue
        tabBar.unselectedItemTintColor = .systemGray
        tabBar.backgroundColor = .systemBackground
        
        // Add shadow
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOpacity = 0.1
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -2)
        tabBar.layer.shadowRadius = 4
    }
    
    private func setupViewControllers() {
        // Home Tab
        let homeVC = HomeViewController()
        let homeNav = UINavigationController(rootViewController: homeVC)
        homeNav.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house.fill"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        
        // Scan Tab
        let scanVC = ScanViewController()
        let scanNav = UINavigationController(rootViewController: scanVC)
        scanNav.tabBarItem = UITabBarItem(
            title: "Scan",
            image: UIImage(systemName: "camera.fill"),
            selectedImage: UIImage(systemName: "camera.fill")
        )
        
        // Log Tab
        let logVC = LogTableViewController()
        let logNav = UINavigationController(rootViewController: logVC)
        logNav.tabBarItem = UITabBarItem(
            title: "Log",
            image: UIImage(systemName: "list.bullet.rectangle.fill"),
            selectedImage: UIImage(systemName: "list.bullet.rectangle.fill")
        )
        
        // Trends Tab
        let trendsVC = TrendsViewController()
        let trendsNav = UINavigationController(rootViewController: trendsVC)
        trendsNav.tabBarItem = UITabBarItem(
            title: "Trends",
            image: UIImage(systemName: "chart.line.uptrend.xyaxis"),
            selectedImage: UIImage(systemName: "chart.line.uptrend.xyaxis")
        )
        
        // Profile Tab
        let profileVC = ProfileViewController()
        let profileNav = UINavigationController(rootViewController: profileVC)
        profileNav.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person.fill"),
            selectedImage: UIImage(systemName: "person.fill")
        )
        
        // Set view controllers
        viewControllers = [homeNav, scanNav, logNav, trendsNav, profileNav]
        
        // Set default selected tab
        selectedIndex = 0
    }
}
