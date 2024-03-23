//
//  TodayLayoutView.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/23/24.
//

import SwiftUI
import SwiftData

struct TodayLayoutView: View {
    
    private var smallSpaceTop: String = "Calendar"
    private var smallSpaceMiddleTop: String = "Schedule"
    private var smallSpaceMiddleBottom: String = "Tasks"
    private var smallSpaceBottom: String = "Mood"
    private var largeSpaceTop: String = "Notes"
    private var largeSpaceBottom: String = "default"
    private var mediumSpaceLeft: String = "default"
    private var mediumSpaceRight: String = "default"
    
    
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 20) {
            
                VStack(spacing: 20) {
                    VStack {
                        SpaceView(type: smallSpaceTop, scale: .small) 
                    }
                    VStack {
                        SpaceView(type: smallSpaceMiddleTop, scale: .small)
                    }
                    VStack {
                        SpaceView(type: smallSpaceMiddleBottom, scale: .small)
                    }
                    VStack {
                        SpaceView(type: smallSpaceBottom, scale: .small)
                    }
                    
                }.frame(maxWidth: geometry.size.width / 3.5, maxHeight: geometry.size.height)
                
                VStack(spacing: 20) {
                    SpaceView(type: largeSpaceTop, scale: .small)
                    SpaceView(type: largeSpaceBottom, scale: .small)
                    
                    HStack(spacing: 20) {
                        SpaceView(type: mediumSpaceLeft, scale: .small)
                        SpaceView(type: mediumSpaceRight, scale: .small)
                    }
                    
                    
                }.frame(maxWidth: .infinity, maxHeight: geometry.size.height)
            }.padding()
        }
        
    }
    
    
    
}


#Preview {
    TodayLayoutView()
}
