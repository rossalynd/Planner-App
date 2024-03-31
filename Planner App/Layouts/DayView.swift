//
//  TodayLayoutView.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/23/24.
//

import SwiftUI
import SwiftData

struct DayView: View {
    @EnvironmentObject var dateHolder: DateHolder
    private var smallSpaceTop: String = "Calendar"
    private var smallSpaceMiddleTop: String = "Mood"
    private var smallSpaceMiddleBottom: String = "Gratitude"
    private var smallSpaceBottom: String = "Water"
    private var largeSpaceTop: String = "Schedule"
    private var largeSpaceBottom: String = "Tasks"
    private var mediumSpaceLeft: String = "Meals"
    private var mediumSpaceRight: String = "Notes"

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 20) {
            
                VStack(spacing: 20) {
                    VStack {
                        SpaceView(type: smallSpaceTop, scale: .small, layoutType: .elsePortrait)
                    }
                    VStack {
                        SpaceView(type: smallSpaceMiddleTop, scale: .small, layoutType: .elsePortrait)
                    }
                    VStack {
                        SpaceView(type: smallSpaceMiddleBottom, scale: .small, layoutType: .elsePortrait)
                    }
                    VStack {
                        SpaceView(type: smallSpaceBottom, scale: .small, layoutType: .elsePortrait)
                    }
                    
                }.frame(maxWidth: geometry.size.width / 3.5, maxHeight: geometry.size.height)
                
                VStack(spacing: 20) {
                    SpaceView(type: largeSpaceTop, scale: .large, layoutType: .elsePortrait)
                    SpaceView(type: largeSpaceBottom, scale: .large, layoutType: .elsePortrait)
                    
                    HStack(spacing: 20) {
                        SpaceView(type: mediumSpaceLeft, scale: .medium, layoutType: .elsePortrait)
                        SpaceView(type: mediumSpaceRight, scale: .medium, layoutType: .elsePortrait)
                    }
                    
                    
                }.frame(maxWidth: .infinity, maxHeight: geometry.size.height)
            }
        }.shadow(radius: 5, x:5,y:5)
        
    }
    
    
    
}


#Preview {
    DayView()
        .environmentObject(DateHolder())
        .environmentObject(ThemeController())
}
