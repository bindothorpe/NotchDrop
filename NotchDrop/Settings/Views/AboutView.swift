//
//  AboutView.swift
//  NotchDrop
//
//  Created by Bindo Thorpe on 14/03/2025.
//


// AboutView.swift
import SwiftUI

struct AboutView: View {
    var body: some View {
        
        
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
                ApplicationUtilities.shared.openWebsite()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
