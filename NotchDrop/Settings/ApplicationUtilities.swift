//
//  ApplicationUtilities.swift
//  NotchDrop
//
//  Created by Bindo Thorpe on 14/03/2025.
//


// ApplicationUtilities.swift
import SwiftUI

class ApplicationUtilities {
    static let shared = ApplicationUtilities()
    
    private init() {}
    
    func restartApplication() {
        let alert = NSAlert()
        alert.messageText = "Restart Application"
        alert.informativeText = "Do you want to restart NotchDrop now?"
        alert.addButton(withTitle: "Restart")
        alert.addButton(withTitle: "Cancel")
        
        if alert.runModal() == .alertFirstButtonReturn {
            let bundleID = Bundle.main.bundleIdentifier!
            
            let task = Process()
            task.launchPath = "/usr/bin/open"
            task.arguments = ["-b", bundleID, "-n"]
            
            try? task.run()
            NSApp.terminate(nil)
        }
    }
    
    func openWebsite() {
        if let url = URL(string: "https://example.com") {
            NSWorkspace.shared.open(url)
        }
    }
}
