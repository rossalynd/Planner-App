//
//  TaskView.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/30/24.
//

import SwiftUI
import EventKit
struct TaskView: View {
    var task: EKReminder
    var body: some View {
        Text(task.title)
    }
}

