//
//  AXTask.swift
//  AXTimeCounter
//
//  Created by Ashwin Paudel on 2024-03-17.
//

import SwiftUI

@Observable
class Task: Codable, Identifiable, Hashable {
    let id = UUID()
    var name: String
    var color: Color
    var sessions: [Session] = []
    
    init(name: String, color: Color, sessions: [Session] = []) {
        self.name = name
        self.color = color
        self.sessions = sessions
    }
    
    // Computed property to generate sessionsByDate dynamically
    var sessionsByDate: [String: Session] {
        return Dictionary(uniqueKeysWithValues: sessions.map { ($0.date, $0) })
    }
    
    // Function to check if a session exists at a certain date
    func getSession(at date: String) -> Session? {
        return sessionsByDate[date]
    }
    
    // MARK: - Session Management
    func updateLatestSession(_ by: TimeInterval) {
        let latestSession = getLatestSession()
        latestSession.time += by
    }
    
    func modifyLatestSession(_ newTime: TimeInterval) {
        let latestSession = getLatestSession()
        latestSession.time = newTime
    }
    
    func getLatestSession() -> Session {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let todayDateString = dateFormatter.string(from: Date())
        
        if let latestSession = sessions.last, latestSession.date == todayDateString {
            return latestSession
        } else {
            let newSession = Session(date: todayDateString, time: 0)
            sessions.append(newSession)
            
            return newSession
        }
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case name, color, sessions
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        color = try container.decode(Color.self, forKey: .color)
        sessions = try container.decode([Session].self, forKey: .sessions)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(color, forKey: .color)
        try container.encode(sessions, forKey: .sessions)
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // MARK: - Equatable
    static func == (lhs: Task, rhs: Task) -> Bool {
        lhs.id == rhs.id
    }
}

class Session: Codable {
    let date: String
    var time: TimeInterval
    
    public init(date: String, time: TimeInterval) {
        self.date = date
        self.time = time
    }
}

extension Color: Codable {
    enum CodingKeys: String, CodingKey {
        case red, green, blue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let r = try container.decode(Double.self, forKey: .red)
        let g = try container.decode(Double.self, forKey: .green)
        let b = try container.decode(Double.self, forKey: .blue)
        
        self.init(red: r, green: g, blue: b)
    }
    
    public func encode(to encoder: Encoder) throws {
        guard let colorComponents = self.colorComponents else {
            return
        }
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(colorComponents.red, forKey: .red)
        try container.encode(colorComponents.green, forKey: .green)
        try container.encode(colorComponents.blue, forKey: .blue)
    }
}

fileprivate extension Color {
    var colorComponents: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        // I don't understand how this code works, just some error I get when using the
        // `getRed` function.
        if let updatedColorSpace = NSColor(self).usingColorSpace(.sRGB) {
            updatedColorSpace.getRed(&r, green: &g, blue: &b, alpha: &a)
        }
        
        return (r, g, b, a)
    }
}
