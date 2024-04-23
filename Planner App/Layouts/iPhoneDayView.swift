//
//  iPhoneLayoutView.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/26/24.
//

import SwiftUI

struct iPhoneDayView: View {
    @EnvironmentObject private var appModel: AppModel
    private var mediumSpaceTop: String = "Schedule"
    
    private var smallSpaceMiddleLeft: String = "Mood"
    private var smallSpaceMiddleRight: String = "Gratitude"
    
    private var largeSpaceBottom: String = "Tasks"
    private var smallSpaceBottomLeft: String = "Water"
    private var smallSpaceBottomRight: String = "Meals"
    
   

    var body: some View {
        GeometryReader { geometry in
            
            ScrollView(.vertical) {
                VStack(spacing: appModel.moduleSpacing) {
                    
                    SpaceView(type: mediumSpaceTop, scale: .medium, layoutType: .iphonePortrait)
                        .frame(minHeight: (geometry.size.height / 3) - appModel.moduleSpacing)
                    
                    HStack(spacing: appModel.moduleSpacing) {
                        SpaceView(type: smallSpaceMiddleLeft, scale: .small, layoutType: .iphonePortrait)
                        SpaceView(type: smallSpaceMiddleRight, scale: .small, layoutType: .iphonePortrait)
                    }
                    .frame(minHeight: (geometry.size.height / 3) - appModel.moduleSpacing)
                    SpaceView(type: largeSpaceBottom, scale: .large, layoutType: .iphonePortrait)
                        .frame(minHeight: (geometry.size.height / 3) - appModel.moduleSpacing)
                    HStack(spacing: appModel.moduleSpacing) {
                        SpaceView(type: smallSpaceBottomLeft, scale: .small, layoutType: .iphonePortrait)
                        SpaceView(type: smallSpaceBottomRight, scale: .small, layoutType: .iphonePortrait)
                    }
                    .frame(minHeight: (geometry.size.height / 3) - appModel.moduleSpacing)
                    
                    
                }.padding(.bottom, appModel.moduleSpacing)
                
            
            }.frame(minWidth: geometry.size.width, minHeight: geometry.size.height).scrollIndicators(.hidden)
        }
        
    }
}

#Preview {
    ContentView()
        .environmentObject(AppModel())
        .environmentObject(TasksUpdateNotifier())
        .modelContainer(for: [MoodEntry.self, Note.self])
       
}
