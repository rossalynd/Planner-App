//
//  Permissions.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/30/24.
//

import Foundation
import EventKit

class Permissions: ObservableObject {
    @Published var calendarPermissionGranted: Bool = false
    @Published var remindersPermissionGranted: Bool = false
    @Published var eventStore = EKEventStore()
    
    func requestCalendarAccess() {
        eventStore.requestFullAccessToEvents { granted, error in
            DispatchQueue.main.async {
                if granted {
                    self.calendarPermissionGranted = true
                } else {
                    self.calendarPermissionGranted = false
                }
            }
        }
    }
    func requestRemindersAccess() {
        eventStore.requestFullAccessToReminders { granted, error in
            DispatchQueue.main.async {
                if granted {
                    self.remindersPermissionGranted = true
                    print("reminders permission set to \(self.remindersPermissionGranted)")
                } else {
                    self.remindersPermissionGranted = false
                    print("Access to reminders was denied. Reminders permission set to \(self.remindersPermissionGranted)")
                }
            }
        }
    }
    
}
