//
//  ScanViewController.swift
//  NutriScan
//
//  Created by Raymond on 25/9/2025.
//

import UIKit

class ScanViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Scan"
        
        // Create scan button
        let scanButton = UIButton(type: .system)
        scanButton.setTitle("Scan Food Item", for: .normal)
        scanButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        scanButton.backgroundColor = .systemBlue
        scanButton.setTitleColor(.white, for: .normal)
        scanButton.layer.cornerRadius = 25
        scanButton.translatesAutoresizingMaskIntoConstraints = false
        
        scanButton.addTarget(self, action: #selector(scanButtonTapped), for: .touchUpInside)
        
        let instructionLabel = UILabel()
        instructionLabel.text = "Tap the button to scan a food item and get nutritional information"
        instructionLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        instructionLabel.textAlignment = .center
        instructionLabel.textColor = .secondaryLabel
        instructionLabel.numberOfLines = 0
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scanButton)
        view.addSubview(instructionLabel)
        
        NSLayoutConstraint.activate([
            scanButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scanButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            scanButton.widthAnchor.constraint(equalToConstant: 200),
            scanButton.heightAnchor.constraint(equalToConstant: 50),
            
            instructionLabel.topAnchor.constraint(equalTo: scanButton.bottomAnchor, constant: 20),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    @objc private func scanButtonTapped() {
        // TODO: Implement camera scanning functionality
        let alert = UIAlertController(title: "Scan Feature", message: "Camera scanning functionality will be implemented here.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
