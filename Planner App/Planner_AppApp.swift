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
   


    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(DateHolder())
                .environmentObject(ThemeController())
                .environmentObject(CustomColor())
                
        }

    }
}
