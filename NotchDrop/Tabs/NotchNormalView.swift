//
//  NotchHomeView.swift
//  NotchDrop
//
//  Created by Bindo Thorpe on 10/03/2025.
//

import SwiftUI


//Tab
struct NotchNormalView: View {
    @StateObject var vm: NotchViewModel
    
    var body: some View {
        HStack(spacing: vm.spacing) {
            AirDropView(vm: vm)
            TrayView(vm: vm)
            PlaceholderView(vm: vm, colSpan: 2, rowSpan: 1)
        }
        .onAppear {
            vm.sizeManager.registerTab(type: .normal, rowCount: 1, colCount: 4)
            vm.sizeManager.updateNotchSize(for: .normal)
        }
    }
}
