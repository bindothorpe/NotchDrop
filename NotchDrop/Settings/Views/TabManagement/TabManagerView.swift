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
                
            }
            header: {
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
                }
            }
            .insetGroupedStyle(header: VStack(alignment: .leading) {
                Text("Tab Settings").font(.largeTitle)
            })
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
            .fixedSize(horizontal: false, vertical: true)
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
                .frame(minWidth: 600, minHeight: 500)
            }
        }
    }
}

#Preview {
    TabManagerView(vm: NotchViewModel())
        .frame(width: 600, height: 400)
        .preferredColorScheme(.dark)
}
