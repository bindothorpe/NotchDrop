//
//  NotchViewModel+Setup.swift
//  NotchDrop
//
//  Created by Bindo Thorpe on 11/03/2025.
//

import SwiftUI

extension NotchViewModel {
    // Instead of redefining setupCancellables(), create a new method
    func setupSizeConfigurations() {
        // Setup default tab configurations
        setupDefaultTabConfigurations()
    }
    
    func setupDefaultTabConfigurations() {
        // Normal tab
        sizeManager.registerTab(type: .normal, rowCount: 1, colCount: 4)
        
        // Menu tab (based on your current layout)
        sizeManager.registerTab(type: .menu, rowCount: 1, colCount: 5)
        
        // Settings tab
        sizeManager.registerTab(type: .settings, rowCount: 3, colCount: 1)
    }
}
