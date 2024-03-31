//
//  OtherLandscapeView.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/28/24.
//

import Foundation
import SwiftUI

struct WeekView: View {
    @EnvironmentObject var themeController: ThemeController
    @EnvironmentObject var dateHolder: DateHolder
    private var smallSpaceLeft: String = "Calendar"
    private var smallSpaceLeftMiddle: String = "Weather"
    private var smallSpaceRightMiddle: String = "Gratitude"
    private var smallSpaceRight: String = "Notes"
    
    
    var body: some View {
        GeometryReader { geometry in
            
            ZStack() {
                VStack {
                    
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                .themedBackground(themeController: themeController)
                
                VStack {
                    // Dynamic generation of dates in the week
                    HStack(spacing: 10) {
                        SpaceView(type: smallSpaceLeft, scale: .small, layoutType: .elseLandscape)
                        SpaceView(type: smallSpaceLeftMiddle, scale: .small, layoutType: .elseLandscape)
                        SpaceView(type: smallSpaceRightMiddle, scale: .small, layoutType: .elseLandscape)
                        SpaceView(type: smallSpaceRight, scale: .small, layoutType: .elseLandscape)
                    }.frame(maxHeight: geometry.size.height / 2.9)
                    HStack(alignment: .top) {
                        ForEach(dateHolder.datesInWeek(from: dateHolder.displayedDate, weekStartsOn: dateHolder.startOfWeek), id: \.self) { date in
                            
                            VStack(spacing: 10) {
                                // Format the date to display however you prefer
                                HStack{
                                    Text(date.dayOfWeekFirstLetter).padding([.leading, .top]).font(.title).bold()
                                    Text(date.dateNum).padding([.trailing, .top]).font(.title).bold()
                                }
                                ScheduleView(layoutType: .elseLandscape, scale: .small, date: date)
                                TasksView(date: date)
                                
                                
                                
                                Spacer()
                                
                            }.frame(maxWidth: .infinity)
                                
                            
                            
                        }.background(Color("DefaultWhite")).clipShape(RoundedRectangle(cornerRadius: 20))
                       
                    }
                    .frame(maxHeight: .infinity)
                    
                    
                    
                }.padding(.horizontal)
            }
        }
    }
   
    
}

#Preview {
    ContentView()
        .environmentObject(DateHolder())
        .environmentObject(ThemeController())
        .environmentObject(CustomColor())
        .environmentObject(TasksUpdateNotifier())
        .environmentObject(OrientationObserver())
        .environmentObject(Permissions())
}
