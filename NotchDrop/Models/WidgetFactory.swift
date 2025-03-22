//
//  WidgetFactory.swift
//  NotchDrop
//
//  Created by Bindo Thorpe on 22/03/2025.
//

import SwiftUI

class WidgetFactory {
    static let shared = WidgetFactory()
    
    private init() {}
    
    // Helper for creating widgets with predefined configurations
    func createWidget(type: WidgetType, xPosition: CGFloat = 0, yPosition: CGFloat = 0) -> WidgetModel {
        let widget = WidgetModel(
            type: type,
            xPosition: xPosition,
            yPosition: yPosition,
            colSpan: type.defaultColSpan,
            rowSpan: type.defaultRowSpan
        )
        
        // Add default configuration based on widget type
        switch type {
        case .airDrop:
            // No specific configuration needed
            break
            
        case .trayDrop:
            // No specific configuration needed
            break
            
        case .placeholder:
            widget.setConfigValue("Placeholder", for: "label")
            widget.setConfigValue("blue", for: "color")
            
        case .settings:
            // No specific configuration needed
            break
            
        case .menuItem:
            widget.setConfigValue("Menu Item", for: "title")
            widget.setConfigValue("square", for: "icon")
            widget.setConfigValue("true", for: "isSystemIcon")
            widget.setConfigValue("none", for: "action")
        }
        
        return widget
    }
    
    // Create a menu item widget with specific configuration
    func createMenuItem(
        title: String,
        icon: String,
        action: String,
        isSystemIcon: Bool = true,
        xPosition: CGFloat = 0,
        yPosition: CGFloat = 0
    ) -> WidgetModel {
        let widget = WidgetModel(
            type: .menuItem,
            xPosition: xPosition,
            yPosition: yPosition
        )
        
        widget.setConfigValue(title, for: "title")
        widget.setConfigValue(icon, for: "icon")
        widget.setConfigValue(isSystemIcon ? "true" : "false", for: "isSystemIcon")
        widget.setConfigValue(action, for: "action")
        
        return widget
    }
    
    // Create a URL menu item
    func createURLMenuItem(
        title: String,
        icon: String,
        url: String,
        isSystemIcon: Bool = true,
        xPosition: CGFloat = 0,
        yPosition: CGFloat = 0
    ) -> WidgetModel {
        let widget = createMenuItem(
            title: title,
            icon: icon,
            action: "openURL",
            isSystemIcon: isSystemIcon,
            xPosition: xPosition,
            yPosition: yPosition
        )
        widget.setConfigValue(url, for: "url")
        return widget
    }
    
    // Create a placeholder widget with customization
    func createPlaceholder(
        label: String,
        color: String = "blue",
        xPosition: CGFloat = 0,
        yPosition: CGFloat = 0,
        colSpan: CGFloat = 1,
        rowSpan: CGFloat = 1
    ) -> WidgetModel {
        let widget = WidgetModel(
            type: .placeholder,
            xPosition: xPosition,
            yPosition: yPosition,
            colSpan: colSpan,
            rowSpan: rowSpan
        )
        
        widget.setConfigValue(label, for: "label")
        widget.setConfigValue(color, for: "color")
        
        return widget
    }
    
    // Get all available widget types with descriptions
    func availableWidgetTypes() -> [(type: WidgetType, name: String, description: String)] {
        return [
            (.airDrop, "AirDrop", "Quick access to macOS AirDrop feature"),
            (.trayDrop, "Tray", "Temporary file storage area"),
            (.placeholder, "Placeholder", "Custom placeholder widget"),
            (.settings, "Settings", "Settings control panel"),
            (.menuItem, "Menu Item", "Configurable menu button with actions")
        ]
    }
}

// Extension to add color support for placeholders
extension Color {
    static func fromString(_ string: String) -> Color {
        switch string.lowercased() {
        case "red":
            return .red
        case "green":
            return .green
        case "blue":
            return .blue
        case "yellow":
            return .yellow
        case "orange":
            return .orange
        case "purple":
            return .purple
        case "pink":
            return .pink
        case "gray", "grey":
            return .gray
        default:
            return .blue
        }
    }
}

// Extension to support widget creation in TabModel
extension TabModel {
    func addMenuWidget(title: String, icon: String, action: String, at position: (x: CGFloat, y: CGFloat) = (0, 0)) {
        let widget = WidgetFactory.shared.createMenuItem(
            title: title,
            icon: icon,
            action: action,
            xPosition: position.x,
            yPosition: position.y
        )
        self.addWidget(widget)
    }
    
    func addURLWidget(title: String, icon: String, url: String, at position: (x: CGFloat, y: CGFloat) = (0, 0)) {
        let widget = WidgetFactory.shared.createURLMenuItem(
            title: title,
            icon: icon,
            url: url,
            xPosition: position.x,
            yPosition: position.y
        )
        self.addWidget(widget)
    }
    
    func createBasicLayout(withAirDrop: Bool = true, withTray: Bool = true) {
        widgets.removeAll()
        
        if withAirDrop {
            let airDropWidget = WidgetFactory.shared.createWidget(type: .airDrop)
            addWidget(airDropWidget)
        }
        
        if withTray {
            let trayWidget = WidgetFactory.shared.createWidget(
                type: .trayDrop,
                xPosition: withAirDrop ? 1 : 0
            )
            addWidget(trayWidget)
        }
    }
}
