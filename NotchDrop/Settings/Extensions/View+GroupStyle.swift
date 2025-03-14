//
//  View+GroupStyle.swift
//  NotchDrop
//
//  Created by Bindo Thorpe on 14/03/2025.
//

import SwiftUI

extension View {
    func insetGroupedStyle<V: View>(header: V) -> some View {
        return GroupBox(label: header.padding(.top).padding(.bottom, 6)) {
            VStack {
                self.padding(.vertical, 3)
            }.padding(.horizontal).padding(.vertical)
        }
    }
}
