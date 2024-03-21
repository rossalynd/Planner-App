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
    @State var todayBoxType: String
    var scale: Scale
    
    var body: some View {
        VStack {
            
            
            if todayBoxType == "Cal" {
                MiniMonthCalendarView(scale: scale)
            } else if todayBoxType == "ToDo" {
                ToDoView()
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



#Preview {
    TodayBoxView(todayBoxType: "", scale: .small)
}
