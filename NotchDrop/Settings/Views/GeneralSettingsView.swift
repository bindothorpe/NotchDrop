//
//  GeneralSettingsView.swift
//  NotchDrop
//
//  Created by Bindo Thorpe on 14/03/2025.
//


// GeneralSettingsView.swift
import SwiftUI
import LaunchAtLogin

struct GeneralSettingsView: View {
    @AppStorage("showInMenuBar") private var showInMenuBar = true
    
    
    var body: some View {
        List {
            Section {
                Cell(leading: { Text("Show in menu bar") }, trailing: { Toggle("",isOn: $showInMenuBar) })
            }.insetGroupedStyle(header: VStack(alignment: .leading) {
                Text("General Settings").font(.largeTitle)
                Text("Menu Bar").padding(.top)
            })
        }
    }
}
