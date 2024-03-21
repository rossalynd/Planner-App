//
//  ContentView.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/21/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    

    var body: some View {
        NavigationSplitView {
            //Menu
            Text("Hello World")
            
            
            
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
            .toolbar {
                ToolbarItem {
                    
                }
            }
        } detail: {
            TodayView().padding()
            
        }
       
        
    }

 
            
}

#Preview {
    ContentView()
      

}
