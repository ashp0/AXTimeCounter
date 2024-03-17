//
//  AXAppData.swift
//  AXTimeCounter
//
//  Created by Ashwin Paudel on 2024-03-17.
//

import Foundation

@Observable
class AXAppData {
    var tasks = [Task]()
    var currentTask: Task?
    var currentTimer: Timer?
    
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
    }
    
    func stopTimer() {
        currentTimer?.invalidate()
        currentTimer = nil
        
        encode()
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
