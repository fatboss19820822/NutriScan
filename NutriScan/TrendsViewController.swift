//
//  TrendsViewController.swift
//  NutriScan
//
//  Created by Raymond on 25/9/2025.
//

import UIKit

class TrendsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Trends"
        
        // Create placeholder content
        let titleLabel = UILabel()
        titleLabel.text = "Nutritional Trends"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Track your nutritional trends over time\n\n• Daily calorie intake\n• Macro nutrients\n• Vitamin consumption\n• Progress charts"
        descriptionLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let chartPlaceholder = UIView()
        chartPlaceholder.backgroundColor = .systemGray6
        chartPlaceholder.layer.cornerRadius = 12
        chartPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        
        let chartLabel = UILabel()
        chartLabel.text = "📊 Chart Placeholder"
        chartLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        chartLabel.textAlignment = .center
        chartLabel.translatesAutoresizingMaskIntoConstraints = false
        
        chartPlaceholder.addSubview(chartLabel)
        
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(chartPlaceholder)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            chartPlaceholder.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 30),
            chartPlaceholder.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            chartPlaceholder.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            chartPlaceholder.heightAnchor.constraint(equalToConstant: 200),
            
            chartLabel.centerXAnchor.constraint(equalTo: chartPlaceholder.centerXAnchor),
            chartLabel.centerYAnchor.constraint(equalTo: chartPlaceholder.centerYAnchor)
        ])
    }
}
