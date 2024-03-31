//
//  Planner_AppApp.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/21/24.
//

import SwiftUI
import SwiftData

@main
struct Planner_App: App {
    var orientationObserver = OrientationObserver()


    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(DateHolder())
                .environmentObject(ThemeController())
                .environmentObject(CustomColor())
                .environmentObject(OrientationObserver())
                .environmentObject(Permissions())
                .environmentObject(TasksUpdateNotifier())
                
        }

    }
}
