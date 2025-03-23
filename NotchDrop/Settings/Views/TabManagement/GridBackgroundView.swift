//
//  GridBackgroundView.swift
//  NotchDrop
//
//  Created by Bindo Thorpe on 23/03/2025.
//

import SwiftUI

// A view to show the grid background for tab editor
struct GridBackgroundView: View {
    let rowCount: Int
    let colCount: Int
    
    var body: some View {
        VStack(spacing: 4) {
            ForEach(0..<rowCount, id: \.self) { row in
                HStack(spacing: 4) {
                    ForEach(0..<colCount, id: \.self) { col in
                        Rectangle()
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            .background(Color.gray.opacity(0.1))
                            .frame(width: 60, height: 60)
                    }
                }
            }
        }
    }
}

#Preview {
    GridBackgroundView(rowCount: 3, colCount: 4)
        .padding()
        .background(Color.black.opacity(0.2))
        .cornerRadius(8)
        .padding()
        .preferredColorScheme(.dark)
}
