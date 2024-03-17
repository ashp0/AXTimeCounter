//
//  AXTimeCounterApp.swift
//  AXTimeCounter
//
//  Created by Ashwin Paudel on 2024-03-17.
//

import SwiftUI
import Observation

@main
struct AXTimeCounterApp: App {
    @State var appData = AXAppData()
    
    var body: some Scene {
        // Menu Bar
        MenuBarExtra {
            HomeView()
                .environment(appData)
        } label: {
            Text("| \((appData.currentTask != nil) ? appData.currentTask!.name : "A(x)") |")
        }
        .menuBarExtraStyle(.window)
        
        
        Window("InformationView", id: "info-window") {
            InfoView()
                .environment(appData)
        }
        
    }
}

extension NSApplication {
    static func show(ignoringOtherApps: Bool = true) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: ignoringOtherApps)
    }
    
    static func hide() {
        NSApp.hide(self)
        NSApp.setActivationPolicy(.accessory)
    }
}
