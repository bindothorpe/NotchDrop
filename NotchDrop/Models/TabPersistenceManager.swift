//
//  TabPersistenceManager.swift
//  NotchDrop
//
//  Created by Claude on 22/03/2025.
//

import Foundation
import Combine

class TabPersistenceManager {
    static let shared = TabPersistenceManager()
    
    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private var tabsURL: URL {
        documentsDirectory.appendingPathComponent("TabsConfig").appendingPathComponent("tabs.json")
    }
    
    private init() {
        // Create directory if it doesn't exist
        try? fileManager.createDirectory(
            at: tabsURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
    }
    
    // Save tabs to disk
    func saveTabs(_ tabs: [TabModel]) {
        do {
            let data = try encoder.encode(tabs)
            try data.write(to: tabsURL)
            print("Successfully saved \(tabs.count) tabs")
        } catch {
            print("Failed to save tabs: \(error.localizedDescription)")
        }
    }
    
    // Load tabs from disk
    func loadTabs() -> [TabModel]? {
        guard fileManager.fileExists(atPath: tabsURL.path) else {
            print("No saved tabs found")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: tabsURL)
            let tabs = try decoder.decode([TabModel].self, from: data)
            print("Successfully loaded \(tabs.count) tabs")
            return tabs
        } catch {
            print("Failed to load tabs: \(error.localizedDescription)")
            return nil
        }
    }
    
    // Delete saved tabs (for reset)
    func deleteSavedTabs() {
        guard fileManager.fileExists(atPath: tabsURL.path) else { return }
        
        do {
            try fileManager.removeItem(at: tabsURL)
            print("Deleted saved tabs configuration")
        } catch {
            print("Failed to delete saved tabs: \(error.localizedDescription)")
        }
    }
}

// MARK: - Convenience Methods for Tab Model

extension TabModel {
    static func loadFrom(id: UUID) -> TabModel? {
        guard let tabs = TabPersistenceManager.shared.loadTabs() else {
            return nil
        }
        
        return tabs.first(where: { $0.id == id })
    }
    
    func save() {
        if var allTabs = TabPersistenceManager.shared.loadTabs() {
            // Replace or add this tab
            if let index = allTabs.firstIndex(where: { $0.id == self.id }) {
                allTabs[index] = self
            } else {
                allTabs.append(self)
            }
            TabPersistenceManager.shared.saveTabs(allTabs)
        } else {
            // Create new tabs array with just this tab
            TabPersistenceManager.shared.saveTabs([self])
        }
    }
}
