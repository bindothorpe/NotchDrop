//
//  WidgetPreview.swift
//  NotchDrop
//
//  Created by Bindo Thorpe on 23/03/2025.
//

import SwiftUI

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

#Preview {
    let widget = WidgetModel(
        type: .placeholder,
        xPosition: 0,
        yPosition: 0,
        colSpan: 1,
        rowSpan: 1
    )
    
    return WidgetPreview(
        widget: widget,
        isSelected: true,
        onClick: {}
    )
    .padding(50)
    .preferredColorScheme(.dark)
}
