//
//  Planner_AppApp.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/21/24.
//

import SwiftUI
import SwiftData
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct Planner_App: App {
    @EnvironmentObject var appModel: AppModel
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    


    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(AppModel())
                .environmentObject(TasksUpdateNotifier())
                .modelContainer(for: [MoodEntry.self, Note.self])
        }
        
        

    }
    

    
}
