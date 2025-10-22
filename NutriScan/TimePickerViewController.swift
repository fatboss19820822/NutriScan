//
//  TimePickerViewController.swift
//  NutriScan
//
//  Created by Raymond on 25/9/2025.
//

import UIKit

protocol TimePickerDelegate: AnyObject {
    func timePicker(_ picker: TimePickerViewController, didSelectTime hour: Int, minute: Int)
    func timePickerDidCancel(_ picker: TimePickerViewController)
}

class TimePickerViewController: UIViewController {
    
    weak var delegate: TimePickerDelegate?
    var mealType: NotificationManager.NotificationType!
    var currentTime: (hour: Int, minute: Int)!
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.preferredDatePickerStyle = .wheels
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemGray5
        button.setTitleColor(.label, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Initialization
    
    static func present(
        for mealType: NotificationManager.NotificationType,
        currentTime: (hour: Int, minute: Int),
        from viewController: UIViewController,
        delegate: TimePickerDelegate
    ) {
        let timePickerVC = TimePickerViewController()
        timePickerVC.mealType = mealType
        timePickerVC.currentTime = currentTime
        timePickerVC.delegate = delegate
        
        timePickerVC.modalPresentationStyle = .overFullScreen
        timePickerVC.modalTransitionStyle = .crossDissolve
        
        viewController.present(timePickerVC, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTimePicker()
        setupActions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateIn()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .clear
        
        // Add background view
        view.addSubview(backgroundView)
        
        // Add container view
        view.addSubview(containerView)
        
        // Add subviews to container
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(timePicker)
        containerView.addSubview(buttonStackView)
        
        // Add buttons to stack view
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(saveButton)
        
        setupConstraints()
        setupContent()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Background view
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Container view
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            containerView.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.7),
            
            // Title label
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            // Subtitle label
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            // Time picker
            timePicker.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
            timePicker.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            timePicker.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            timePicker.heightAnchor.constraint(equalToConstant: 200),
            
            // Button stack view
            buttonStackView.topAnchor.constraint(equalTo: timePicker.bottomAnchor, constant: 24),
            buttonStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            buttonStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24),
            buttonStackView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupContent() {
        titleLabel.text = "\(mealType.displayName) Reminder"
        subtitleLabel.text = "Set the time for your \(mealType.displayName.lowercased()) notification"
    }
    
    private func setupTimePicker() {
        // Set the current time
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.hour = currentTime.hour
        dateComponents.minute = currentTime.minute
        dateComponents.second = 0
        
        if let date = calendar.date(from: dateComponents) {
            timePicker.date = date
        }
    }
    
    private func setupActions() {
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        // Add tap gesture to background to dismiss
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        backgroundView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    
    @objc private func cancelButtonTapped() {
        animateOut {
            self.delegate?.timePickerDidCancel(self)
        }
    }
    
    @objc private func saveButtonTapped() {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: timePicker.date)
        
        guard let hour = components.hour,
              let minute = components.minute else {
            return
        }
        
        animateOut {
            self.delegate?.timePicker(self, didSelectTime: hour, minute: minute)
        }
    }
    
    @objc private func backgroundTapped() {
        cancelButtonTapped()
    }
    
    // MARK: - Animations
    
    private func animateIn() {
        containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        containerView.alpha = 0
        backgroundView.alpha = 0
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut) {
            self.containerView.transform = .identity
            self.containerView.alpha = 1
            self.backgroundView.alpha = 1
        }
    }
    
    private func animateOut(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) {
            self.containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.containerView.alpha = 0
            self.backgroundView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false) {
                completion()
            }
        }
    }
}

// MARK: - Accessibility

extension TimePickerViewController {
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Add accessibility labels
        titleLabel.accessibilityLabel = "\(mealType.displayName) reminder time picker"
        subtitleLabel.accessibilityLabel = "Set the time for your \(mealType.displayName.lowercased()) notification"
        timePicker.accessibilityLabel = "Time picker for \(mealType.displayName) reminder"
        cancelButton.accessibilityLabel = "Cancel time selection"
        saveButton.accessibilityLabel = "Save time selection"
    }
}
