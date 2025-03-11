//
//  SettingsView.swift
//  NotchDrop
//
//  Created by Bindo Thorpe on 11/03/2025.
//

import SwiftUI
import LaunchAtLogin

struct SettingsView: View {
    @State private var selectedTab = 0
    @AppStorage("showInMenuBar") private var showInMenuBar = true
    @AppStorage("autoOpenOnHover") private var autoOpenOnHover = true
    @AppStorage("hoverDelay") private var hoverDelay = 0.5
    @AppStorage("autoCloseAfterInactivity") private var autoCloseAfterInactivity = true
    @AppStorage("autoCloseTimeout") private var autoCloseTimeout = 5.0
    @State private var accentColor = Color.blue
    @AppStorage("iconSize") private var iconSize = 24.0
    @AppStorage("themePreference") private var themePreference = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // General Tab
            Form {
                Section {
                    LaunchAtLogin.Toggle("Launch at login")
                    Toggle("Show in menu bar", isOn: $showInMenuBar)
                }
                
                Button("Restart Application") {
                    restartApplication()
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.top)
            }
            .tabItem {
                Label("General", systemImage: "gear")
            }
            .tag(0)
            
            // Appearance Tab
            Form {
                Section {
                    Picker("Theme", selection: $themePreference) {
                        Text("System").tag(0)
                        Text("Light").tag(1)
                        Text("Dark").tag(2)
                    }
                    .pickerStyle(.menu)
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Icon Size:")
                            Spacer()
                            Text("\(Int(iconSize))px")
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $iconSize, in: 16...48, step: 1)
                    }
                    
                    ColorPicker("Accent Color", selection: $accentColor)
                }
            }
            .tabItem {
                Label("Appearance", systemImage: "paintbrush")
            }
            .tag(1)
            
            // Behavior Tab
            Form {
                Section {
                    Toggle("Automatically open on hover", isOn: $autoOpenOnHover)
                    
                    if autoOpenOnHover {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Hover delay:")
                                Spacer()
                                Text("\(hoverDelay, specifier: "%.1f")s")
                                    .foregroundColor(.secondary)
                            }
                            Slider(value: $hoverDelay, in: 0...2, step: 0.1)
                        }
                        .padding(.leading)
                    }
                    
                    Toggle("Automatically close after inactivity", isOn: $autoCloseAfterInactivity)
                    
                    if autoCloseAfterInactivity {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Close after:")
                                Spacer()
                                Text("\(Int(autoCloseTimeout))s")
                                    .foregroundColor(.secondary)
                            }
                            Slider(value: $autoCloseTimeout, in: 1...30, step: 1)
                        }
                        .padding(.leading)
                    }
                }
            }
            .tabItem {
                Label("Behavior", systemImage: "hand.tap")
            }
            .tag(2)
            
            // About Tab
            VStack(spacing: 20) {
                Image(nsImage: NSApp.applicationIconImage ?? NSImage())
                    .resizable()
                    .frame(width: 128, height: 128)
                
                Text("NotchDrop")
                    .font(.title)
                    .bold()
                
                Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
                    .foregroundColor(.secondary)
                
                Text("© 2024 NotchDrop Developer")
                    .foregroundColor(.secondary)
                
                Button("Visit Website") {
                    openWebsite()
                }
                .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .tabItem {
                Label("About", systemImage: "info.circle")
            }
            .tag(3)
        }
        .padding()
        .frame(width: 500, height: 400)
    }
    
    private func restartApplication() {
        let alert = NSAlert()
        alert.messageText = "Restart Application"
        alert.informativeText = "Do you want to restart NotchDrop now?"
        alert.addButton(withTitle: "Restart")
        alert.addButton(withTitle: "Cancel")
        
        if alert.runModal() == .alertFirstButtonReturn {
            let bundleID = Bundle.main.bundleIdentifier!
            
            let task = Process()
            task.launchPath = "/usr/bin/open"
            task.arguments = ["-b", bundleID, "-n"]
            
            try? task.run()
            NSApp.terminate(nil)
        }
    }
    
    private func openWebsite() {
        if let url = URL(string: "https://example.com") {
            NSWorkspace.shared.open(url)
        }
    }
}
