//
//  iPhoneLayoutView.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/26/24.
//

import SwiftUI

struct iPhoneDayView: View {

    private var mediumSpaceTop: String = "Timeline (Horizontal)"
    
    private var smallSpaceMiddleLeft: String = "Mood"
    private var smallSpaceMiddleRight: String = "Gratitude"
    
    private var largeSpaceBottom: String = "Tasks"
    
   

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 15) {
            
                
                VStack(spacing: 15) {
                    SpaceView(type: mediumSpaceTop, scale: .medium, layoutType: .iphonePortrait)
                    
                    HStack {
                        SpaceView(type: smallSpaceMiddleLeft, scale: .small, layoutType: .iphonePortrait)
                        SpaceView(type: smallSpaceMiddleRight, scale: .small, layoutType: .iphonePortrait)
                    }
                    
                   
                        
                        SpaceView(type: largeSpaceBottom, scale: .large, layoutType: .iphonePortrait)
                    
                    
                    
                }.frame(maxWidth: .infinity, maxHeight: geometry.size.height)
            }
        }.shadow(radius: 4, x:3,y:3)
        
    }
}
