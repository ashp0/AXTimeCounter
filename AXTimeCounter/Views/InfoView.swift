//
//  InfoView.swift
//  AXTimeCounter
//
//  Created by Ashwin Paudel on 2024-03-17.
//

import SwiftUI

enum SideBarItem: String, Identifiable, CaseIterable {
    var id: String { rawValue }
    
    case stats
    case tasks
}

struct InfoView: View {
    @State var selectedSideBarItem: SideBarItem = .stats
    @Environment(AXAppData.self) private var appData
    @Environment(\.controlActiveState) private var controlActiveState
    
    var body: some View {
        NavigationSplitView {
            List(SideBarItem.allCases, selection: $selectedSideBarItem) { item in
                NavigationLink(
                    item.rawValue.localizedCapitalized,
                    value: item
                )
            }
        } detail: {
            switch selectedSideBarItem {
            case .stats:
                StatisticsView()
            case .tasks:
                TaskCustomizerView()
            }
        }
        .onChange(of: controlActiveState) { _, newValue in
            switch newValue {
            case .key, .active:
                break
            case .inactive:
                NSApplication.hide()
                appData.encode()
            @unknown default:
                break
            }
        }
    }
}


#Preview {
    InfoView()
}
