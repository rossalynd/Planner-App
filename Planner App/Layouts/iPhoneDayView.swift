//
//  iPhoneLayoutView.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/26/24.
//

import SwiftUI

struct iPhoneDayView: View {
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
                        SpaceView(type: smallSpaceTop, scale: .small, layoutType: .iphonePortrait)
                    }.frame(maxHeight: geometry.size.height / 3.2)
                    VStack(spacing: 15) {
                        VStack {
                            SpaceView(type: smallSpaceMiddleTop, scale: .small, layoutType: .iphonePortrait)
                        }
                        VStack {
                            SpaceView(type: smallSpaceMiddleBottom, scale: .small, layoutType: .iphonePortrait)
                        }
                        
                    }
                }.frame(maxWidth: geometry.size.width / 1.7, maxHeight: geometry.size.height)
                
                VStack(spacing: 15) {
                    SpaceView(type: largeSpaceTop, scale: .small, layoutType: .iphonePortrait)
                    SpaceView(type: largeSpaceBottom, scale: .small, layoutType: .iphonePortrait)
                    
                   
                        SpaceView(type: mediumSpaceLeft, scale: .small, layoutType: .iphonePortrait)
                        SpaceView(type: mediumSpaceRight, scale: .small, layoutType: .iphonePortrait)
                    
                    
                    
                }.frame(maxWidth: .infinity, maxHeight: geometry.size.height)
            }
        }.shadow(radius: 4, x:3,y:3)
        
    }
}
