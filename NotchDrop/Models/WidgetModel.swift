//
//  WidgetModel.swift
//  NotchDrop
//
//  Created by Bindo Thorpe on 22/03/2025.
//

import SwiftUI

class WidgetModel: Identifiable, ObservableObject, Codable {
    let id: UUID
    let type: WidgetType
    
    // Position in the grid (0-based)
    @Published var xPosition: CGFloat
    @Published var yPosition: CGFloat
    
    // Size in grid cells
    @Published var colSpan: CGFloat
    @Published var rowSpan: CGFloat
    
    // Widget-specific configuration data
    @Published var configuration: [String: String] = [:]
    
    enum CodingKeys: String, CodingKey {
        case id, type, xPosition, yPosition, colSpan, rowSpan, configuration
    }
    
    init(id: UUID = UUID(),
         type: WidgetType,
         xPosition: CGFloat = 0,
         yPosition: CGFloat = 0,
         colSpan: CGFloat = 1.0,
         rowSpan: CGFloat = 1.0,
         configuration: [String: String] = [:]) {
        self.id = id
        self.type = type
        self.xPosition = xPosition
        self.yPosition = yPosition
        self.colSpan = colSpan
        self.rowSpan = rowSpan
        self.configuration = configuration
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        type = try container.decode(WidgetType.self, forKey: .type)
        xPosition = try container.decode(CGFloat.self, forKey: .xPosition)
        yPosition = try container.decode(CGFloat.self, forKey: .yPosition)
        colSpan = try container.decode(CGFloat.self, forKey: .colSpan)
        rowSpan = try container.decode(CGFloat.self, forKey: .rowSpan)
        configuration = try container.decode([String: String].self, forKey: .configuration)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(xPosition, forKey: .xPosition)
        try container.encode(yPosition, forKey: .yPosition)
        try container.encode(colSpan, forKey: .colSpan)
        try container.encode(rowSpan, forKey: .rowSpan)
        try container.encode(configuration, forKey: .configuration)
    }
    
    // Get configuration value with default fallback
    func configValue(for key: String, defaultValue: String = "") -> String {
        return configuration[key] ?? defaultValue
    }
    
    // Set configuration value
    func setConfigValue(_ value: String, for key: String) {
        configuration[key] = value
        objectWillChange.send()
    }
}

// Widget types supported by the application
enum WidgetType: String, CaseIterable, Codable {
    case airDrop = "AirDrop"
    case trayDrop = "TrayDrop"
    case placeholder = "Placeholder"
    case settings = "Settings"
    case menuItem = "MenuItem"
    
    // Add more widget types as needed
    
    var displayName: String {
        return self.rawValue
    }
    
    var defaultIcon: String {
        switch self {
        case .airDrop:
            return "airplayaudio"
        case .trayDrop:
            return "tray.and.arrow.down.fill"
        case .placeholder:
            return "square.dashed"
        case .settings:
            return "gear"
        case .menuItem:
            return "list.bullet"
        }
    }
    
    var defaultColSpan: CGFloat {
        switch self {
        case .trayDrop:
            return 3.0
        default:
            return 1.0
        }
    }
    
    var defaultRowSpan: CGFloat {
        return 1.0
    }
}
