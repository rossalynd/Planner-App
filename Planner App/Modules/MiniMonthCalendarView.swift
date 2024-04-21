//
//  MiniMonthCalendarView.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/21/24.
//

import SwiftUI


struct MiniMonthCalendarView: View {
   
    @EnvironmentObject var appModel: AppModel
    @StateObject private var viewModel: CalendarViewModel = CalendarViewModel(date: Date(), startOfWeek: .monday, dayColor: .pink) // Default values
    @State var showDatePicker: Bool = false
       var scale: SpaceView.Scale
       var layoutType: LayoutType
    
   
    init(scale: SpaceView.Scale, layoutType: LayoutType, appModel: AppModel) {
           self.scale = scale
           self.layoutType = layoutType
        _viewModel = StateObject(wrappedValue: CalendarViewModel(date: appModel.displayedDate, startOfWeek: appModel.startOfWeek, dayColor: appModel.headerColor))
       }
    
    private var baseFontSize: CGFloat {
        switch scale {
        case .small: return 14 // Smaller parent view
        case .medium: return 24 // Medium parent view
        case .large: return 50 // Larger parent view
        }
    }
    
    private var paddingScale: CGFloat {
        switch scale {
        case .small: return 1 // Reduced padding for smaller view
        case .medium: return 5 // Standard padding for medium view
        case .large: return 10 // Increased padding for larger view
        }
    }
    
    private var spacingScale: CGFloat {
        switch scale {
        case .small: return 1 // Tighter spacing for smaller view
        case .medium: return 6 // Standard spacing for medium view
        case .large: return 15 // Looser spacing for larger view
        }
    }
    
    private var circleSize: CGFloat {
        switch scale {
        case .small: return 20 // Tighter spacing for smaller view
        case .medium: return 45 // Standard spacing for medium view
        case .large: return 100 // Looser spacing for larger view
        }
    }
    
    private func previousMonth() {
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .month, value: -1, to: appModel.displayedDate) {
            appModel.displayedDate = newDate
            // Now displayedDate is one month earlier
        } else {
            // Handle potential error if the date subtraction fails
            print("Could not calculate the new date.")
        }
        viewModel.previousMonth()
       
    }
    
    private func nextMonth() {
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .month, value: 1, to: appModel.displayedDate) {
            appModel.displayedDate = newDate
            // Now displayedDate is one month earlier
        } else {
            // Handle potential error if the date subtraction fails
            print("Could not calculate the new date.")
        }
        viewModel.nextMonth()
    }
    
    var body: some View {
        VStack(spacing: spacingScale) { // Use spacingScale for Vstack spacing
           
            HStack {
                            Button("Previous Month", systemImage: "arrowshape.left.circle.fill", action: {
                                previousMonth()
                                
                            }).labelStyle(.iconOnly).font(.title).background(.white).clipShape(Circle()).foregroundStyle(appModel.headerColor).shadow(radius: 2, x: 3, y: 3).padding([.leading, .bottom], 10)
                            Spacer()
                ZStack {
                    
                    
                    
                    
                    Button("TODAY", systemImage: "calendar.circle.fill", action: {
                       showDatePicker = true
                        
                    }).labelStyle(.iconOnly).font(.title).background(.white).clipShape(Circle()).foregroundStyle(appModel.headerColor).shadow(radius: 2, x: 3, y: 3).padding(.bottom, 10)
                }
                            Spacer()
                            Button("Next Month", systemImage: "arrowshape.right.circle.fill", action: {
                                nextMonth()
                                
                            }).labelStyle(.iconOnly).font(.title).background(.white).clipShape(Circle()).foregroundStyle(appModel.headerColor).shadow(radius: 2, x: 3, y: 3).padding([.bottom, .trailing], 10)
            }.popover(isPresented: $showDatePicker, content: {
                
                VStack {
                    HStack {
                        Button("Today", action: {
                            appModel.displayedDate = Date().startOfDay
                            
                        })
                        .font(Font.custom(appModel.headerFont, size: 20))
                        .padding(10)
                        .background(appModel.headerColor)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .foregroundStyle(appModel.headerColorContrast)
                        .shadow(radius: 2, x: 3, y: 3)
                        .padding([.top, .leading], 10)
                        Spacer()
                    }
                    HStack{
                        DatePicker("", selection: $appModel.displayedDate,displayedComponents: .date).datePickerStyle(.graphical)
                    }.frame(width: 300)
                }
            })


            HStack(spacing: 0) {
                if appModel.startOfWeek == .monday {
                    ForEach(viewModel.daysOfWeekMonday, id: \.self) { day in
                        Text(day)
                            .textCase(.uppercase)
                            .font(.system(size: baseFontSize * 0.85))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, paddingScale) // Use paddingScale for internal padding
                    }
                } else {
                    ForEach(viewModel.daysOfWeekSunday, id: \.self) { day in
                        Text(day)
                            .textCase(.uppercase)
                            .font(.system(size: baseFontSize * 0.85))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, paddingScale) // Use paddingScale for internal padding
                    }

                }
            }
            .background(appModel.headerColor).clipShape(RoundedRectangle(cornerRadius: 20))
            .foregroundColor(appModel.headerColorContrast)

            let columns = Array(repeating: GridItem(.flexible(), spacing: spacingScale), count: 7) // Use spacingScale for grid spacing
            
            
            LazyVGrid(columns: columns, spacing: spacingScale) {
                
                if layoutType == .elsePortrait || layoutType == .iphonePortrait {
                    ForEach(viewModel.days, id: \.self) { day in
                        
                        ZStack {
                            if day.isCurrentDay {
                                Circle()
                                    .foregroundStyle(day.isCurrentDay ? appModel.headerColor : Color.clear)
                                    .padding(paddingScale).frame(maxWidth: circleSize)
                                    
                                    
                            }
                            Text("\(day.number)")
                                .font(.system(size: baseFontSize))
                                .foregroundColor(day.isCurrentDay ? appModel.headerColorContrast : day.color)
                                .onTapGesture {
                                    let calendar = Calendar.current
                                    var dateComponents = DateComponents()
                                    dateComponents.year = day.year
                                    dateComponents.month = day.month
                                    dateComponents.day = day.number
                                    
                                    if let date = calendar.date(from: dateComponents) {
                                        appModel.displayedDate = date
                                    }
                                }
                        }
                        
                    }
                } else {
                    // Inside LazyVGrid in MiniMonthCalendarView

                    ForEach(viewModel.days, id: \.self) { day in
                        

                        Text("\(day.number)")
                            .font(.system(size: baseFontSize))
                            // Adjust padding to scale with the text
                            .frame(maxWidth: 40, maxHeight: 20)
                            .padding(paddingScale)
                            .background(day.isCurrentDay ? appModel.headerColor : Color.clear)
                            .clipShape(Circle())
                            .foregroundColor(day.color)
                            
                            .onTapGesture {
                                let calendar = Calendar.current
                                var dateComponents = DateComponents()
                                dateComponents.year = day.year
                                dateComponents.month = day.month
                                dateComponents.day = day.number

                                if let date = calendar.date(from: dateComponents) {
                                    appModel.displayedDate = date
                                }
                            }
                    }

                }
                
                
            }
                           
        }.padding(.horizontal, 10)
    
            .padding(.horizontal, 10)
            .background(.clear)
            .onAppear {
                // Initialize or update viewModel here if needed
                viewModel.updateMonth(date: appModel.displayedDate)
               
            }
            .onChange(of: appModel.displayedDate) { oldDate, newDate in
                        // Assuming you have an updateMonth method in your viewModel
                        viewModel.updateMonth(date: newDate)
                    }
                    .onChange(of: appModel.startOfWeek) { oldStartOfWeek, newStartOfWeek in
                        viewModel.updateStartOfWeek(newStartOfWeek: newStartOfWeek)
                    }
        
        }
    

}


#Preview {
   ContentView()
        .environmentObject(AppModel())
        .environmentObject(TasksUpdateNotifier())
        .modelContainer(for: [MoodEntry.self, Note.self])
}
