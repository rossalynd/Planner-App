//
//  SpaceView.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/23/24.
//



import SwiftUI

struct SpaceView: View {
    @EnvironmentObject var appModel: AppModel
    @State var type: String
    @State var showingAssignView = false
    var scale: Scale
    var layoutType: LayoutType
    var maxHeight = 0.0
   
    
    enum Scale {
        case small, medium, large
    }
    
    

    var body: some View {
        GeometryReader { geometry in
            ZStack {
               
                
                VStack {
                    
                    HStack {
                        if type != "Calendar" {
                            Text(type.uppercased()).font(.headline)  
                                .onLongPressGesture(perform:{
                                showingAssignView = true
                            })
                        
                        } else {
                            HStack {
                                Text(appModel.displayedDate.monthName)
                                    .textCase(.uppercase).font(.headline)
                                Text(appModel.displayedDate.year).font(.headline)
                            }  
                            .onLongPressGesture(perform:{
                                showingAssignView = true
                            })
                        
                        }
                    }.padding(.top, 12.0)
                    
                    if type == "Calendar" {
                        MiniMonthCalendarView(scale: scale, layoutType: layoutType, appModel: appModel)
                    } else if type == "Notes" {
                        NotesView()
                    } else if type == "Mood" {
                        MoodView()
                    } else if type == "Weather" {
                        WeatherView()
                    } else if type == "Tasks" {
                        TasksView(date: appModel.displayedDate, scale: scale)
                            .environmentObject(TasksUpdateNotifier())
                    } else if type == "Schedule" {
                        ScheduleView(layoutType: layoutType, scale: scale, date: appModel.displayedDate)
                    } else if type == "Gratitude" {
                        GratitudeView()
                    } else if type == "Water" {
                        WaterView()
                    } else if type == "Meals" {
                        MealsView()
                    } else {
                        Text("No view to display")
                    }
                    Spacer()
                }
                .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .background(Color("DefaultWhite"))
                .clipShape(RoundedRectangle(cornerRadius: appModel.moduleCornerRadius))
                .sheet(isPresented: $showingAssignView) {
                    AddModuleView(type: $type).onDisappear()
                }
                
               
                
            }
        }
        
          
    }

    func currentMonthName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM" // "MMMM" is the format string for the full month name.
        let monthName = dateFormatter.string(from: appModel.displayedDate)
        return monthName
    }
}



