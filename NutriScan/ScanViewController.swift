//
//  ScanViewController.swift
//  NutriScan
//
//  Created by Raymond on 25/9/2025.
//

import UIKit
import AVFoundation

class ScanViewController: UIViewController {
    
    // MARK: - Properties
    
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var scanningAreaView: UIView!
    private var instructionLabel: UILabel!
    private var closeButton: UIButton!
    private var torchButton: UIButton!
    
    private var isScanning = false
    private var isTorchOn = false
    private var currentDevice: AVCaptureDevice?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Start camera session when view appears
        if captureSession != nil && !captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession.startRunning()
            }
            isScanning = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Turn off torch if it's on
        if isTorchOn {
            toggleTorch()
        }
        
        // Stop camera session when view disappears
        if captureSession != nil && captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession.stopRunning()
            }
            isScanning = false
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.layer.bounds
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        view.backgroundColor = .black
        title = "Scan Barcode"
        
        // Check camera permission and setup
        checkCameraPermission()
    }
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // Permission granted, setup camera
            setupCamera()
            
        case .notDetermined:
            // Request permission
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.setupCamera()
                    } else {
                        self?.showPermissionDeniedAlert()
                    }
                }
            }
            
        case .denied, .restricted:
            // Permission denied
            showPermissionDeniedAlert()
            
        @unknown default:
            showPermissionDeniedAlert()
        }
    }
    
    private func setupCamera() {
        // Initialize capture session
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            showCameraError()
            return
        }
        
        // Store the device for torch control
        currentDevice = videoCaptureDevice
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            showCameraError()
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            showCameraError()
            return
        }
        
        // Setup metadata output for barcode detection
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            // Support multiple barcode types
            metadataOutput.metadataObjectTypes = [
                .ean8,
                .ean13,
                .pdf417,
                .qr,
                .code128,
                .code39,
                .code93,
                .upce
            ]
        } else {
            showCameraError()
            return
        }
        
        // Setup preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        // Setup UI overlay
        setupOverlay()
        
        // Start the session
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
            DispatchQueue.main.async {
                self?.isScanning = true
            }
        }
    }
    
    private func setupOverlay() {
        // Semi-transparent overlay
        let overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        overlayView.isUserInteractionEnabled = false
        view.addSubview(overlayView)
        
        // Scanning area (transparent rectangle)
        scanningAreaView = UIView()
        scanningAreaView.layer.borderColor = UIColor.systemGreen.cgColor
        scanningAreaView.layer.borderWidth = 3
        scanningAreaView.layer.cornerRadius = 12
        scanningAreaView.backgroundColor = .clear
        scanningAreaView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scanningAreaView)
        
        // Create a mask to make scanning area transparent
        let maskLayer = CAShapeLayer()
        let path = UIBezierPath(rect: overlayView.bounds)
        
        // Calculate scanning area frame
        let scanWidth: CGFloat = view.bounds.width * 0.7
        let scanHeight: CGFloat = 200
        let scanX = (view.bounds.width - scanWidth) / 2
        let scanY = (view.bounds.height - scanHeight) / 2
        let scanRect = CGRect(x: scanX, y: scanY, width: scanWidth, height: scanHeight)
        
        let scanPath = UIBezierPath(roundedRect: scanRect, cornerRadius: 12)
        path.append(scanPath)
        path.usesEvenOddFillRule = true
        
        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd
        overlayView.layer.mask = maskLayer
        
        // Instruction label
        instructionLabel = UILabel()
        instructionLabel.text = "Position barcode within the frame"
        instructionLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        instructionLabel.textColor = .white
        instructionLabel.textAlignment = .center
        instructionLabel.numberOfLines = 0
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(instructionLabel)
        
        // Close button (hidden since we navigate via tab bar)
        closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = .white
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        closeButton.isHidden = true  // Hidden since ScanViewController is accessed via tab bar
        view.addSubview(closeButton)
        
        // Torch button
        torchButton = UIButton(type: .system)
        torchButton.setImage(UIImage(systemName: "flashlight.off.fill"), for: .normal)
        torchButton.tintColor = .white
        torchButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        torchButton.layer.cornerRadius = 25
        torchButton.translatesAutoresizingMaskIntoConstraints = false
        torchButton.addTarget(self, action: #selector(torchButtonTapped), for: .touchUpInside)
        view.addSubview(torchButton)
        
        // Hide torch button if device doesn't support it
        if let device = currentDevice, !device.hasTorch {
            torchButton.isHidden = true
        }
        
        // Layout constraints
        NSLayoutConstraint.activate([
            scanningAreaView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scanningAreaView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            scanningAreaView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            scanningAreaView.heightAnchor.constraint(equalToConstant: 200),
            
            instructionLabel.bottomAnchor.constraint(equalTo: scanningAreaView.topAnchor, constant: -30),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            
            torchButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            torchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            torchButton.widthAnchor.constraint(equalToConstant: 50),
            torchButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Add scanning animation
        addScanningAnimation()
    }
    
    private func addScanningAnimation() {
        // Animated scanning line
        let scanLine = UIView()
        scanLine.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.7)
        scanLine.translatesAutoresizingMaskIntoConstraints = false
        scanningAreaView.addSubview(scanLine)
        
        NSLayoutConstraint.activate([
            scanLine.leadingAnchor.constraint(equalTo: scanningAreaView.leadingAnchor),
            scanLine.trailingAnchor.constraint(equalTo: scanningAreaView.trailingAnchor),
            scanLine.heightAnchor.constraint(equalToConstant: 2),
            scanLine.topAnchor.constraint(equalTo: scanningAreaView.topAnchor)
        ])
        
        scanningAreaView.layoutIfNeeded()
        
        // Animate the scan line
        UIView.animate(withDuration: 2.0, delay: 0, options: [.repeat, .autoreverse], animations: {
            scanLine.frame.origin.y = self.scanningAreaView.bounds.height - 2
        })
    }
    
    // MARK: - Actions
    
    @objc private func closeButtonTapped() {
        // Optional: implement if you want a way to dismiss the scanner
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func torchButtonTapped() {
        toggleTorch()
    }
    
    private func toggleTorch() {
        guard let device = currentDevice, device.hasTorch else {
            return
        }
        
        do {
            try device.lockForConfiguration()
            
            if isTorchOn {
                // Turn off torch
                device.torchMode = .off
                isTorchOn = false
                torchButton.setImage(UIImage(systemName: "flashlight.off.fill"), for: .normal)
                torchButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            } else {
                // Turn on torch
                if device.isTorchModeSupported(.on) {
                    device.torchMode = .on
                    isTorchOn = true
                    torchButton.setImage(UIImage(systemName: "flashlight.on.fill"), for: .normal)
                    torchButton.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.7)
                }
            }
            
            device.unlockForConfiguration()
            
            // Haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            
        } catch {
            print("Error toggling torch: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Helper Methods
    
    private func showPermissionDeniedAlert() {
        let alert = UIAlertController(
            title: "Camera Access Required",
            message: "Please enable camera access in Settings to scan barcodes.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        
        present(alert, animated: true)
    }
    
    private func showCameraError() {
        let alert = UIAlertController(
            title: "Camera Error",
            message: "Unable to access the camera. Please try again.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func barcodeDetected(_ barcode: String, type: AVMetadataObject.ObjectType) {
        // Prevent multiple scans
        guard isScanning else { return }
        isScanning = false
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // Visual feedback
        scanningAreaView.layer.borderColor = UIColor.systemGreen.cgColor
        UIView.animate(withDuration: 0.3, animations: {
            self.scanningAreaView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                self.scanningAreaView.transform = .identity
            }
        }
        
        // Update instruction label
        instructionLabel.text = "Barcode detected!"
        instructionLabel.textColor = .systemGreen
        
        // Show barcode information
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.showBarcodeResult(barcode: barcode, type: type)
        }
    }
    
    private func showBarcodeResult(barcode: String, type: AVMetadataObject.ObjectType) {
        let typeString = barcodeTypeToString(type)
        
        let alert = UIAlertController(
            title: "Barcode Detected",
            message: "Type: \(typeString)\nCode: \(barcode)",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Scan Again", style: .default) { [weak self] _ in
            self?.resetScanner()
        })
        
        alert.addAction(UIAlertAction(title: "Lookup Product", style: .default) { [weak self] _ in
            // TODO: Implement product lookup functionality
            self?.lookupProduct(barcode: barcode)
        })
        
        present(alert, animated: true)
    }
    
    private func barcodeTypeToString(_ type: AVMetadataObject.ObjectType) -> String {
        switch type {
        case .ean8: return "EAN-8"
        case .ean13: return "EAN-13"
        case .upce: return "UPC-E"
        case .code39: return "Code 39"
        case .code93: return "Code 93"
        case .code128: return "Code 128"
        case .qr: return "QR Code"
        case .pdf417: return "PDF417"
        default: return "Unknown"
        }
    }
    
    private func resetScanner() {
        isScanning = true
        instructionLabel.text = "Position barcode within the frame"
        instructionLabel.textColor = .white
        scanningAreaView.layer.borderColor = UIColor.systemGreen.cgColor
    }
    
    private func lookupProduct(barcode: String) {
        // TODO: Implement API call to food database (e.g., Open Food Facts)
        // This will be implemented in the next step
        let alert = UIAlertController(
            title: "Product Lookup",
            message: "Product lookup functionality will be implemented to fetch nutritional information for barcode: \(barcode)",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.resetScanner()
        })
        
        present(alert, animated: true)
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate

extension ScanViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        // Check if we found any metadata objects
        guard let metadataObject = metadataObjects.first,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let stringValue = readableObject.stringValue else {
            return
        }
        
        // We found a barcode!
        barcodeDetected(stringValue, type: readableObject.type)
    }
}
