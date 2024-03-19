//
//  IdleTimerPopupView.swift
//  AXTimeCounter
//
//  Created by Ashwin Paudel on 2024-03-18.
//

import SwiftUI

struct IdleTimerPopupView: View {
    @Environment(\.controlActiveState) private var controlActiveState
    @State var disableAllComms = false
    
    var window: NSWindow
    var stopTimerAction: () -> Void
    var keepTimerAction: () -> Void
    
    var body: some View {
        VStack {
            Text("You have been inactive.")
                .font(.title2)
            Text("Would you like to stop the timer?")
            Text("Leaving this window will keep the timer running :)")
                .font(.caption)
            
            HStack {
                Button("Stop Timer") {
                    disableAllComms = true
                    window.close()
                    stopTimerAction()
                }
                Button("Keep Timer") {
                    disableAllComms = true
                    window.close()
                    keepTimerAction()
                }
            }
        }
        .padding()
        .frame(width: 300, height: 150)
        .cornerRadius(10)
        .shadow(radius: 5)
        .onChange(of: controlActiveState) { _, newValue in
            switch newValue {
            case .key, .active:
                break
            case .inactive:
                if !disableAllComms {
                    window.close()
                    keepTimerAction()
                }
                
            @unknown default:
                break
            }
        }
    }
}
