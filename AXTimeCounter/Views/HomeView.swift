//
//  HomeView.swift
//  AXTimeCounter
//
//  Created by Ashwin Paudel on 2024-03-17.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.openWindow) var openWindow
    
    @Environment(AXAppData.self) private var appData
    
    var body: some View {
        List {
            HStack {
                Text("Tasks")
                    .font(.title)
                    .bold()
                
                Spacer()
                
                Button(action: {
                    NSApplication.shared.activate(ignoringOtherApps: true)
                    openWindow(id: "info-window")
                    NSApplication.show()
                }) {
                    Image(systemName: "clock")
                }
                .buttonStyle(.borderless)
            }
            ForEach(appData.tasks) { task in
                AXTaskItemView(task: task)
                    .padding(.vertical, 10.0)
            }
        }
        .scrollIndicators(.never)
        .listStyle(.sidebar)
        .frame(maxWidth: 275)
    }
}

#Preview {
    HomeView()
}
