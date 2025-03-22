//
//  SettingsView.swift
//  NotchDrop
//
//  Created by Bindo Thorpe on 11/03/2025.
//  Updated by Claude on 22/03/2025.
//

import SwiftUI

enum SidebarItem: String, Identifiable, CaseIterable {
    var id: String { rawValue }
    
    case general
    case appearance
    case behavior
    case tabs
    case about
    
    // Add a property to get the appropriate system image name for each item
    var iconName: String {
        switch self {
        case .general:
            return "gear"
        case .appearance:
            return "paintbrush"
        case .behavior:
            return "hand.tap"
        case .tabs:
            return "rectangle.grid.2x2"
        case .about:
            return "info.circle"
        }
    }
}

struct SettingsView: View {
    private let sidebarVisibility: NavigationSplitViewVisibility = .all
    @State var selectedSidebarItem: SidebarItem = .general
    @ObservedObject var notchViewModel: NotchViewModel
    
    init() {
        // Get reference to the NotchViewModel from the AppDelegate
        if let appDelegate = NSApp.delegate as? AppDelegate,
           let windowController = appDelegate.mainWindowController,
           let vm = windowController.vm {
            self.notchViewModel = vm
        } else {
            // Fallback to a new instance if not available
            self.notchViewModel = NotchViewModel()
        }
    }
    
    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            VStack(spacing: 0) {
                List(selection: $selectedSidebarItem) {
                    ForEach(SidebarItem.allCases.filter { $0 != .about }, id: \.self) { item in
                        NavigationLink(value: item) {
                            Label(item.rawValue.localizedCapitalized, systemImage: item.iconName)
                        }
                    }
                }
                .listStyle(SidebarListStyle())
                
                Spacer()
                Divider()
                
                // About section at the bottom
                List(selection: $selectedSidebarItem) {
                    NavigationLink(value: SidebarItem.about) {
                        Label(SidebarItem.about.rawValue.localizedCapitalized,
                              systemImage: SidebarItem.about.iconName)
                    }
                }
                .listStyle(SidebarListStyle())
                .frame(height: 50) // Adjust this height as needed
            }
            .toolbar(.hidden, for: .automatic)
        } detail: {
            switch selectedSidebarItem {
            case .general:
                GeneralSettingsView()
            case .appearance:
                AppearanceSettingsView()
            case .behavior:
                BehaviorSettingsView()
            case .tabs:
                TabManagerView(vm: notchViewModel)
            case .about:
                AboutView()
            }
        }
        .frame(width: 800, height: 600)
    }
}

struct AppDelegateKey: EnvironmentKey {
    static let defaultValue: AppDelegate? = nil
}

extension EnvironmentValues {
    var appDelegate: AppDelegate? {
        get { self[AppDelegateKey.self] }
        set { self[AppDelegateKey.self] = newValue }
    }
}
