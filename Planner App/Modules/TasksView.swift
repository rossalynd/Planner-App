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
    
    @EnvironmentObject var appModel: AppModel
    var date: Date
    var scale: SpaceView.Scale
    @State private var tasks: [(task: EKReminder, listColor: Color)] = []
    @State private var showingAddTaskView = false
    @State private var permissionGranted = false
    @State private var showingAlert = false
    @State private var reminderTitle: String = ""
    @State private var dueDate: Date = Date()
    @State private var showingTaskMenu = false
    @State private var showDeletedTask = false
    @State private var previouslyDeletedTask: EKReminder? = nil
    
    

    init(date: Date, scale: SpaceView.Scale) {
        self.date = date
        self.scale = scale
    }
    
    var body: some View {
        if appModel.remindersPermissionGranted {
            ZStack {
                List {
                        ForEach(tasks, id: \.task.calendarItemIdentifier) { item in
                            let calendar = Calendar.current
                            let dueDate = calendar.date(from: item.task.dueDateComponents!)!
                            let isOverDue = dueDate < Date().startOfDay
                           
                                HStack {
                                    Button(action: {
                                        markTaskAsCompleted(reminder: item.task)
                                        loadTodaysReminders()
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                        loadTodaysRemindersWithOverDueWithoutCompleted()
                                        }
                                    }) {
                                        Image(systemName: item.task.isCompleted ? "button.programmable" : "circle")
                                            .foregroundColor(item.task.isCompleted ? .black : .black)
                                            .font(scale == .small ? .headline : .title3)
                                            .background(.white).clipShape(Circle())
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .padding(.trailing, 8)
                                    
                                    NavigationLink(destination: TaskView(task: item.task)) {
                                        HStack{
                                            Text(item.task.title.uppercased())
                                                .font(scale == .small ? .caption : .subheadline)
                                                .foregroundStyle(isOverDue ? Color.red : Color.black)

                                                .fontWeight(item.task.isCompleted ? .regular : .semibold)
                                            
                                            Spacer()
                                        }
                                    }
                                    
                                    Spacer()
                                    if showingTaskMenu == true {
                                        HStack {
                                            Image(systemName: "arrow.triangle.turn.up.right.circle.fill").foregroundStyle(.black).font(scale == .small ? .headline : .title3).background(.white).clipShape(Circle())
                                            Image(systemName: "minus.circle.fill").foregroundStyle(.black).font(scale == .small ? .headline : .title3).background(.white).clipShape(Circle())
                                            Button(action: { deleteTask(taskToDelete: item.task)
                                            }, label: {Image(systemName: "trash.circle.fill").foregroundStyle(.black).font(scale == .small ? .headline : .title3).background(.white).clipShape(Circle())})
                                            
                                        }.padding(.leading, 10)
                                    }
                                    
                                } .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))// Hide the row separators
                                .listRowBackground(Color.clear)
                                
                                .padding(.horizontal, 5)
                                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                    // Swipe left to delete
                                    Button(role: .destructive) {
                                        // Your delete action goes here
                                        print("Deleting...")
                                        deleteTask(taskToDelete: item.task)
                                    } label: {
                                        Text("Delete")
                                        
                                    }
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    // Swipe right to move to a new date
                                    Button {
                                        // Your move action goes here
                                        print("Moving to a new date...")
                                    } label: {
                                        Label("Move Date", systemImage: "calendar.circle.fill")
                                    }
                                    .tint(.white)
                                    
                                    // Swipe right to remove date
                                    Button {
                                        // Your remove date action goes here
                                        print("Removing date...")
                                    } label: {
                                        Label("Remove Date", systemImage: "calendar.badge.minus")
                                    }.labelStyle(.titleAndIcon)
                                    .tint(.white)
                                }
                                .padding(scale == .small ? 5 : 10)
                                .frame(maxWidth: .infinity)
                                .background(item.task.isCompleted ? item.listColor.opacity(0.5) : item.listColor)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .shadow(radius: 3, x: 3, y: 3)
                                
                        }
                    
                    
                }.listStyle(PlainListStyle()) // Use a plain list style
                    .background(Color.clear)
                
                .onChange(of: appModel.displayedDate) {
                     loadTodaysRemindersWithOverDueWithoutCompleted()
                }
                
                
                
                VStack {
                    Spacer()
               
                    VStack {
                  
                        if showDeletedTask, let taskToUndo = previouslyDeletedTask {
                            VStack {
                                Text("Deleted task: \(taskToUndo.title)").font(.caption)
                                Button(action: {
                                    undoDeleteTask()
                                }, label: {
                                    Text("Undo Delete")
                                })
                                .font(.caption2)
                            }.background(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                    }.onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                            withAnimation(.easeInOut) {
                                self.showDeletedTask = false
                            }
                        }
                    }
                        
                    
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
                                        Button("Add Task", systemImage: "plus.circle.fill") {
                                            saveTask()
                                            loadTodaysRemindersWithOverDueWithoutCompleted()
                                           
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
                loadTodaysRemindersWithOverDueWithoutCompleted()
            }
            
            } else {
                VStack(alignment: .center) {
                Text("Unable to retrieve reminders. Please enable access to Reminders in Settings.")
                    Button("Settings", action: {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    })
                }.padding()
                    .onAppear {
                        // Check if reminders permission is already granted
                        if appModel.remindersPermissionGranted {
                            self.loadTodaysRemindersWithOverDueWithoutCompleted()
                        } else {
                            // Request permission and then load the reminders if granted
                            appModel.requestRemindersAccess { granted in
                                if granted {
                                    self.loadTodaysRemindersWithOverDueWithoutCompleted()
                                }
                            }
                        }
                    }

                    .onChange(of: appModel.remindersPermissionGranted) { oldValue, newValue in
                        // Load reminders when permission is granted
                        if newValue {
                            self.loadTodaysRemindersWithOverDueWithoutCompleted()
                        }
                    }
            }
        
    }
    
    
    func markTaskAsCompleted(reminder: EKReminder) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            reminder.isCompleted.toggle()
            do {
                try appModel.eventStore.save(reminder, commit: true)
            } catch {
                print("Error saving reminder: \(error.localizedDescription)")
            }
        }
    }
     
    
    func deleteTask(taskToDelete: EKReminder) {
        DispatchQueue.main.async {
            do {
                self.previouslyDeletedTask = taskToDelete
                try appModel.eventStore.remove(taskToDelete, commit: true)
                // Remove from the local tasks array
                self.tasks.removeAll { $0.task.calendarItemIdentifier == taskToDelete.calendarItemIdentifier }
                // Store the deleted task for potential undo
                self.showDeletedTask = true // Show the undo option
            } catch let error as NSError {
                print("Failed to delete the reminder: \(error)")
            }
        }
    }
    func undoDeleteTask() {
        guard let reminderToRestore = previouslyDeletedTask else { return }
        
        let task = EKReminder(eventStore: appModel.eventStore)
        
        // Set the properties from the reminderToRestore
        task.title = reminderToRestore.title
        task.dueDateComponents = reminderToRestore.dueDateComponents
        task.notes = reminderToRestore.notes
        task.url = reminderToRestore.url
        task.priority = reminderToRestore.priority
        if let calendar = reminderToRestore.calendar {
            task.calendar = calendar
        } else {
            task.calendar = appModel.eventStore.defaultCalendarForNewReminders()
        }
        
        // Set alarms
        if reminderToRestore.alarms != nil {
            task.alarms = reminderToRestore.alarms
        }
        
        // Set recurrence rules
        if let recurrence = reminderToRestore.recurrenceRules {
            task.recurrenceRules = recurrence
        }
        
    
        do {
            try appModel.eventStore.save(task, commit: true)
            // Add more detailed logging here to confirm operation success
            print("Successfully restored reminder: \(String(describing: task.title))")
            self.tasksUpdateNotifier.needsUpdate.toggle() // Trigger a refresh
            
            withAnimation(.easeInOut) {
                self.showDeletedTask = false
            }
            
            self.previouslyDeletedTask = nil
        } catch {
            print("Error restoring reminder: \(error.localizedDescription)")
        }
    }


    
    private func loadTodaysReminders() {
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            let predicate = appModel.eventStore.predicateForReminders(in: nil)
            
            appModel.eventStore.fetchReminders(matching: predicate) { fetchedTasks in
                guard let fetchedTasks = fetchedTasks else { return }
                
                DispatchQueue.main.async {
                    self.tasks = fetchedTasks.compactMap { task in
                        guard !task.isCompleted,
                              let dueDate = task.dueDateComponents?.date,
                              dueDate >= startOfDay,
                              dueDate < endOfDay else {
                            return nil
                        }
                        return (task, Color(task.calendar.cgColor))
                    }
                }
            }
        }
   
    
    private func loadTodaysRemindersWithoutCompleted() {
       
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        let predicate = appModel.eventStore.predicateForReminders(in: nil)
        
        appModel.eventStore.fetchReminders(matching: predicate) { fetchedTasks in
            guard let fetchedTasks = fetchedTasks else { return }
            
            DispatchQueue.main.async {
                self.tasks = fetchedTasks.compactMap { task in
                    guard !task.isCompleted,
                          let dueDate = task.dueDateComponents?.date,
                          dueDate >= startOfDay,
                          dueDate < endOfDay else {
                        return nil
                    }
                    return (task, Color(task.calendar.cgColor))
                }
            }
        }
    }
    private func loadTodaysRemindersWithOverDueWithoutCompleted() {
        let calendar = Calendar.current
        
            // Replace 'date' with your variable that represents the displayed date
            let displayedDate = date // Assuming 'date' is the displayed date variable
            let displayedStartOfDay = calendar.startOfDay(for: displayedDate)
            let displayedEndOfDay = calendar.date(byAdding: .day, value: 1, to: displayedStartOfDay)!
            let predicate = appModel.eventStore.predicateForReminders(in: nil)
            
            appModel.eventStore.fetchReminders(matching: predicate) { fetchedTasks in
                guard let fetchedTasks = fetchedTasks else { return }
                
                DispatchQueue.main.async {
                    self.tasks = fetchedTasks.compactMap { task in
                        guard !task.isCompleted,
                              let dueDate = task.dueDateComponents?.date else {
                            return nil
                        }
                        
                        if displayedDate.startOfDay == Date().startOfDay {
                            // If displaying today's date, include overdue and today's reminders
                            if dueDate < displayedEndOfDay {
                                return (task, Color(task.calendar.cgColor))
                            }
                        } else {
                            // For any other date, include only that day's reminders
                            if dueDate >= displayedStartOfDay && dueDate < displayedEndOfDay {
                                return (task, Color(task.calendar.cgColor))
                            }
                        }
                        
                        return nil
                    }
                }
            }
    }

    


    
    func saveTask() {
        var targetList: EKCalendar?
        let lists = appModel.eventStore.calendars(for: .reminder)
        
        for list in lists where list.title == "Inbox" {
            targetList = list
            break
        }
        
        if targetList == nil {
            // "Inbox" list not found, create a new one
            let newList = EKCalendar(for: .reminder, eventStore: appModel.eventStore)
            newList.title = "Inbox"
            newList.source = appModel.eventStore.defaultCalendarForNewReminders()?.source
            
            do {
                try appModel.eventStore.saveCalendar(newList, commit: true)
                targetList = newList
            } catch {
                print("Error creating new list: \(error.localizedDescription)")
            }
        }
        
        
        
        if let inboxList = targetList {
            let task = EKReminder(eventStore: appModel.eventStore)
            task.title = self.reminderTitle
            task.calendar = inboxList
            
            // Set the due date for the reminder
            let dueDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
            task.dueDateComponents = dueDateComponents
            if !task.title.isEmpty {
                do {
                    try appModel.eventStore.save(task, commit: true)
                    tasksUpdateNotifier.needsUpdate.toggle()
                    
                    
                } catch {
                    print("Error saving reminder: \(error.localizedDescription)")
                }
            }
        }
    }

    
    
    
}



