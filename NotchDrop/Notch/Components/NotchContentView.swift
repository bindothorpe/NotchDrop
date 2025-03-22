//
//  NotchContentView.swift
//  NotchDrop
//
//  Created by 秋星桥 on 2024/7/7.
//  Updated by Claude on 22/03/2025.
//

import ColorfulX
import SwiftUI
import UniformTypeIdentifiers

// Notch Content
struct NotchContentView: View {
    @StateObject var vm: NotchViewModel

    var body: some View {
        VStack(spacing: vm.spacing) {
            // Tab content
            ZStack {
                if let selectedTab = vm.selectedTab {
                    DynamicTabView(tab: selectedTab, vm: vm)
                        .transition(.scale(scale: 0.8).combined(with: .opacity))
                        .id(selectedTab.id) // Force view refresh when tab changes
                } else {
                    // Fallback for legacy content types for backward compatibility
                    switch vm.contentType {
                    case .normal:
                        NotchNormalView(vm: vm)
                            .transition(.scale(scale: 0.8).combined(with: .opacity))
                    case .menu:
                        NotchMenuView(vm: vm)
                            .transition(.scale(scale: 0.8).combined(with: .opacity))
                    case .settings:
                        NotchSettingsView(vm: vm)
                            .transition(.scale(scale: 0.8).combined(with: .opacity))
                    }
                }
            }
        }
        .animation(vm.animation, value: vm.selectedTabIndex)
        .animation(vm.animation, value: vm.contentType)
    }
}

// Dynamic tab view that renders widgets based on the tab model
struct DynamicTabView: View {
    @ObservedObject var tab: TabModel
    @ObservedObject var vm: NotchViewModel
    
    var body: some View {
        ZStack {
            // Widgets
            ForEach(tab.widgets) { widget in
                widgetView(for: widget)
                    .frame(
                        width: widget.colSpan * vm.cellSize + (widget.colSpan - 1) * vm.spacing,
                        height: widget.rowSpan * vm.cellSize + (widget.rowSpan - 1) * vm.spacing
                    )
                    .position(
                        x: calculateXPosition(widget),
                        y: calculateYPosition(widget)
                    )
            }
        }
        .frame(
            width: CGFloat(tab.colCount) * vm.cellSize + CGFloat(tab.colCount - 1) * vm.spacing,
            height: CGFloat(tab.rowCount) * vm.cellSize + CGFloat(tab.rowCount - 1) * vm.spacing
        )
        .onAppear {
            vm.updateNotchSize()
        }
    }
    
    // Calculate the X position accounting for spacing between widgets
    private func calculateXPosition(_ widget: WidgetModel) -> CGFloat {
        // Calculate base position
        let widgetCenterX = widget.xPosition * (vm.cellSize + vm.spacing) +
                          (widget.colSpan * vm.cellSize + (widget.colSpan - 1) * vm.spacing) / 2
        
        return widgetCenterX
    }
    
    // Calculate the Y position accounting for spacing between widgets
    private func calculateYPosition(_ widget: WidgetModel) -> CGFloat {
        // Calculate base position
        let widgetCenterY = widget.yPosition * (vm.cellSize + vm.spacing) +
                          (widget.rowSpan * vm.cellSize + (widget.rowSpan - 1) * vm.spacing) / 2
        
        return widgetCenterY
    }
    
    @ViewBuilder
    func widgetView(for widget: WidgetModel) -> some View {
        switch widget.type {
        case .airDrop:
            AirDropView(vm: vm)
                
        case .trayDrop:
            TrayView(vm: vm)
                
        case .placeholder:
            PlaceholderView(
                vm: vm,
                label: widget.configValue(for: "label", defaultValue: "Placeholder"),
                colSpan: widget.colSpan,
                rowSpan: widget.rowSpan,
                backgroundColor: Color.blue.opacity(0.3)
            )
                
        case .settings:
            NotchSettingsView(vm: vm)
                
        case .menuItem:
            MenuItemView(widget: widget, vm: vm)
        }
    }
}

// View for menu item widgets
struct MenuItemView: View {
    @ObservedObject var widget: WidgetModel
    @ObservedObject var vm: NotchViewModel
    @StateObject var tvm = TrayDrop.shared
    
    @State var hover: Bool = false
    
    var title: String {
        widget.configValue(for: "title", defaultValue: "Menu Item")
    }
    
    var iconName: String {
        widget.configValue(for: "icon", defaultValue: "square")
    }
    
    var action: String {
        widget.configValue(for: "action", defaultValue: "none")
    }
    
    var url: String {
        widget.configValue(for: "url", defaultValue: "")
    }
    
    var isSystemIcon: Bool {
        widget.configValue(for: "isSystemIcon", defaultValue: "true") == "true"
    }
    
    var body: some View {
        ColorButton(
            color: action == "exit" || action == "clearTray" ? [.red] : ColorfulPreset.colorful.colors,
            image: isSystemIcon ? Image(systemName: iconName) : Image(iconName),
            title: LocalizedStringKey(title)
        )
        .onTapGesture {
            performAction()
        }
        .clipShape(RoundedRectangle(cornerRadius: vm.cornerRadius))
    }
    
    func performAction() {
        switch action {
        case "openURL":
            if let url = URL(string: url) {
                NSWorkspace.shared.open(url)
            }
            vm.notchClose()
            
        case "openSettings":
            vm.openSettingsWindow()
            
        case "clearTray":
            tvm.removeAll()
            vm.notchClose()
            
        case "exit":
            vm.notchClose()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                NSApp.terminate(nil)
            }
            
        default:
            break
        }
    }
}

// Re-implementing ColorButton to ensure compatibility
private struct ColorButton: View, NotchSizeProvider {
    let color: [Color]
    let image: Image
    let title: LocalizedStringKey

    @State var hover: Bool = false

    var body: some View {
        Color.white
            .opacity(0.1)
            .overlay(
                ColorfulView(
                    color: .constant(color),
                    speed: .constant(0)
                )
                .mask {
                    VStack(spacing: 8) {
                        Text("888888")
                            .hidden()
                            .overlay {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                        Text(title)
                    }
                    .font(.system(.headline, design: .rounded))
                }
                .contentShape(Rectangle())
                .scaleEffect(hover ? 1.05 : 1)
                .animation(.spring, value: hover)
                .onHover { hover = $0 }
            )
            .aspectRatio(1, contentMode: .fit)
            .contentShape(Rectangle())
    }
    
    // NotchSizeProvider implementation
    func getColSpan() -> CGFloat { 1.0 }
    func getRowSpan() -> CGFloat { 1.0 }
}

#Preview {
    NotchContentView(vm: .init())
        .padding()
        .frame(width: 600, height: 200, alignment: .center)
        .background(.black)
        .preferredColorScheme(.dark)
}
