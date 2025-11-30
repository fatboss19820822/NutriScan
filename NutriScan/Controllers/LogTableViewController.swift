//
//  LogTableViewController.swift
//  NutriScan
//
//  Created by Raymond on 25/9/2025.
//

import UIKit
import SwiftUI

class LogTableViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSwiftUIView()
    }
    
    private func setupSwiftUIView() {
        // Create SwiftUI view with Firestore (cloud storage)
        let logView = FirestoreLogView()
        
        // Create hosting controller
        let hostingController = UIHostingController(rootView: logView)
        
        // Add as child view controller
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        // Setup constraints
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        hostingController.didMove(toParent: self)
    }
}

// MARK: - Legacy Core Data Version
// Uncomment to switch back to Core Data (local storage)
/*
extension LogTableViewController {
    private func setupCoreDataView() {
        let logView = LogView()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
        
        let hostingController = UIHostingController(rootView: logView)
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        hostingController.didMove(toParent: self)
    }
}
*/
