//
//  NotchHeaderView.swift
//  NotchDrop
//
//  Created by 秋星桥 on 2024/7/7.
//  Updated by Claude on 22/03/2025.
//

import ColorfulX
import SwiftUI

struct NotchHeaderView: View {
    @StateObject var vm: NotchViewModel

    var body: some View {
        HStack {
            // Show tabs if there are multiple, otherwise show the app title
            if vm.tabs.count > 1 && vm.status == .opened {
                TabSelectorBar(vm: vm)
            } else {
                Text(
                    vm.contentType == .settings
                        ? "Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown") (Build: \(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"))"
                        : "Notch Drop"
                )
                .contentTransition(.numericText())
            }
            
            Spacer()
            
            // Settings gear icon
            Image(systemName: "gear").onTapGesture {
                vm.openSettingsWindow()
            }
        }
        .animation(vm.animation, value: vm.contentType)
        .animation(vm.animation, value: vm.selectedTabIndex)
        .font(.system(.headline, design: .rounded))
    }
}

// Tab selector for the header
struct TabSelectorBar: View {
    @ObservedObject var vm: NotchViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(vm.tabs.enumerated()), id: \.element.id) { index, tab in
                    Button(action: {
                        vm.selectTab(at: index)
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 12))
                            Text(tab.title)
                                .font(.system(size: 12, weight: vm.selectedTabIndex == index ? .bold : .medium))
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(index == vm.selectedTabIndex ? Color.blue.opacity(0.5) : Color.black.opacity(0.2))
                        .cornerRadius(6)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    NotchHeaderView(vm: .init())
}
