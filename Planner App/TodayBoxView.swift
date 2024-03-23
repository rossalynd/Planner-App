//
//  TodayBoxView.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/21/24.
//

import SwiftUI

struct TodayBoxView: View {
    @State var showingAddView: Bool = false
    @State var showingReplaceView: Bool = false
    @State var type: String
    var scale: SpaceView.Scale
    
    var body: some View {
        VStack {
            
            
            if type == "Cal" {
                MiniMonthCalendarView(scale: scale)
            } else if type == "Tasks" {
                TasksView()
            } else {
                Text("No views to display")
                
            }
        }.shadow(radius: 10, x:5,y:5)
       
    }
    enum Scale {
        case small, medium, large
    }
    
    
    var editButtons: some View {
        HStack {
            //Up Button
            Button(action: {
                
                
            }) {
                Image(systemName: "chevron.up.circle.fill")
            }
            
            
            //Down Button
            Button(action: {
              
                
            }) {
                Image(systemName: "chevron.down.circle.fill")
            }
            
            
            //Replace button
            Button(action: {
               //code to replace current module
                
            }) {
                Image(systemName: "arrow.2.squarepath")
            }
            
           
            
            //Remove button
            Button(action: {
                //code to remove current module
                
            }) {
                Image(systemName: "minus.circle.fill")
            }
            
            
        }
    }
    
}



