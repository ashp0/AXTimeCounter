//
//  AXStartStopButton.swift
//  AXTimeCounter
//
//  Created by Ashwin Paudel on 2024-03-17.
//

import SwiftUI

struct AXStartStopButton: View {
    @Binding var isPaused: Bool
    var backgroundColor: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            withAnimation {
                self.isPaused.toggle()
            }
            
            action()
        }) {
            ZStack {
                backgroundColor
                    .opacity(isPaused ? 0.3 : 0.6)
                    .cornerRadius(8)
                Image(systemName: isPaused ? "play.circle.fill" : "pause.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
                    .foregroundColor((backgroundColor))
                    .padding(12)
            }
        }
        .buttonStyle(.borderless)
        .frame(width: 50, height: 50)
    }
}

#Preview {
    AXStartStopButton(isPaused: .constant(true), backgroundColor: .red, action: {
        print("hello")
    })
        .padding()
}
