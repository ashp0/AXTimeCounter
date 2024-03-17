//
//  StatisticsView.swift
//  AXTimeCounter
//
//  Created by Ashwin Paudel on 2024-03-17.
//

import SwiftUI
import Charts

struct StatisticsView: View {
    @Environment(AXAppData.self) private var appData
    @State var selectedDate: String? = nil
    @State private var showingPopover = false
    
    
    let daysToShow: Int = 7 // Change this value to adjust the number of days to show
    
    var body: some View {
        VStack {
            Text("Weekly Task Sessions")
                .font(.title)
                .padding()
            
            Chart {
                let currentDate = Date()
                let calendar = Calendar.current
                let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate))!
                
                ForEach(0..<daysToShow, id: \.self) { i in
                    let date = calendar.date(byAdding: .day, value: i, to: startOfWeek)!
                    let shortDate = date.shortDateString()
                    
                    ForEach(appData.tasks) { task in
                        if let session = task.getSession(at: shortDate) {
                            BarMark(
                                x: .value("Date", shortDate),
                                y: .value("Seconds", session.time)
                                
                            )
                            .foregroundStyle(task.color)
                        } else {
                            BarMark(
                                x: .value("Date", shortDate),
                                y: .value("Seconds", 0)
                            )
                        }
                    }
                }
            }
            .chartXSelection(value: $selectedDate)
            .popover(isPresented: $showingPopover) {
                if let selectedDate = selectedDate {
                    List(appData.tasks) { task in
                        if let session = task.getSession(at: selectedDate) {
                            Text("\(task.name): \(session.time)")
                        }
                    }
                }
            }
            .onChange(of: selectedDate) {
                if let selectedDate = selectedDate {
                    for task in appData.tasks {
                        if task.getSession(at: selectedDate) != nil {
                            showingPopover = true
                            return
                        } else {
                            showingPopover = false
                        }
                    }
                } else {
                    showingPopover = false
                }
            }
        }
        .padding()
        .navigationTitle("Statistics")
    }
}



fileprivate extension Date {
    func shortDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: self)
    }
}


#Preview {
    StatisticsView()
}
