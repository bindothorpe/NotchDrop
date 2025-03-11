//
//  PlaceholderView.swift
//  NotchDrop
//
//  Created by Bindo Thorpe on 10/03/2025.
//

import SwiftUI

// Widget
struct PlaceholderView: View, NotchSizeProvider {
    @StateObject var vm: NotchViewModel
    
    let label: String
    let colSpan: CGFloat
    let rowSpan: CGFloat
    let backgroundColor: Color
    
    var body: some View {
        Text("\(label) \(colSpan, specifier: "%.0f")x\(rowSpan, specifier: "%.0f")")
            .frame(width: vm.cellSize * colSpan + (max(0, (colSpan - 1) * vm.spacing)), height: vm.cellSize * rowSpan + (max(0, (rowSpan - 1) * vm.spacing)))
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: vm.cornerRadius))
            .onAppear {
                // Register this widget with the size manager
                vm.sizeManager.registerWidget(self, for: vm.contentType)
            }
    }
    
    // Implement NotchSizeProvider
    func getColSpan() -> CGFloat {
        return colSpan
    }
    
    func getRowSpan() -> CGFloat {
        return rowSpan
    }
}
