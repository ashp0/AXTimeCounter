//
//  AXAppData.swift
//  AXTimeCounter
//
//  Created by Ashwin Paudel on 2024-03-17.
//

import Foundation
import AppKit
import SwiftUI

@Observable
class AXAppData {
    var tasks = [Task]()
    var currentTask: Task?
    
    var currentTimer: Timer?
    
    var lastMovedMouse: Date?
    var idleTimer: Timer?
    var mouseMonitorEvent: Any?
    
    private var reader: FileReader
    
    init() {
        self.reader = FileReader("A(x)TimeCounter")
        print(reader.readFile())
        let items = decode()
        print(items)
        tasks = items
    }
    
    func decode() -> [Task] {
        let jsonDecoder = JSONDecoder()
        guard let decodedTasks = try? jsonDecoder.decode([Task].self, from: reader.fileContents.data(using: .utf8)!) else {
            return []
        }
        
        return decodedTasks
    }
    
    func encode() {
        let jsonEncoder = JSONEncoder()
        
        do {
            let jsonResultData = try jsonEncoder.encode(tasks)
            reader.writeFile(text: String(data: jsonResultData, encoding: .utf8)!)
        } catch {
            print("Unable to encode JSON: AXAppData. \(error.localizedDescription)")
        }
    }
    
    func startTimer(for task: Task) {
        currentTask = task
        currentTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.currentTask!.updateLatestSession(1) // 1 second
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [unowned self] in
            self.startIdleTimer()
        }
    }
    
    func stopTimer() {
        currentTimer?.invalidate()
        currentTimer = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [unowned self] in
            self.stopIdleTimer()
        }
        
        encode()
    }
    
    func stopIdleTimer() {
        self.idleTimer?.invalidate()
        self.idleTimer = nil
        
        if let event = self.mouseMonitorEvent {
            NSEvent.removeMonitor(event)
        }
        
        
        self.mouseMonitorEvent = nil
    }
    
    func startIdleTimer() {
        self.idleTimer = Timer.scheduledTimer(withTimeInterval: 5 * 60, repeats: true) { _ in
            if let lastMovedMouse = self.lastMovedMouse {
                let elapsedTime = Date().timeIntervalSince(lastMovedMouse)
                print("Time", elapsedTime)
                if elapsedTime >= 5 * 60 {
                    print("Show PopupView")
                    self.showInactivePopup()
                }
            }
        }
        
        mouseMonitorEvent = NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved, .keyDown]) { event in
            self.lastMovedMouse = Date()
#if DEBUG
            print("Mouse Moused \(UUID())")
#endif
        }
    }
    
    func showInactivePopup() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [unowned self] in
            self.stopIdleTimer()
        }
        
        let previousTime = self.currentTask!.getLatestSession().time
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 150),
            styleMask: [.titled, .closable],
            backing: .buffered, defer: false)
        
        let contentView = IdleTimerPopupView(window: window, stopTimerAction: {
            self.currentTask!.modifyLatestSession(previousTime)
            self.stopTimer()
        }, keepTimerAction: {
            self.lastMovedMouse = Date()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [unowned self] in
                self.startIdleTimer()
            }
        })
        
        window.title = "Inactive"
        window.titlebarAppearsTransparent = true
        window.center()
        window.contentView = NSHostingView(rootView: contentView)
        
        NSApplication.show(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
        window.isReleasedWhenClosed = true
    }
}


// We are going to be reading from a specific file in the user's documents folder. It will follow a JSON format.
private class FileReader {
    let fileName: String
    var fileContents: String = ""
    private let fileURL: URL
    
    init(_ file: String) {
        self.fileName = file
        
        // Read from documents directory
        let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        guard let fileURL = dir?.appendingPathComponent(fileName).appendingPathExtension("txt") else {
            fatalError("Not able to create URL")
        }
        self.fileURL = fileURL
        print(fileURL)
        
        // Check if the file exists, if not, create a new blank file
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                // Create an empty file at the specified URL
                try "".write(to: fileURL, atomically: true, encoding: .utf8)
            } catch {
                fatalError("Unable to create file at \(fileURL)")
            }
        }
    }
    
    func readFile() {
        do {
            fileContents = try String(contentsOf: fileURL)
        } catch {
            print("[FileReader]: Unable to read file at \(fileURL) || Error: \(error.localizedDescription)")
        }
    }
    
    func writeFile(text: String) {
        do {
            try text.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("[FileReader]: Unable to write to file at \(fileURL) || Error: \(error.localizedDescription)")
        }
    }
}
