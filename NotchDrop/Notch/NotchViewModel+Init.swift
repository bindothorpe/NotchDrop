//
//  NotchViewModel+Init.swift
//  NotchDrop
//
//  Created by Bindo Thorpe on 22/03/2025.
//

import Foundation

extension NotchViewModel {
    // This extends the initialization process
    func completeInitialization() {
        // Load saved tabs or set up defaults
        initializeWithSavedTabs()
        
        // Update size configurations for the tabs
        setupSizeConfigurations()
    }
}
