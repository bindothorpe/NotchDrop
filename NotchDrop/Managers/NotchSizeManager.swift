//
//  NotchSizeManager.swift
//  NotchDrop
//
//  Created by Bindo Thorpe on 11/03/2025.
//

import SwiftUI
import Combine

// Protocol for widgets to specify their size requirements
protocol NotchSizeProvider {
    func getColSpan() -> CGFloat
    func getRowSpan() -> CGFloat
}

// Extension to provide default values
extension NotchSizeProvider {
    func getColSpan() -> CGFloat { 1.0 }
    func getRowSpan() -> CGFloat { 1.0 }
}

class NotchSizeManager: ObservableObject {
    // Reference to the view model
    private weak var viewModel: NotchViewModel?
    
    // Store cancellables
    private var cancellables = Set<AnyCancellable>()
    
    // Storage for tab configurations
    private var tabConfigurations: [NotchViewModel.ContentType: TabConfiguration] = [:]
    
    // Represents the grid layout for a tab
    struct TabConfiguration {
        var rowCount: Int = 1
        var colCount: Int = 1
        var widgets: [NotchSizeProvider] = []
        
        // Calculate the required dimensions based on widgets
        func calculateDimensions(cellSize: CGFloat, spacing: CGFloat) -> CGSize {
            if widgets.isEmpty {
                return CGSize(width: cellSize * CGFloat(colCount) + spacing * CGFloat(max(0, colCount - 1)),
                             height: cellSize * CGFloat(rowCount) + spacing * CGFloat(max(0, rowCount - 1)))
            }
            
            // Find the maximum column span needed
            var maxColSpan: CGFloat = 0
            var maxRowSpan: CGFloat = 0
            
            // Track actual layout to better estimate size
            var currentRowSpan: CGFloat = 0
            var maxRowsNeeded: CGFloat = 0
            var maxColsInRow: CGFloat = 0
            
            for widget in widgets {
                let colSpan = widget.getColSpan()
                let rowSpan = widget.getRowSpan()
                
                maxColSpan = max(maxColSpan, colSpan)
                maxRowSpan = max(maxRowSpan, rowSpan)
                
                // Track maximum columns needed in a single row
                maxColsInRow = max(maxColsInRow, colSpan)
                currentRowSpan = max(currentRowSpan, rowSpan)
            }
            
            maxRowsNeeded = max(1, currentRowSpan)
            
            // Ensure minimum dimensions
            let minCols = max(CGFloat(colCount), maxColsInRow)
            let minRows = max(CGFloat(rowCount), maxRowsNeeded)
            
            // Calculate dimensions based on layout
            let width = cellSize * minCols + spacing * CGFloat(max(0, Int(minCols) - 1))
            let height = cellSize * minRows + spacing * CGFloat(max(0, Int(minRows) - 1))
            
            return CGSize(width: width, height: height)
        }
    }
    
    init(viewModel: NotchViewModel) {
        self.viewModel = viewModel
        setupObservers()
    }
    
    private func setupObservers() {
        guard let viewModel = viewModel else { return }
        
        // Update size when content type changes
        viewModel.$contentType
            .sink { [weak self] contentType in
                self?.updateNotchSize(for: contentType)
            }
            .store(in: &cancellables)
        
        // Update size when spacing or cell size changes
        Publishers.CombineLatest(viewModel.$spacing, viewModel.$cellSize)
            .sink { [weak self] _, _ in
                guard let self = self, let viewModel = self.viewModel else { return }
                self.updateNotchSize(for: viewModel.contentType)
            }
            .store(in: &cancellables)
    }
    
    // Register a tab configuration
    func registerTab(type: NotchViewModel.ContentType, rowCount: Int, colCount: Int) {
        var config = tabConfigurations[type] ?? TabConfiguration()
        config.rowCount = rowCount
        config.colCount = colCount
        tabConfigurations[type] = config
    }
    
    // Register a widget for a specific tab
    func registerWidget(_ widget: NotchSizeProvider, for type: NotchViewModel.ContentType) {
        var config = tabConfigurations[type] ?? TabConfiguration()
        config.widgets.append(widget)
        tabConfigurations[type] = config
    }
    
    // Update the notch size based on the current content type
    func updateNotchSize(for contentType: NotchViewModel.ContentType) {
        guard let viewModel = viewModel,
              let config = tabConfigurations[contentType] else { return }
        
        // Get base size for device notch height
        let baseHeight = viewModel.deviceNotchRect.height
        
        // Calculate content size based on widget layout
        let contentSize = config.calculateDimensions(
            cellSize: viewModel.cellSize,
            spacing: viewModel.spacing
        )
        
        // Add padding and header height
        let totalWidth = contentSize.width + viewModel.spacing * 2
        let totalHeight = contentSize.height + baseHeight + viewModel.spacing * 2
        
        // Update the view model's notch size
        viewModel.updateNotchSize(CGSize(width: totalWidth, height: totalHeight))
    }
}
