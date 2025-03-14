//
//  Cell.swift
//  NotchDrop
//
//  Created by Bindo Thorpe on 14/03/2025.
//

import SwiftUI

struct Cell<Leading: View, Trailing: View>: View {
    var leading: Leading
    var trailing: Trailing
    
    var body: some View {
        HStack {
            leading
            Spacer()
            trailing.foregroundColor(.secondary)
        }
    }
    
    init(@ViewBuilder leading: () -> Leading, @ViewBuilder trailing: () -> Trailing) {
        self.leading = leading()
        self.trailing = trailing()
    }
}

// Example usage:
// Cell {
//     Text("Title")
// } trailing: {
//     Text("Detail")
// }

// For convenience, you can also add this initializer for the common Text case:
extension Cell where Leading == Text, Trailing == Text {
    init(leading: String, trailing: String) {
        self.leading = Text(leading)
        self.trailing = Text(trailing)
    }
}
