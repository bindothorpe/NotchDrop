//
//  KeyboardShortcuts.swift
//  NotchDrop
//
//  Created by Bindo Thorpe on 11/03/2025.
//

import AppKit

class ShortcutManager {
    static let shared = ShortcutManager()
    
    private init() {
        // Register for keyboard events
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleKeyEvent(event)
        }
        
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if self?.handleKeyEvent(event) == true {
                return nil // Event was handled, don't pass it along
            }
            return event // Pass the event along
        }
    }
    
    private func handleKeyEvent(_ event: NSEvent) -> Bool {
        // Handle Command + , (comma) for settings
        if event.modifierFlags.contains(.command) && event.keyCode == 43 { // 43 is the key code for comma
            if let appDelegate = NSApp.delegate as? AppDelegate {
                appDelegate.openSettings()
                return true
            }
        }
        
        return false
    }
    
    // You can add more shortcut handlers here as needed
    func registerShortcuts() {
        // This method can be used to register any additional shortcuts during app initialization
        print("Shortcuts registered")
    }
}
