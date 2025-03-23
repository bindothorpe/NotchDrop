//
//  TabDetailView.swift
//  NotchDrop
//
//  Created by Bindo Thorpe on 23/03/2025.
//

import SwiftUI

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
        List {
            // Tab Properties Section
            Section {
                VStack(spacing: 16) {
                    VStack(spacing: 12) {
                        SettingRow(label: "Tab Title:") {
                            TextField("", text: $tabTitle)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        SettingRow(label: "Icon:") {
                            HStack(alignment: .top) {
                                TextField("", text: $tabIcon)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(maxWidth: .infinity)
                                
                                if !tabIcon.isEmpty {
                                    Image(systemName: tabIcon)
                                        .font(.system(size: 20))
                                        .frame(width: 24, height: 20)
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                    }
                    
                    Divider().padding(.vertical, 8)
                    
                    // Grid Size
                    VStack(spacing: 12) {
                        SettingRow(label: "Grid Size:") {
                            HStack {
                                Stepper("Rows: \(tab.rowCount)", value: Binding(
                                    get: { self.tab.rowCount },
                                    set: { self.tab.rowCount = max(1, $0) }
                                ), in: 1...10)
                            }
                        }
                        
                        SettingRow(label: "") {
                            HStack {
                                Stepper("Columns: \(tab.colCount)", value: Binding(
                                    get: { self.tab.colCount },
                                    set: { self.tab.colCount = max(1, $0) }
                                ), in: 1...10)
                            }
                        }
                    }
                }
            }.insetGroupedStyle(header: VStack(alignment: .leading) {
                Text("Tab Properties").font(.title)
            })
            
            // Widgets Section
            Section {
                VStack(spacing: 12) {
                    // Widget Grid
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
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(8)
                    .padding(.vertical, 8)
                    
                    // Widget Controls
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
                    .padding(.vertical, 8)
                }
            }.insetGroupedStyle(header: VStack(alignment: .leading) {
                Text("Widgets").font(.title)
            }).padding([.bottom], 60)
            
        }
        .overlay(alignment: .bottom) {
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
            .background(
                Rectangle()
                    .fill(Color(NSColor.windowBackgroundColor))
                    .shadow(radius: 2, y: -1)
            )
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
            .padding()
            .fixedSize(horizontal: false, vertical: true)
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
                .padding()
                .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @StateObject private var vm = NotchViewModel()
        @State private var tabTitle = "Test Tab"
        @State private var tabIcon = "star.fill"
        
        var body: some View {
            if let tab = vm.tabs.first {
                TabDetailView(
                    vm: vm,
                    tab: tab,
                    tabTitle: $tabTitle,
                    tabIcon: $tabIcon,
                    commonIcons: ["star.fill", "heart.fill", "house.fill"],
                    onSave: {},
                    onCancel: {}
                )
            } else {
                Text("No tab available")
            }
        }
    }
    
    return PreviewWrapper()
        .preferredColorScheme(.dark)
}
