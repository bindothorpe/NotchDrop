//
//  NotchViewModel+Persistence.swift
//  NotchDrop
//
//  Created by Claude on 22/03/2025.
//

import Foundation
import Combine

extension NotchViewModel {
    // Initialize the model with saved tabs or defaults
    func initializeWithSavedTabs() {
        // Load tabs from storage
        if let savedTabs = TabPersistenceManager.shared.loadTabs(), !savedTabs.isEmpty {
            self.tabs = savedTabs
            print("Loaded \(savedTabs.count) saved tabs")
        } else {
            print("No saved tabs found, using defaults")
            setupDefaultTabs()
        }
        
        // Set up observer to automatically save tabs when they change
        setupPersistenceObserver()
    }
    
    // Set up observer to automatically save tabs when they change
    private func setupPersistenceObserver() {
        // Use a debounced publisher to avoid saving too frequently
        $tabs
            .dropFirst() // Skip initial value
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink { [weak self] tabs in
                guard let self = self else { return }
                TabPersistenceManager.shared.saveTabs(tabs)
            }
            .store(in: &cancellables)
    }
    
    // Method to manually save tabs
    func persistTabs() {
        TabPersistenceManager.shared.saveTabs(tabs)
    }
    
    // Reset to default tabs
    func resetToDefaultTabs() {
        TabPersistenceManager.shared.deleteSavedTabs()
        tabs.removeAll()
        setupDefaultTabs()
    }
}
