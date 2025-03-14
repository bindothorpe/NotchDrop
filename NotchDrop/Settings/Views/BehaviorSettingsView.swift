//
//  BehaviorSettingsView.swift
//  NotchDrop
//
//  Created by Bindo Thorpe on 14/03/2025.
//


// BehaviorSettingsView.swift
import SwiftUI

struct BehaviorSettingsView: View {
    @AppStorage("autoOpenOnHover") private var autoOpenOnHover = true
    
    var body: some View {
        List {
            Section {
                Cell(leading: {
                    Text("Open on hover")
                }, trailing: {
                    Toggle("", isOn: $autoOpenOnHover)
                })
            }.insetGroupedStyle(header: VStack(alignment: .leading) {
                Text("Behavior Settings").font(.largeTitle)
                Text("Notch").padding(.top)
            })
        }
    }
}
