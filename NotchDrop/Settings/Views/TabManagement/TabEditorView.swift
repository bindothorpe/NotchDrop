//
//  TabEditorView.swift
//  NotchDrop
//
//  Created by Bindo Thorpe on 23/03/2025.
//

import SwiftUI

// Tab editor for creating or editing a tab
struct TabEditorView: View {
    @Binding var title: String
    @Binding var icon: String
    let commonIcons: [String]
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Form {
                Section {
                    SettingRow(label: "Tab Title:") {
                        TextField("", text: $title)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    SettingRow(label: "Icon:") {
                        HStack(alignment:.top) {
                            TextField("", text: $icon)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(maxWidth: .infinity)
                            
                            if !icon.isEmpty {
                                Image(systemName: icon)
                                    .font(.system(size: 20))
                                    .frame(width: 24, height: 20)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }.insetGroupedStyle(header: VStack(alignment: .leading) {
                    Text("Tab Properties").font(.title).padding(.top)
                })
            }
            
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
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var title = "Tab Title"
        @State private var icon = "star.fill"
        
        var body: some View {
            TabEditorView(
                title: $title,
                icon: $icon,
                commonIcons: ["star.fill", "heart.fill", "house.fill"],
                onSave: {},
                onCancel: {}
            )
        }
    }
    
    return PreviewWrapper()
        .frame(width: 400, height: 300)
        .preferredColorScheme(.dark)
}
