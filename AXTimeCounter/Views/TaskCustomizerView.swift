//
//  TaskCustomizerView.swift
//  AXTimeCounter
//
//  Created by Ashwin Paudel on 2024-03-17.
//

import SwiftUI

struct TaskCustomizerView: View {
    @State private var selectedTask: Task?
    @State private var newName = ""
    @State private var newColor = Color.red // Default color
    
    @Environment(AXAppData.self) private var appData

    var body: some View {
        HStack {
            // Table view of tasks
            List {
                ForEach(appData.tasks) { task in
                    HStack {
                        Button(action: {
                            selectedTask = task
                            newName = task.name
                            newColor = task.color
                        }) {
                            ZStack(alignment: .leading) {
                                task.color.opacity(task != selectedTask ? 0.1 : 1)
                                HStack {
                                    Text(task.name)
                                        .fontWeight(.semibold)
                                    Spacer()
                                }
                                .padding()
                            }
                            .clipShape(
                                RoundedRectangle(cornerRadius: 10)
                            )
                        }
                        .buttonStyle(.borderless)
                        
                        Image(systemName: "line.3.horizontal")
                    }
                }
                .onDelete(perform: deleteTask)
                .onMove(perform: moveTask)
            }
            .listStyle(PlainListStyle())
            .frame(minWidth: 350)
            
            // Form to edit task
            if selectedTask != nil {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Name")
                    TextField("Enter name", text: $newName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: newName) {
                            updateTask()
                        }
                    
                    Text("Color")
                    HStack {
                        ForEach([Color.red, .green, .blue, .yellow], id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 30, height: 30)
                                .onTapGesture {
                                    newColor = color
                                    updateTask()
                                }
                        }
                    }
                }
                .padding()
            } else {
                Text("Select a task to edit")
                    .padding()
            }
        }
        .navigationTitle("Tasks")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: addTask) {
                    Label("Add", systemImage: "plus")
                }
            }
            
            ToolbarItem(placement: .destructiveAction) {
                Button(action: deleteTask) {
                    Label("Delete", systemImage: "trash")
                }
                .foregroundStyle(.red)
            }
        }
    }
    
    func updateTask() {
        guard let task = selectedTask else { return }
        if let index = appData.tasks.firstIndex(where: { $0.id == task.id }) {
            appData.tasks[index].name = newName
            appData.tasks[index].color = newColor
        }
    }
    
    func deleteTask() {
        if let selectedTask = selectedTask, let index = appData.tasks.firstIndex(where: { $0.id == selectedTask.id }) {
            appData.tasks.remove(at: index)
            self.selectedTask = nil
        }
    }
    
    func deleteTask(at offsets: IndexSet) {
        appData.tasks.remove(atOffsets: offsets)
        selectedTask = nil
    }
    
    func moveTask(from source: IndexSet, to destination: Int) {
        appData.tasks.move(fromOffsets: source, toOffset: destination)
    }
    
    func addTask() {
        let newTask = Task(name: "New Task", color: .gray)
        appData.tasks.append(newTask)
    }
}

#Preview {
    TaskCustomizerView()
        .environment(AXAppData())
}
