//
//  NotchViewModel.swift
//  NotchDrop
//
//  Created by 秋星桥 on 2024/7/7.
//  Updated by Claude on 22/03/2025.
//

import Cocoa
import Combine
import Foundation
import LaunchAtLogin
import SwiftUI


// Notch View Model
class NotchViewModel: NSObject, ObservableObject {
    var cancellables: Set<AnyCancellable> = []
    let inset: CGFloat
    
    // Size manager
    private(set) lazy var sizeManager = NotchSizeManager(viewModel: self)

    init(inset: CGFloat = -4) {
        self.inset = inset
        super.init()
        setupCancellables()
        setupSizeConfigurations() // Initialize the size manager
        initializeWithSavedTabs() // Load tabs or set up defaults
    }

    deinit {
        destroy()
    }

    let animation: Animation = .interactiveSpring(
        duration: 0.3,
        extraBounce: 0.15,
        blendDuration: 0.125
    )
    @Published var notchOpenedSize: CGSize = .init(width: 800, height: 160)
    let dropDetectorRange: CGFloat = 32

    enum Status: String, Codable, Hashable, Equatable {
        case closed
        case opened
        case popping
    }

    enum OpenReason: String, Codable, Hashable, Equatable {
        case click
        case drag
        case boot
        case unknown
    }

    enum ContentType: Int, Codable, Hashable, Equatable {
        case normal
        case menu
        case settings
    }
    
    // New properties for tab management
    @Published var tabs: [TabModel] = []
    @Published var selectedTabIndex: Int = 0
    
    var selectedTab: TabModel? {
        guard selectedTabIndex >= 0 && selectedTabIndex < tabs.count else { return nil }
        return tabs[selectedTabIndex]
    }

    var notchOpenedRect: CGRect {
        .init(
            x: screenRect.origin.x + (screenRect.width - notchOpenedSize.width) / 2,
            y: screenRect.origin.y + screenRect.height - notchOpenedSize.height,
            width: notchOpenedSize.width,
            height: notchOpenedSize.height
        )
    }

    var headlineOpenedRect: CGRect {
        .init(
            x: screenRect.origin.x + (screenRect.width - notchOpenedSize.width) / 2,
            y: screenRect.origin.y + screenRect.height - deviceNotchRect.height,
            width: notchOpenedSize.width,
            height: deviceNotchRect.height
        )
    }

    @Published private(set) var status: Status = .closed
    @Published var openReason: OpenReason = .unknown
    @Published var contentType: ContentType = .normal {
        didSet {
            // Update notch size when content type changes
            if oldValue != contentType && status == .opened {
                sizeManager.updateNotchSize(for: contentType)
            }
        }
    }

    @Published var spacing: CGFloat = 16
    @Published var cellSize: CGFloat = 108
    @Published var cornerRadius: CGFloat = 16
    @Published var deviceNotchRect: CGRect = .zero {
        didSet {
            // Update size when device notch rect changes
            if status == .opened {
                sizeManager.updateNotchSize(for: contentType)
            }
        }
    }
    @Published var screenRect: CGRect = .zero
    @Published var optionKeyPressed: Bool = false
    @Published var notchVisible: Bool = true

    @PublishedPersist(key: "selectedLanguage", defaultValue: .system)
    var selectedLanguage: Language

    @PublishedPersist(key: "hapticFeedback", defaultValue: true)
    var hapticFeedback: Bool

    let hapticSender = PassthroughSubject<Void, Never>()
    
    // MARK: - Tab Management Methods
    
    func setupDefaultTabs() {
        // Don't add default tabs if we already have tabs
        if !tabs.isEmpty { return }
        
        // Create the default "Normal" tab with AirDrop and TrayDrop widgets
        let normalTab = TabModel(title: "Home", icon: "house.fill", sortOrder: 0)
        let airDropWidget = WidgetModel(type: .airDrop, xPosition: 0, yPosition: 0)
        let trayDropWidget = WidgetModel(type: .trayDrop, xPosition: 1, yPosition: 0, colSpan: 3)
        normalTab.addWidget(airDropWidget)
        normalTab.addWidget(trayDropWidget)
        tabs.append(normalTab)
        
        // Create a "Menu" tab
        let menuTab = TabModel(title: "Menu", icon: "list.bullet", sortOrder: 1)
        let githubWidget = WidgetModel(type: .menuItem, xPosition: 0, yPosition: 0)
        githubWidget.setConfigValue("GitHub", for: "title")
        githubWidget.setConfigValue("gitHub", for: "icon")
        githubWidget.setConfigValue("openURL", for: "action")
        githubWidget.setConfigValue("https://github.com/Lakr233/NotchDrop", for: "url")
        
        let donateWidget = WidgetModel(type: .menuItem, xPosition: 1, yPosition: 0)
        donateWidget.setConfigValue("Love Drop", for: "title")
        donateWidget.setConfigValue("heart.fill", for: "icon")
        donateWidget.setConfigValue("openURL", for: "action")
        donateWidget.setConfigValue("https://github.com/sponsors/Lakr233", for: "url")
        
        let settingsWidget = WidgetModel(type: .menuItem, xPosition: 2, yPosition: 0)
        settingsWidget.setConfigValue("Settings", for: "title")
        settingsWidget.setConfigValue("gear", for: "icon")
        settingsWidget.setConfigValue("openSettings", for: "action")
        
        let clearWidget = WidgetModel(type: .menuItem, xPosition: 3, yPosition: 0)
        clearWidget.setConfigValue("Clear", for: "title")
        clearWidget.setConfigValue("trash", for: "icon")
        clearWidget.setConfigValue("clearTray", for: "action")
        
        let closeWidget = WidgetModel(type: .menuItem, xPosition: 4, yPosition: 0)
        closeWidget.setConfigValue("Exit", for: "title")
        closeWidget.setConfigValue("xmark", for: "icon")
        closeWidget.setConfigValue("exit", for: "action")
        
        menuTab.addWidget(githubWidget)
        menuTab.addWidget(donateWidget)
        menuTab.addWidget(settingsWidget)
        menuTab.addWidget(clearWidget)
        menuTab.addWidget(closeWidget)
        tabs.append(menuTab)
        
        // Create a "Settings" tab
        let settingsTab = TabModel(title: "Settings", icon: "gear", sortOrder: 2)
        let settingsControlWidget = WidgetModel(type: .settings, xPosition: 0, yPosition: 0, colSpan: 1, rowSpan: 3)
        settingsTab.addWidget(settingsControlWidget)
        tabs.append(settingsTab)
    }
    
    func addTab(title: String, icon: String) -> TabModel {
        let sortOrder = tabs.map { $0.sortOrder }.max() ?? 0 + 1
        let newTab = TabModel(title: title, icon: icon, sortOrder: sortOrder)
        tabs.append(newTab)
        return newTab
    }
    
    func removeTab(at index: Int) {
        guard index >= 0 && index < tabs.count else { return }
        
        // Prevent removing the last tab
        if tabs.count <= 1 {
            return
        }
        
        tabs.remove(at: index)
        
        // Adjust selected tab if needed
        if selectedTabIndex >= tabs.count {
            selectedTabIndex = max(0, tabs.count - 1)
        }
    }
    
    func moveTab(from sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex >= 0, sourceIndex < tabs.count,
              destinationIndex >= 0, destinationIndex < tabs.count else {
            return
        }
        
        let tab = tabs.remove(at: sourceIndex)
        tabs.insert(tab, at: destinationIndex)
        
        // Update sort orders
        for (index, tab) in tabs.enumerated() {
            tab.sortOrder = index
        }
        
        // Update selected tab index if needed
        if selectedTabIndex == sourceIndex {
            selectedTabIndex = destinationIndex
        } else if selectedTabIndex > sourceIndex && selectedTabIndex <= destinationIndex {
            selectedTabIndex -= 1
        } else if selectedTabIndex < sourceIndex && selectedTabIndex >= destinationIndex {
            selectedTabIndex += 1
        }
    }
    
    func selectTab(_ tab: TabModel) {
        if let index = tabs.firstIndex(where: { $0.id == tab.id }) {
            selectedTabIndex = index
        }
    }
    
    func selectTab(at index: Int) {
        guard index >= 0 && index < tabs.count else { return }
        selectedTabIndex = index
    }
    
    // Widget management
    func addWidget(to tabIndex: Int, type: WidgetType, xPosition: CGFloat = 0, yPosition: CGFloat = 0) -> WidgetModel? {
        guard tabIndex >= 0 && tabIndex < tabs.count else { return nil }
        
        let widget = WidgetModel(
            type: type,
            xPosition: xPosition,
            yPosition: yPosition,
            colSpan: type.defaultColSpan,
            rowSpan: type.defaultRowSpan
        )
        tabs[tabIndex].addWidget(widget)
        
        // Update notch size if this is the current tab
        if tabIndex == selectedTabIndex && status == .opened {
            updateNotchSize()
        }
        
        return widget
    }
    
    func removeWidget(from tabIndex: Int, widgetID: UUID) {
        guard tabIndex >= 0 && tabIndex < tabs.count else { return }
        tabs[tabIndex].removeWidget(withID: widgetID)
        
        // Update notch size if this is the current tab
        if tabIndex == selectedTabIndex && status == .opened {
            updateNotchSize()
        }
    }
    
    // MARK: - Notch Control
    
    func notchOpen(_ reason: OpenReason) {
        openReason = reason
        status = .opened
        
        // Use the current tab to calculate notch size
        if selectedTabIndex >= 0 && selectedTabIndex < tabs.count {
            // Translate legacy contentType to tabIndex if needed
            switch contentType {
            case .normal:
                selectedTabIndex = 0
            case .menu:
                selectedTabIndex = 1
            case .settings:
                selectedTabIndex = 2
            }
        }
        
        updateNotchSize()
        NSApp.activate(ignoringOtherApps: true)
    }

    func notchClose() {
        openReason = .unknown
        status = .closed
        contentType = .normal
    }

    func showSettings() {
        contentType = .settings
        selectTab(at: 2) // Select the settings tab
    }
    
    func openSettingsWindow() {
        if let appDelegate = NSApp.delegate as? AppDelegate {
            appDelegate.openSettings()
        }
    }

    func notchPop() {
        openReason = .unknown
        status = .popping
    }
    
    // Method to update notch size based on current tab
    func updateNotchSize() {
        guard let tab = selectedTab else { return }
        
        // Update content type based on tab index for backward compatibility
        switch selectedTabIndex {
        case 0:
            contentType = .normal
        case 1:
            contentType = .menu
        case 2:
            contentType = .settings
        default:
            contentType = .normal
        }
        
        let size = tab.calculateDimensions(cellSize: cellSize, spacing: spacing)
        
        // Ensure minimum width and height
        let minWidth = max(deviceNotchRect.width, 120)
        let minHeight = max(deviceNotchRect.height * 2, 120)
        
        // Apply size limits
        var finalSize = size
        finalSize.width = max(minWidth, finalSize.width)
        finalSize.height = max(minHeight, finalSize.height + 34)
        
        // Don't exceed screen size minus some margin
        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            finalSize.width = min(screenFrame.width * 0.9, finalSize.width)
            finalSize.height = min(screenFrame.height * 0.8, finalSize.height)
        }
        
        // Update the size
        notchOpenedSize = finalSize
    }
    
    // Legacy method to support existing size manager
    func updateNotchSize(_ newSize: CGSize) {
        // Ensure minimum width and height
        let minWidth = max(deviceNotchRect.width * 2, 120)
        let minHeight = max(deviceNotchRect.height * 2, 120)
        
        // Apply size limits
        var finalSize = newSize
        finalSize.width = max(minWidth, finalSize.width)
        finalSize.height = max(minHeight, finalSize.height)
        
        // Don't exceed screen size minus some margin
        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            finalSize.width = min(screenFrame.width * 0.9, finalSize.width)
            finalSize.height = min(screenFrame.height * 0.8, finalSize.height)
        }
        
        // Update the size
        notchOpenedSize = finalSize
    }
}
