//
//  TabModel.swift
//  NotchDrop
//
//  Created by Claude on 22/03/2025.
//

import SwiftUI
import Combine

class TabModel: Identifiable, ObservableObject, Codable {
    let id: UUID
    @Published var title: String
    @Published var icon: String // System icon name
    @Published var widgets: [WidgetModel] = []
    @Published var rowCount: Int = 1
    @Published var colCount: Int = 1
    
    // For tab sorting and management
    @Published var sortOrder: Int = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    enum CodingKeys: String, CodingKey {
        case id, title, icon, widgets, rowCount, colCount, sortOrder
    }
    
    init(id: UUID = UUID(), title: String, icon: String, sortOrder: Int = 0) {
        self.id = id
        self.title = title
        self.icon = icon
        self.sortOrder = sortOrder
        
        // Set up observers to automatically compute row/column counts when widgets change
        $widgets
            .sink { [weak self] widgets in
                self?.updateDimensions(from: widgets)
            }
            .store(in: &cancellables)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        icon = try container.decode(String.self, forKey: .icon)
        widgets = try container.decode([WidgetModel].self, forKey: .widgets)
        rowCount = try container.decode(Int.self, forKey: .rowCount)
        colCount = try container.decode(Int.self, forKey: .colCount)
        sortOrder = try container.decode(Int.self, forKey: .sortOrder)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(icon, forKey: .icon)
        try container.encode(widgets, forKey: .widgets)
        try container.encode(rowCount, forKey: .rowCount)
        try container.encode(colCount, forKey: .colCount)
        try container.encode(sortOrder, forKey: .sortOrder)
    }
    
    private func updateDimensions(from widgets: [WidgetModel]) {
        var maxRow = 0
        var maxCol = 0
        
        for widget in widgets {
            let widgetMaxRow = Int(widget.yPosition + widget.rowSpan)
            let widgetMaxCol = Int(widget.xPosition + widget.colSpan)
            
            maxRow = max(maxRow, widgetMaxRow)
            maxCol = max(maxCol, widgetMaxCol)
        }
        
        // Ensure at least 1x1 grid even if empty
        rowCount = max(1, maxRow)
        colCount = max(1, maxCol)
    }
    
    // Calculate tab dimensions based on contained widgets
    func calculateDimensions(cellSize: CGFloat, spacing: CGFloat) -> CGSize {
        // Find the maximum extent in both dimensions
        var maxX: CGFloat = 0
        var maxY: CGFloat = 0
        
        for widget in widgets {
            let widgetEndX = (widget.xPosition + widget.colSpan) * cellSize +
                            (widget.xPosition + widget.colSpan - 1) * spacing
            let widgetEndY = (widget.yPosition + widget.rowSpan) * cellSize +
                            (widget.yPosition + widget.rowSpan - 1) * spacing
            
            maxX = max(maxX, widgetEndX)
            maxY = max(maxY, widgetEndY)
        }
        
        // If no widgets, set minimum size
        if widgets.isEmpty {
            maxX = cellSize * CGFloat(colCount) + spacing * CGFloat(max(0, colCount - 1))
            maxY = cellSize * CGFloat(rowCount) + spacing * CGFloat(max(0, rowCount - 1))
        }
        
        // Add padding
        let width = maxX + spacing * 2
        let height = maxY + spacing * 2
        
        return CGSize(width: width, height: height)
    }
    
    // Add a widget to this tab
    func addWidget(_ widget: WidgetModel) {
        widgets.append(widget)
    }
    
    // Remove a widget by ID
    func removeWidget(withID id: UUID) {
        widgets.removeAll(where: { $0.id == id })
    }
}
