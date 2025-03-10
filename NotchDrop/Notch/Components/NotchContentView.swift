//
//  NotchContentView.swift
//  NotchDrop
//
//  Created by 秋星桥 on 2024/7/7.
//

import ColorfulX
import SwiftUI
import UniformTypeIdentifiers


// Notch Content
struct NotchContentView: View {
    @StateObject var vm: NotchViewModel

    var body: some View {
        ZStack {
            switch vm.contentType {
            case .normal:
                NotchNormalView(vm: vm)
                .transition(.scale(scale: 0.8).combined(with: .opacity))
                .onAppear {
                    vm.sizeManager.updateNotchSize(for: .normal)
                }
            case .menu:
                NotchMenuView(vm: vm)
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
                    .onAppear {
                        vm.sizeManager.updateNotchSize(for: .menu)
                    }
            case .settings:
                NotchSettingsView(vm: vm)
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
                    .onAppear {
                        vm.sizeManager.updateNotchSize(for: .settings)
                    }
            }
        }
        .animation(vm.animation, value: vm.contentType)
    }
}

#Preview {
    NotchContentView(vm: .init())
        .padding()
        .frame(width: 600, height: 150, alignment: .center)
        .background(.black)
        .preferredColorScheme(.dark)
}
