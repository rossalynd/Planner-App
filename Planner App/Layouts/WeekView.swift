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
                        HStack(spacing: 10) {
                            SpaceView(type: smallSpaceLeft, scale: .small, layoutType: .elseLandscape)
                            SpaceView(type: smallSpaceLeftMiddle, scale: .small, layoutType: .elseLandscape)
                            SpaceView(type: smallSpaceRightMiddle, scale: .small, layoutType: .elseLandscape)
                            SpaceView(type: smallSpaceRight, scale: .small, layoutType: .elseLandscape)
                        }.frame(maxHeight: geometry.size.height / 2.9)
                        HStack(alignment: .top) {
                            ForEach(datesInWeekList, id: \.self) { date in
                                
                                VStack(spacing: 10) {
                                    // Format the date to display however you prefer
                                    HStack{
                                        Text(date.dayOfWeekFirstLetter).padding([.leading, .top]).font(.title).bold()
                                        Text(date.dateNum).padding([.trailing, .top]).font(.title).bold()
                                    }
                                    ScheduleView(layoutType: .elseLandscape, scale: .small, date: date)
                                    TasksView(date: date, scale: .small)
                                    
                                    
                                    
                                    Spacer()
                                    
                                }.frame(maxWidth: .infinity)
                                
                                
                                
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
                    HStack(spacing: 10) {
                        // Dynamic generation of dates in the week
                        VStack(spacing: 10) {
                            SpaceView(type: smallSpaceLeft, scale: .small, layoutType: .elsePortrait)
                            SpaceView(type: smallSpaceLeftMiddle, scale: .small, layoutType: .elsePortrait)
                            SpaceView(type: smallSpaceRightMiddle, scale: .small, layoutType: .elsePortrait)
                            SpaceView(type: smallSpaceRight, scale: .small, layoutType: .elsePortrait)
                        }.frame(maxWidth: geometry.size.width * 0.3)
                        VStack(spacing: 10) {
                            ForEach(datesInWeekList, id: \.self) { date in
                                
                                HStack(spacing: 10) {
                                    HStack{
                                        Text(date.dayOfWeekFirstLetter).padding([.leading, .top]).font(.title).bold()
                                        Text(date.dateNum).padding([.trailing, .top]).font(.title).bold()
                                    }
                                    ScheduleView(layoutType: .elsePortrait, scale: .small, date: date)
                                    TasksView(date: date, scale: .small)
                                    
                                }
                                
                                
                                
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
        .modelContainer(for: MoodEntry.self)
}
