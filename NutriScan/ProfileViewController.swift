//
//  ProfileViewController.swift
//  NutriScan
//
//  Created by Raymond on 25/9/2025.
//

import UIKit

class ProfileViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Profile"
        
        // Create profile image placeholder
        let profileImageView = UIImageView()
        profileImageView.backgroundColor = .systemGray4
        profileImageView.layer.cornerRadius = 50
        profileImageView.clipsToBounds = true
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let nameLabel = UILabel()
        nameLabel.text = "User Name"
        nameLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        nameLabel.textAlignment = .center
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let emailLabel = UILabel()
        emailLabel.text = "user@example.com"
        emailLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        emailLabel.textAlignment = .center
        emailLabel.textColor = .secondaryLabel
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Create settings button
        let settingsButton = UIButton(type: .system)
        settingsButton.setTitle("Settings", for: .normal)
        settingsButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        settingsButton.backgroundColor = .systemGray6
        settingsButton.layer.cornerRadius = 8
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        
        // Create goals button
        let goalsButton = UIButton(type: .system)
        goalsButton.setTitle("Nutritional Goals", for: .normal)
        goalsButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        goalsButton.backgroundColor = .systemGray6
        goalsButton.layer.cornerRadius = 8
        goalsButton.translatesAutoresizingMaskIntoConstraints = false
        goalsButton.addTarget(self, action: #selector(goalsButtonTapped), for: .touchUpInside)
        
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(emailLabel)
        view.addSubview(settingsButton)
        view.addSubview(goalsButton)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            settingsButton.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 40),
            settingsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            settingsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            settingsButton.heightAnchor.constraint(equalToConstant: 44),
            
            goalsButton.topAnchor.constraint(equalTo: settingsButton.bottomAnchor, constant: 16),
            goalsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            goalsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            goalsButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func settingsButtonTapped() {
        let alert = UIAlertController(title: "Settings", message: "Settings functionality will be implemented here.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func goalsButtonTapped() {
        let alert = UIAlertController(title: "Nutritional Goals", message: "Goals management functionality will be implemented here.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
