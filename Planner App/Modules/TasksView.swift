//
//  TasksMiniView.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/23/24.
//
import SwiftUI
import EventKit
import Foundation

class TasksUpdateNotifier: ObservableObject {
    @Published var needsUpdate: Bool = false
}


struct TasksView: View {
    @EnvironmentObject var tasksUpdateNotifier: TasksUpdateNotifier
    @EnvironmentObject var dateHolder: DateHolder
    @State private var tasks: [(task: EKReminder, listColor: Color)] = []
    private let eventStore = EKEventStore()
    @State private var showingAddTaskView = false
    @State private var permissionGranted = false
    @State private var showingAlert = false
    @State private var reminderTitle: String = ""
    @State private var dueDate: Date = Date()
    @State private var showingTaskMenu = false


    
    var body: some View {
        if permissionGranted {
            ZStack {
                ScrollView {
                    LazyVStack {
                        ForEach(tasks, id: \.task.calendarItemIdentifier) { item in
                            
                                HStack {
                                    Button(action: {
                                        markTaskAsCompleted(reminder: item.task)
                                    }) {
                                        Image(systemName: item.task.isCompleted ? "button.programmable" : "circle")
                                            .foregroundColor(item.task.isCompleted ? .black : .black)
                                            .font(.title)
                                            .background(.white).clipShape(Circle())
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .padding(.trailing, 8)
                                    
                                    NavigationLink(destination: TaskView(task: item.task)) {
                                        HStack{
                                            Text(item.task.title.uppercased())
                                                .font(.headline)
                                                .foregroundStyle(item.task.isCompleted ? .gray : .black)
                                                .fontWeight(item.task.isCompleted ? .regular : .bold)
                                            Spacer()
                                        }
                                    }
                                    
                                    Spacer()
                                    if showingTaskMenu == true {
                                        HStack {
                                            Image(systemName: "arrow.uturn.right.circle.fill").font(.title).background(.white).clipShape(Circle())
                                            Image(systemName: "minus.circle.fill").font(.title).background(.white).clipShape(Circle())
                                            Image(systemName: "trash.circle.fill").font(.title).background(.white).clipShape(Circle())
                                        }.padding(.leading, 10)
                                    }
                                    
                                }
                                .padding()
                                .frame(maxWidth: .infinity, maxHeight: 50)
                                .background(item.task.isCompleted ? item.listColor.opacity(0.5) : item.listColor)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .shadow(radius: 3, x: 3, y: 3)
                                .padding(.horizontal, 14)
                                .onChange(of: item.task.isCompleted) {
                                    loadTodaysReminders()
                                }
                            
                           
                            
                        }
                        
                        
                    }
                    
                }
                
                .onChange(of: dateHolder.displayedDate) {
                     loadTodaysReminders()
                }
                
                
                VStack {
                    Spacer()
                    HStack {
                       
                        Button("Edit Tasks", systemImage: "ellipsis.circle.fill", action: {
                            showingTaskMenu.toggle()
                        }).labelStyle(.iconOnly).font(.title).background(.white).clipShape(Circle()).foregroundStyle(Color.black).padding(.leading, 5).shadow(radius: 2, x: 3, y: 3)
                        Spacer()
                        Button("Add Task", systemImage: "plus.circle.fill", action: {
                            showingAddTaskView.toggle()
                        }).labelStyle(.iconOnly).font(.title).background(.white).clipShape(Circle()).foregroundStyle(Color.black).padding(.trailing, 5).shadow(radius: 2, x: 3, y: 3)
                            .popover(isPresented: $showingAddTaskView) {
                                
                                
                                VStack{
                                    HStack {
                                        TextField("Task", text: $reminderTitle)
                                            .padding()
                                        Button("Add Reminder", systemImage: "plus.circle.fill") {
                                            saveTask()
                                            showingAddTaskView = false
                                        }
                                        .labelStyle(.iconOnly)
                                        .padding()
                                    }
                                    .padding()
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    
                                    
                                    
                                }.padding()
                                
                            }.clipShape(RoundedRectangle(cornerRadius: 20))
                        
                    }
                }
            }.onChange(of: tasksUpdateNotifier.needsUpdate) {
                loadTodaysReminders()
            }
            
            } else {
                VStack(alignment: .center) {
                Text("Unable to retrieve reminders. Please enable access to Reminders in Settings.")
                    Button("Request Reminders Access") {
                        requestAccess()
                    }
                }.padding()
                    .onAppear {
                        if permissionGranted == false {
                            print("requesting access")
                            requestAccess()
                        } else {
                           print("loading reminders")
                            loadTodaysReminders()
                        }
                        
                    }
            }
        
    }

    
    func markTaskAsCompleted(reminder: EKReminder) {
        DispatchQueue.main.async {
            reminder.isCompleted.toggle()
            do {
                try self.eventStore.save(reminder, commit: true)
                // Refresh your tasks list here
                self.loadTodaysReminders()
            } catch {
                print("Error saving reminder: \(error.localizedDescription)")
            }
        }
    }
    func deleteTask(taskToDelete: EKReminder) {
        DispatchQueue.main.async {
            do {
                try self.eventStore.remove(taskToDelete, commit: true)
                // After deleting from the event store, also remove it from the local tasks array
                self.tasks.removeAll { $0.task.calendarItemIdentifier == taskToDelete.calendarItemIdentifier }
            } catch let error as NSError {
                print("Failed to delete the reminder: \(error)")
            }
        }
    }
    
    private func requestAccess() {
        
        eventStore.requestFullAccessToReminders { granted, error in
            DispatchQueue.main.async {
                
                if granted {
                    self.permissionGranted = true
                    print(self.permissionGranted)
                    loadTodaysReminders()
                } else {
                    self.showingAlert = true
                    print("Access to reminders was denied.")
                }
            }
        }
    }
    
    private func loadTodaysReminders() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: dateHolder.displayedDate)
        let endOfDay = calendar.date(byAdding: .hour, value: 23, to: startOfDay)!
        let predicate = eventStore.predicateForReminders(in: nil)
        eventStore.fetchReminders(matching: predicate) { [self] fetchedTasks in
            guard let fetchedTasks = fetchedTasks else { return }
            self.tasks = fetchedTasks.compactMap { task in
                guard let dueDate = task.dueDateComponents?.date, dueDate >= startOfDay, dueDate < endOfDay else { return nil }
                return (task, Color(task.calendar.cgColor))
            }
            
        }
    }
    func saveTask() {
        var targetList: EKCalendar?
        let lists = eventStore.calendars(for: .reminder)
        
        for list in lists where list.title == "Inbox" {
            targetList = list
            break
        }
        
        if targetList == nil {
            // "Inbox" list not found, create a new one
            let newList = EKCalendar(for: .reminder, eventStore: self.eventStore)
            newList.title = "Inbox"
            newList.source = eventStore.defaultCalendarForNewReminders()?.source
            
            do {
                try eventStore.saveCalendar(newList, commit: true)
                targetList = newList
            } catch {
                print("Error creating new list: \(error.localizedDescription)")
            }
        }
        
        
        
        if let inboxList = targetList {
            let task = EKReminder(eventStore: self.eventStore)
            task.title = self.reminderTitle
            task.calendar = inboxList
            
            // Set the due date for the reminder
            let dueDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: dateHolder.displayedDate)
            task.dueDateComponents = dueDateComponents
            if !task.title.isEmpty {
                do {
                    try eventStore.save(task, commit: true)
                    tasksUpdateNotifier.needsUpdate.toggle()
                    
                    
                } catch {
                    print("Error saving reminder: \(error.localizedDescription)")
                }
            }
        }
    }

    
    
    
}




#Preview {
    TasksView()
        .environmentObject(DateHolder())
}
