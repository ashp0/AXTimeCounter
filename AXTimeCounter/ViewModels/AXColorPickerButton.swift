//
//  AXColorPickerButton.swift
//  AXTimeCounter
//
//  Created by Ashwin Paudel on 2024-03-19.
//

import SwiftUI

struct AXColorPickerButton: View {
    @Binding var selectedColor: Color
    var color: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            self.selectedColor = self.color
            action()
        }) {
            Image(systemName: self.selectedColor == color ? "checkmark.circle.fill" : "circle.fill")
        }
        .tint(self.color)
        .buttonStyle(.borderless)
    }
}

#Preview {
    AXColorPickerButton(selectedColor: .constant(.yellow), color: .red, action: {})
}
