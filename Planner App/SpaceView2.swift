//
//  SpaceView.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/23/24.
//



import SwiftUI

struct SpaceView: View {
    @EnvironmentObject var dateHolder: DateHolder
    @State var type: String
    @State var showingAssignView = false
    var scale: Scale
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
                        } else {
                            
                            Text(currentMonthName())
                                .textCase(.uppercase).font(.headline)
                        }
                    }.padding(.top, 12.0)
                    
                    if type == "Calendar" {
                        MiniMonthCalendarView(scale: scale)
                    } else if type == "Notes" {
                        NotesView()
                    } else if type == "Mood" {
                        MoodView()
                    } else if type == "Weather" {
                        WeatherView()
                    } else if type == "Tasks" {
                        TasksView()
                    } else if type == "Schedule" {
                        ScheduleView(scale: scale)
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
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .onTapGesture {
                    
                }
                .sheet(isPresented: $showingAssignView) {
                    AddModuleView(type: $type).onDisappear()
                }
                
               
                
            }
        }
        .onLongPressGesture(perform:{ showingAssignView = true})
    }

    func currentMonthName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM" // "MMMM" is the format string for the full month name.
        let monthName = dateFormatter.string(from: Date())
        return monthName
    }
}



#Preview {
    SpaceView(type: "Calendar", scale: .small)
}
