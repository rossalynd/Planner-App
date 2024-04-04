//
//  iPhoneLayoutView.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/26/24.
//

import SwiftUI

struct iPhoneLayoutView: View {
    @EnvironmentObject var dateHolder: DateHolder
    private var smallSpaceTop: String = "Calendar"
    private var smallSpaceMiddleTop: String = "Schedule"
    private var smallSpaceMiddleBottom: String = "Tasks"
    private var largeSpaceTop: String = "Weather"
    private var largeSpaceBottom: String = "Mood"
    private var mediumSpaceLeft: String = "Notes"
    private var mediumSpaceRight: String = "Gratitude"

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 15) {
            
                VStack(spacing: 15) {
                    VStack {
                        SpaceView(type: smallSpaceTop, scale: .small)
                    }.frame(maxHeight: geometry.size.height / 3.2)
                    VStack(spacing: 15) {
                        VStack {
                            SpaceView(type: smallSpaceMiddleTop, scale: .small)
                        }
                        VStack {
                            SpaceView(type: smallSpaceMiddleBottom, scale: .small)
                        }
                        
                    }
                }.frame(maxWidth: geometry.size.width / 1.7, maxHeight: geometry.size.height)
                
                VStack(spacing: 15) {
                    SpaceView(type: largeSpaceTop, scale: .small)
                    SpaceView(type: largeSpaceBottom, scale: .small)
                    
                   
                        SpaceView(type: mediumSpaceLeft, scale: .small)
                        SpaceView(type: mediumSpaceRight, scale: .small)
                    
                    
                    
                }.frame(maxWidth: .infinity, maxHeight: geometry.size.height)
            }
        }.shadow(radius: 4, x:3,y:3)
        
    }
}

#Preview {
    iPhoneLayoutView()
        .environmentObject(DateHolder())
        .environmentObject(ThemeController())
}
