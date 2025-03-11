//
//  WidgetWrapper.swift
//  NotchDrop
//
//  Created by Bindo Thorpe on 11/03/2025.
//

import SwiftUI

struct WidgetWrapper<Content: View>: View, NotchSizeProvider {
    @StateObject var vm: NotchViewModel
    
    let colSpan: CGFloat
    let rowSpan: CGFloat
    let content: Content
    
    // Initializer with a content builder
    init(
        vm: NotchViewModel,
        colSpan: CGFloat = 1.0,
        rowSpan: CGFloat = 1.0,
        @ViewBuilder content: () -> Content
    ) {
        self._vm = StateObject(wrappedValue: vm)
        self.colSpan = colSpan
        self.rowSpan = rowSpan
        self.content = content()
    }
    
    var body: some View {
        content
            .frame(width: vm.cellSize * colSpan + (max(0, (colSpan - 1) * vm.spacing)),
                   height: vm.cellSize * rowSpan + (max(0, (rowSpan - 1) * vm.spacing)))
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
