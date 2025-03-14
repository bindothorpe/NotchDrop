//
//  NotchSettingsView.swift
//  NotchDrop
//
//  Created by 曹丁杰 on 2024/7/29.
//

import LaunchAtLogin
import SwiftUI

struct NotchSettingsView: View {
    @StateObject var vm: NotchViewModel
    @StateObject var tvm: TrayDrop = .shared
    
    // Computed property to create a binding for just the width
    private var notchWidthBinding: Binding<Double> {
        Binding<Double>(
            get: { Double(vm.notchOpenedSize.width) },
            set: { newWidth in
                vm.notchOpenedSize = CGSize(
                    width: newWidth,
                    height: vm.notchOpenedSize.height
                )
            }
        )
    }

    var body: some View {
        VStack(spacing: vm.spacing) {
            HStack {
                Picker("Language: ", selection: $vm.selectedLanguage) {
                    ForEach(Language.allCases) { language in
                        Text(language.localized).tag(language)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: vm.selectedLanguage == .simplifiedChinese || vm.selectedLanguage == .traditionalChinese ? 220 : 160)

                Spacer()
                LaunchAtLogin.Toggle {
                    Text(NSLocalizedString("Launch at Login", comment: ""))
                }

                Spacer()
                Toggle("Haptic Feedback ", isOn: $vm.hapticFeedback)

                Spacer()
            }
            
            // New row for notch width slider
            HStack {
                Spacer()
                
                Text("Notch Width: ")
                
                Slider(
                    value: notchWidthBinding,
                    in: 400...1200,
                    step: 50
                )
                .frame(width: 300)
                
                Text("\(Int(vm.notchOpenedSize.width))px")
                    .frame(width: 70, alignment: .trailing)
                
                Spacer()
            }

            HStack {
                Text("File Storage Time: ")
                Picker(String(), selection: $tvm.selectedFileStorageTime) {
                    ForEach(TrayDrop.FileStorageTime.allCases) { time in
                        Text(time.localized).tag(time)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 100)
                if tvm.selectedFileStorageTime == .custom {
                    TextField("Days", value: $tvm.customStorageTime, formatter: NumberFormatter())
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 50)
                        .padding(.leading, 10)
                    Picker("Time Unit", selection: $tvm.customStorageTimeUnit) {
                        ForEach(TrayDrop.CustomstorageTimeUnit.allCases) { unit in
                            Text(unit.localized).tag(unit)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 200)
                }
                Spacer()
            }
        }
        .padding()
        .transition(.scale(scale: 0.8).combined(with: .opacity))
        .onAppear {
            vm.sizeManager.registerTab(type: .settings, rowCount: 3, colCount: 1)
            vm.sizeManager.updateNotchSize(for: .settings)
        }
    }
}

#Preview {
    NotchSettingsView(vm: .init())
        .padding()
        .frame(width: 600, height: 180, alignment: .center) // Increased height for new slider
        .background(.black)
        .preferredColorScheme(.dark)
}
