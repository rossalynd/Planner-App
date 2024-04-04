//
//  iPhoneLandscapeView.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/28/24.
//
//
//  iPhoneLayoutView.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/26/24.
//

import SwiftUI

struct iPhoneLandscapeView: View {
    @EnvironmentObject var dateHolder: DateHolder
    private var smallSpaceTop: String = "Calendar"
    private var smallSpaceMiddleTop: String = "Schedule"
    private var smallSpaceMiddleBottom: String = "Tasks"
    private var largeSpaceTop: String = "Weather"
    private var largeSpaceBottom: String = "Mood"
    private var mediumSpaceLeft: String = "Notes"
    private var mediumSpaceRight: String = "Gratitude"

    var body: some View {
     
            HStack(spacing: 15) {
            
                VStack(spacing: 15) {
                    
                    SpaceView(type: smallSpaceTop, scale: .small)
                    SpaceView(type: smallSpaceMiddleBottom, scale: .small)
                    
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                
                VStack(spacing: 15) {
                    
                    SpaceView(type: mediumSpaceLeft, scale: .small)
                    SpaceView(type: mediumSpaceRight, scale: .small)
                    
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                
                VStack(spacing: 15) {
                    
                    SpaceView(type: largeSpaceTop, scale: .small)
                    SpaceView(type: largeSpaceBottom, scale: .small)
                    
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        .shadow(radius: 4, x:3,y:3)
        
    }
}

#Preview {
    iPhoneLandscapeView()
        .environmentObject(DateHolder())
        .environmentObject(ThemeController())
}
