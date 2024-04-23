//
//  OtherLandscapeView.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/28/24.
//

import Foundation
import SwiftUI

struct WeekView: View {
    @EnvironmentObject var appModel: AppModel
    private var smallSpaceLeft: String = "Calendar"
    private var smallSpaceLeftMiddle: String = "Weather"
    private var smallSpaceRightMiddle: String = "Gratitude"
    private var smallSpaceRight: String = "Notes"
    @State private var datesInWeekList: [Date] = []
    
    
    var body: some View {
        GeometryReader { geometry in
            
            ZStack() {
               
                if appModel.isLandscape {
                    VStack {
                        // Dynamic generation of dates in the week
                        HStack(spacing: appModel.moduleSpacing) {
                            SpaceView(type: smallSpaceLeft, scale: .small, layoutType: .elseLandscape)
                            SpaceView(type: smallSpaceLeftMiddle, scale: .small, layoutType: .elseLandscape)
                            SpaceView(type: smallSpaceRightMiddle, scale: .small, layoutType: .elseLandscape)
                            SpaceView(type: smallSpaceRight, scale: .small, layoutType: .elseLandscape)
                        }.frame(maxHeight: geometry.size.height / 2.9)
                        HStack(alignment: .top) {
                            ForEach(datesInWeekList, id: \.self) { date in
                                
                                VStack(spacing: appModel.moduleSpacing) {
                                    // Format the date to display however you prefer
                                    HStack{
                                        Text(date.dayOfWeekFirstLetter).padding([.leading, .top]).font(.title).bold()
                                        Text(date.dateNum).padding([.trailing, .top]).font(.title).bold()
                                    }
                                    TimelineView(layoutType: .elseLandscape, scale: .small)
                                    TasksView(date: date, scale: .small)
                                    
                                    
                                    
                                    Spacer()
                                    
                                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                                
                                
                                
                            }.background(Color("DefaultWhite")).clipShape(RoundedRectangle(cornerRadius: appModel.moduleCornerRadius))
                            
                        }
                        .frame(maxHeight: .infinity)
                        
                        
                        
                    }.onChange(of: appModel.startOfWeek) {
                        print("Date changed, updating dates in week list")
                        datesInWeekList = datesInWeek(from: appModel.displayedDate, weekStartsOn: appModel.startOfWeek)
                    }
                    .onChange(of: appModel.displayedDate) {
                        
                        print("Date changed, updating dates in week list")
                        datesInWeekList = datesInWeek(from: appModel.displayedDate, weekStartsOn: appModel.startOfWeek)
                    }
                    .onAppear {
                        datesInWeekList = datesInWeek(from: appModel.displayedDate, weekStartsOn: appModel.startOfWeek)
                    }
                } else {
                    //if portrait
                    HStack(spacing: appModel.moduleSpacing) {
                        // Dynamic generation of dates in the week
                        
                        
                        VStack(spacing: appModel.moduleSpacing) {
                            ForEach(datesInWeekList, id: \.self) { date in
                                
                                HStack(spacing: appModel.moduleSpacing) {
                                    VStack{
                                        HStack{
                                            Text(date.dayOfWeekFirstLetter).padding([.leading, .top]).font(.title).bold()
                                            Text(date.dateNum).padding([.trailing, .top]).font(.title2).bold()
                                        }
                                        AllDayEventsView(date: date)
                                    }.frame(maxWidth: geometry.size.width / 4)
                                    HorizontalTimelineView(layoutType: .elsePortrait, scale: .small, date: date)
                                }.frame(maxHeight: .infinity)
                                
                                
                                
                            }.background(Color("DefaultWhite")).clipShape(RoundedRectangle(cornerRadius: appModel.moduleCornerRadius))
                            
                        }.frame(maxWidth: .infinity)
                        
                    }.onChange(of: appModel.startOfWeek) {
                        print("Date changed, updating dates in week list")
                        datesInWeekList = datesInWeek(from: appModel.displayedDate, weekStartsOn: appModel.startOfWeek)
                    }
                    .onChange(of: appModel.displayedDate) {
                        print("Date changed, updating dates in week list")
                        datesInWeekList = datesInWeek(from: appModel.displayedDate, weekStartsOn: appModel.startOfWeek)
                    }
                    .onAppear {
                        datesInWeekList = datesInWeek(from: appModel.displayedDate, weekStartsOn: appModel.startOfWeek)
                    }
                }
            }
        }
    }
    
    func datesInWeek(from date: Date, weekStartsOn startDay: WeekStartDay) -> [Date] {
        var calendar = Calendar.current
        
        switch startDay {
        case .sunday:
            calendar.firstWeekday = 1 // Sunday
        case .monday:
            calendar.firstWeekday = 2 // Monday
        
        
        }

        
        // Find the start of the week
        guard let startDateOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)) else {
            return []
        }
        
        // Generate the list of dates in the week
        var dates: [Date] = []
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: startDateOfWeek) {
                dates.append(date)
            }
        }
        
        return dates
    }
   
    
}

#Preview {
    WeekView()
        .environmentObject(AppModel())
        .environmentObject(TasksUpdateNotifier())
        .modelContainer(for: [MoodEntry.self, Note.self])
}
