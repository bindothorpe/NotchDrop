//
//  TabManagerView.swift
//  NotchDrop
//
//  Created by Claude on 22/03/2025.
//

import SwiftUI

struct TabManagerView: View {
    @ObservedObject var vm: NotchViewModel
    @State private var isAddingTab = false
    @State private var isEditingTab = false
    @State private var editingTabIndex: Int? = nil
    @State private var newTabTitle = ""
    @State private var newTabIcon = "square"
    
    // Common system icons for tabs
    private let commonIcons = [
        "house.fill", "list.bullet", "gear", "star.fill", "heart.fill",
        "doc.fill", "folder.fill", "tray.fill", "terminal.fill", "wrench.fill",
        "hammer.fill", "pencil", "trash.fill", "globe", "link"
    ]
    
    var body: some View {
        List {
            Section {
                ForEach(Array(vm.tabs.enumerated()), id: \.element.id) { index, tab in
                    HStack {
                        Image(systemName: tab.icon)
                            .foregroundColor(.blue)
                            .frame(width: 30)
                        
                        Text(tab.title)
                            .font(.headline)
                        
                        Spacer()
                        
                        Text("\(tab.widgets.count) widgets")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        
                        Button(action: {
                            editingTabIndex = index
                            newTabTitle = tab.title
                            newTabIcon = tab.icon
                            isEditingTab = true
                        }) {
                            Image(systemName: "pencil")
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .padding(.horizontal, 4)
                        
                        if vm.tabs.count > 1 {
                            Button(action: {
                                vm.removeTab(at: index)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .padding(.horizontal, 4)
                        }
                    }
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // Navigate to tab editor
                        editingTabIndex = index
                        isEditingTab = true
                        newTabTitle = tab.title
                        newTabIcon = tab.icon
                    }
                }
                .onMove { indices, destination in
                    // Handle tab reordering
                    if let first = indices.first {
                        vm.moveTab(from: first, to: destination)
                    }
                }
            } header: {
                HStack {
                    Text("Tabs")
                    Spacer()
                    Button(action: {
                        isAddingTab = true
                        isEditingTab = false
                        newTabTitle = "New Tab"
                        newTabIcon = "square"
                    }) {
                        Label("Add Tab", systemImage: "plus")
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
            }
        }
        .sheet(isPresented: $isAddingTab) {
            TabEditorView(
                title: $newTabTitle,
                icon: $newTabIcon,
                commonIcons: commonIcons,
                onSave: {
                    let newTab = vm.addTab(title: newTabTitle, icon: newTabIcon)
                    isAddingTab = false
                    
                    // Add a placeholder widget to the new tab
                    let placeholderWidget = WidgetModel(
                        type: .placeholder,
                        xPosition: 0,
                        yPosition: 0,
                        colSpan: 1,
                        rowSpan: 1
                    )
                    placeholderWidget.setConfigValue("New Widget", for: "label")
                    newTab.addWidget(placeholderWidget)
                },
                onCancel: {
                    isAddingTab = false
                }
            )
            .frame(width: 400, height: 300)
            .padding()
        }
        .sheet(isPresented: $isEditingTab) {
            if let index = editingTabIndex, index < vm.tabs.count {
                TabDetailView(
                    vm: vm,
                    tab: vm.tabs[index],
                    tabTitle: $newTabTitle,
                    tabIcon: $newTabIcon,
                    commonIcons: commonIcons,
                    onSave: {
                        vm.tabs[index].title = newTabTitle
                        vm.tabs[index].icon = newTabIcon
                        isEditingTab = false
                    },
                    onCancel: {
                        isEditingTab = false
                    }
                )
                .frame(width: 600, height: 500)
                .padding()
            }
        }
    }
}

// Tab editor for creating or editing a tab
struct TabEditorView: View {
    @Binding var title: String
    @Binding var icon: String
    let commonIcons: [String]
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Tab Properties")
                .font(.headline)
                .padding(.top)
            
            Form {
                Section {
                    TextField("Tab Title", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    HStack {
                        Text("Icon:")
                            .frame(width: 60, alignment: .leading)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(commonIcons, id: \.self) { iconName in
                                    Button(action: {
                                        icon = iconName
                                    }) {
                                        Image(systemName: iconName)
                                            .font(.system(size: 20))
                                            .frame(width: 32, height: 32)
                                            .foregroundColor(icon == iconName ? .white : .primary)
                                            .background(icon == iconName ? Color.blue : Color.clear)
                                            .cornerRadius(6)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .frame(height: 40)
                    }
                    
                    HStack {
                        Text("Custom:")
                            .frame(width: 60, alignment: .leading)
                        
                        TextField("Custom Icon Name", text: $icon)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: .infinity)
                        
                        if !icon.isEmpty {
                            Image(systemName: icon)
                                .font(.system(size: 20))
                                .frame(width: 32, height: 32)
                                .foregroundColor(.primary)
                        }
                    }
                } header: {
                    Text("Basic Information")
                }
            }
            
            Spacer()
            
            HStack {
                Button("Cancel") {
                    onCancel()
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                Button("Save") {
                    onSave()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding([.horizontal, .bottom])
        }
    }
}

// Detailed view for editing a tab and its widgets
struct TabDetailView: View {
    @ObservedObject var vm: NotchViewModel
    @ObservedObject var tab: TabModel
    @Binding var tabTitle: String
    @Binding var tabIcon: String
    let commonIcons: [String]
    let onSave: () -> Void
    let onCancel: () -> Void
    
    @State private var isAddingWidget = false
    @State private var isEditingWidget = false
    @State private var editingWidgetIndex: Int? = nil
    @State private var newWidgetType: WidgetType = .placeholder
    @State private var newWidgetXPosition: CGFloat = 0
    @State private var newWidgetYPosition: CGFloat = 0
    @State private var newWidgetColSpan: CGFloat = 1
    @State private var newWidgetRowSpan: CGFloat = 1
    @State private var selectedWidgetID: UUID? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab name and icon editor
            HStack {
                VStack(alignment: .leading) {
                    Text("Tab Properties")
                        .font(.headline)
                    
                    HStack {
                        TextField("Tab Title", text: $tabTitle)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 200)
                        
                        Image(systemName: tabIcon)
                            .font(.system(size: 20))
                            .frame(width: 32, height: 32)
                            .foregroundColor(.primary)
                        
                        Picker("Icon", selection: $tabIcon) {
                            ForEach(commonIcons, id: \.self) { iconName in
                                HStack {
                                    Image(systemName: iconName)
                                    Text(iconName)
                                        .font(.caption)
                                }
                                .tag(iconName)
                            }
                        }
                        .frame(width: 150)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Grid Size")
                        .font(.headline)
                    
                    HStack {
                        Stepper("Rows: \(tab.rowCount)", value: Binding(
                            get: { self.tab.rowCount },
                            set: { self.tab.rowCount = max(1, $0) }
                        ), in: 1...10)
                        .frame(width: 150)
                        
                        Stepper("Columns: \(tab.colCount)", value: Binding(
                            get: { self.tab.colCount },
                            set: { self.tab.colCount = max(1, $0) }
                        ), in: 1...10)
                        .frame(width: 150)
                    }
                }
            }
            .padding()
            
            Divider()
            
            // Grid visualization
            Text("Widgets")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.horizontal, .top])
            
            ZStack {
                // Grid background
                GridBackgroundView(rowCount: tab.rowCount, colCount: tab.colCount)
                
                // Widgets
                ForEach(tab.widgets) { widget in
                    WidgetPreview(
                        widget: widget,
                        isSelected: selectedWidgetID == widget.id,
                        onClick: {
                            selectedWidgetID = widget.id
                        }
                    )
                    .position(
                        x: (widget.xPosition + widget.colSpan/2) * 60 + widget.xPosition * 4,
                        y: (widget.yPosition + widget.rowSpan/2) * 60 + widget.yPosition * 4
                    )
                }
            }
            .frame(
                width: CGFloat(tab.colCount) * 60 + CGFloat(tab.colCount - 1) * 4,
                height: CGFloat(tab.rowCount) * 60 + CGFloat(tab.rowCount - 1) * 4
            )
            .padding()
            .background(Color.black.opacity(0.2))
            .cornerRadius(8)
            
            // Widget controls
            HStack {
                Button(action: {
                    isAddingWidget = true
                    newWidgetType = .placeholder
                    newWidgetXPosition = 0
                    newWidgetYPosition = 0
                    newWidgetColSpan = 1
                    newWidgetRowSpan = 1
                }) {
                    Label("Add Widget", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                
                Spacer()
                
                if let selectedID = selectedWidgetID,
                   let index = tab.widgets.firstIndex(where: { $0.id == selectedID }) {
                    Button(action: {
                        isEditingWidget = true
                        editingWidgetIndex = index
                        let widget = tab.widgets[index]
                        newWidgetType = widget.type
                        newWidgetXPosition = widget.xPosition
                        newWidgetYPosition = widget.yPosition
                        newWidgetColSpan = widget.colSpan
                        newWidgetRowSpan = widget.rowSpan
                    }) {
                        Label("Edit", systemImage: "pencil")
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    
                    Button(action: {
                        tab.removeWidget(withID: selectedID)
                        selectedWidgetID = nil
                    }) {
                        Label("Remove", systemImage: "trash")
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .tint(.red)
                }
            }
            .padding()
            
            Divider()
            
            // Bottom buttons
            HStack {
                Button("Cancel") {
                    onCancel()
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                Button("Save") {
                    onSave()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(tabTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
        }
        .sheet(isPresented: $isAddingWidget) {
            WidgetEditorView(
                widgetType: $newWidgetType,
                xPosition: $newWidgetXPosition,
                yPosition: $newWidgetYPosition,
                colSpan: $newWidgetColSpan,
                rowSpan: $newWidgetRowSpan,
                maxRows: tab.rowCount,
                maxCols: tab.colCount,
                onSave: {
                    let newWidget = WidgetModel(
                        type: newWidgetType,
                        xPosition: newWidgetXPosition,
                        yPosition: newWidgetYPosition,
                        colSpan: newWidgetColSpan,
                        rowSpan: newWidgetRowSpan
                    )
                    tab.addWidget(newWidget)
                    isAddingWidget = false
                    selectedWidgetID = newWidget.id
                },
                onCancel: {
                    isAddingWidget = false
                }
            )
            .frame(width: 400, height: 350)
            .padding()
        }
        .sheet(isPresented: $isEditingWidget) {
            if let index = editingWidgetIndex, index < tab.widgets.count {
                WidgetEditorView(
                    widgetType: $newWidgetType,
                    xPosition: $newWidgetXPosition,
                    yPosition: $newWidgetYPosition,
                    colSpan: $newWidgetColSpan,
                    rowSpan: $newWidgetRowSpan,
                    maxRows: tab.rowCount,
                    maxCols: tab.colCount,
                    onSave: {
                        tab.widgets[index].xPosition = newWidgetXPosition
                        tab.widgets[index].yPosition = newWidgetYPosition
                        tab.widgets[index].colSpan = newWidgetColSpan
                        tab.widgets[index].rowSpan = newWidgetRowSpan
                        isEditingWidget = false
                    },
                    onCancel: {
                        isEditingWidget = false
                    }
                )
                .frame(width: 400, height: 350)
                .padding()
            }
        }
    }
}

// A view to show the grid background for tab editor
struct GridBackgroundView: View {
    let rowCount: Int
    let colCount: Int
    
    var body: some View {
        VStack(spacing: 4) {
            ForEach(0..<rowCount, id: \.self) { row in
                HStack(spacing: 4) {
                    ForEach(0..<colCount, id: \.self) { col in
                        Rectangle()
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            .background(Color.gray.opacity(0.1))
                            .frame(width: 60, height: 60)
                    }
                }
            }
        }
    }
}

// A preview of a widget in the editor
struct WidgetPreview: View {
    @ObservedObject var widget: WidgetModel
    let isSelected: Bool
    let onClick: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(widgetColor(for: widget.type))
                .frame(
                    width: widget.colSpan * 60 + (widget.colSpan - 1) * 4,
                    height: widget.rowSpan * 60 + (widget.rowSpan - 1) * 4
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.white : Color.clear, lineWidth: 2)
                )
            
            VStack {
                Image(systemName: widget.type.defaultIcon)
                    .font(.system(size: 16))
                
                Text(widget.type.displayName)
                    .font(.caption)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .foregroundColor(.white)
        }
        .onTapGesture {
            onClick()
        }
    }
    
    func widgetColor(for type: WidgetType) -> Color {
        switch type {
        case .airDrop:
            return Color.blue
        case .trayDrop:
            return Color.green
        case .placeholder:
            return Color.orange
        case .settings:
            return Color.purple
        case .menuItem:
            return Color.pink
        }
    }
}

// Editor for widget properties
struct WidgetEditorView: View {
    @Binding var widgetType: WidgetType
    @Binding var xPosition: CGFloat
    @Binding var yPosition: CGFloat
    @Binding var colSpan: CGFloat
    @Binding var rowSpan: CGFloat
    let maxRows: Int
    let maxCols: Int
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Widget Properties")
                .font(.headline)
                .padding(.top)
            
            Form {
                Section {
                    Picker("Widget Type", selection: $widgetType) {
                        ForEach(WidgetType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.defaultIcon)
                                Text(type.displayName)
                            }
                            .tag(type)
                        }
                    }
                } header: {
                    Text("Type")
                }
                
                Section {
                    Stepper("X Position: \(Int(xPosition))", value: Binding(
                        get: { self.xPosition },
                        set: { self.xPosition = min(CGFloat(maxCols - Int(colSpan)), max(0, $0)) }
                    ), in: 0...CGFloat(maxCols - 1))
                    
                    Stepper("Y Position: \(Int(yPosition))", value: Binding(
                        get: { self.yPosition },
                        set: { self.yPosition = min(CGFloat(maxRows - Int(rowSpan)), max(0, $0)) }
                    ), in: 0...CGFloat(maxRows - 1))
                    
                    Stepper("Width: \(Int(colSpan))", value: Binding(
                        get: { self.colSpan },
                        set: {
                            self.colSpan = min(CGFloat(maxCols) - xPosition, max(1, $0))
                        }
                    ), in: 1...CGFloat(maxCols))
                    
                    Stepper("Height: \(Int(rowSpan))", value: Binding(
                        get: { self.rowSpan },
                        set: {
                            self.rowSpan = min(CGFloat(maxRows) - yPosition, max(1, $0))
                        }
                    ), in: 1...CGFloat(maxRows))
                } header: {
                    Text("Position & Size")
                }
            }
            
            Spacer()
            
            HStack {
                Button("Cancel") {
                    onCancel()
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                Button("Save") {
                    onSave()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding([.horizontal, .bottom])
        }
    }
}

#Preview {
    TabManagerView(vm: NotchViewModel())
        .frame(width: 600, height: 400)
        .preferredColorScheme(.dark)
}
