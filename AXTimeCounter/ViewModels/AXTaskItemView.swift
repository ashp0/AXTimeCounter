//
//  AXTaskItemView.swift
//  AXTimeCounter
//
//  Created by Ashwin Paudel on 2024-03-17.
//

import SwiftUI

struct AXTaskItemView: View {
    @Bindable var task: Task
    @State private var isPaused: Bool = true
    @Environment(AXAppData.self) private var appData
    
    var body: some View {
        ZStack(alignment: .leading) {
            task.color.opacity(0.3)
            HStack {
                AXStartStopButton(isPaused: $isPaused, backgroundColor: task.color, action: {
                    if !isPaused { // The isPaused variable is triggered already. So we inverse.
                        appData.stopTimer()
                        appData.startTimer(for: task)
                    } else {
                        appData.stopTimer()
                        print("Stopped Timer")
                    }
                })
                
                Text(task.name)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if isPaused {
                    Text("\(timeString(time: task.getLatestSession().time))")
                        .padding(.trailing)
                        .foregroundStyle(.gray)
                } else {
                    Text("Active")
                        .padding(.trailing)
                        .foregroundStyle(.gray)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(isPaused ? Color.clear : task.color, lineWidth: 2)
            )
        }
        .clipShape(
            RoundedRectangle(cornerRadius: 10)
        )
        .frame(maxWidth: 250, maxHeight: 30)
        .opacity(isPaused ? 0.3 : 1)
    }
    
    private func timeString(time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
    }
}

#Preview {
    AXTaskItemView(task: .init(name: "Math", color: .red))
}
