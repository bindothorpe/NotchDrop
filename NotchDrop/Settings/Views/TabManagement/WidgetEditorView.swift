//
//  WidgetEditorView.swift
//  NotchDrop
//
//  Created by Bindo Thorpe on 23/03/2025.
//

import SwiftUI

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
    struct PreviewWrapper: View {
        @State private var widgetType: WidgetType = .placeholder
        @State private var xPosition: CGFloat = 1
        @State private var yPosition: CGFloat = 1
        @State private var colSpan: CGFloat = 2
        @State private var rowSpan: CGFloat = 1
        
        var body: some View {
            WidgetEditorView(
                widgetType: $widgetType,
                xPosition: $xPosition,
                yPosition: $yPosition,
                colSpan: $colSpan,
                rowSpan: $rowSpan,
                maxRows: 5,
                maxCols: 5,
                onSave: {},
                onCancel: {}
            )
        }
    }
    
    return PreviewWrapper()
        .frame(width: 400, height: 350)
        .preferredColorScheme(.dark)
}
