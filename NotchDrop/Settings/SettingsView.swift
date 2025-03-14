//
//  SettingsView.swift
//  NotchDrop
//
//  Created by Bindo Thorpe on 11/03/2025.
//

import SwiftUI
import SwiftUI

import SwiftUI

enum SidebarItem: String, Identifiable, CaseIterable {
    var id: String { rawValue }
    
    case general
    case appearance
    case behavior
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
        case .about:
            return "info.circle"
        }
    }
}

struct SettingsView: View {
    private let sidebarVisibility: NavigationSplitViewVisibility = .all
    @State var selectedSidebarItem: SidebarItem = .general
    
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
            case .about:
                AboutView()
            }
        }
        .frame(width: 800, height: 600)
    }
}
