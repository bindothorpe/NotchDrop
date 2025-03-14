//
//  AppearanceSettingsView.swift
//  NotchDrop
//
//  Created by Bindo Thorpe on 14/03/2025.
//


// AppearanceSettingsView.swift
import SwiftUI

struct AppearanceSettingsView: View {
    @AppStorage("translucentNotchBackground") private var translucentNotchBackground = true
    
    var body: some View {
        List {
            Section {
                Cell(leading: {
                    Text("Translucent notch background")
                }, trailing: {
                    Toggle("", isOn: $translucentNotchBackground)
                })
            }.insetGroupedStyle(header: VStack(alignment: .leading) {
                Text("Appearance Settings").font(.largeTitle)
                Text("Notch").padding(.top)
            })
        }
    }
}
