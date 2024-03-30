//
//  MiniMonthCalendarView.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/21/24.
//

import SwiftUI

struct MiniMonthCalendarView: View {
   
    @EnvironmentObject var dateHolder: DateHolder
    var scale: SpaceView.Scale
    private var viewModel: CalendarViewModel {
           CalendarViewModel(date: dateHolder.displayedDate)
       }
    
    private var baseFontSize: CGFloat {
        switch scale {
        case .small: return 14 // Smaller parent view
        case .medium: return 16 // Medium parent view
        case .large: return 18 // Larger parent view
        }
    }
    
    private var paddingScale: CGFloat {
        switch scale {
        case .small: return 1 // Reduced padding for smaller view
        case .medium: return 3 // Standard padding for medium view
        case .large: return 6 // Increased padding for larger view
        }
    }
    
    private var spacingScale: CGFloat {
        switch scale {
        case .small: return 1 // Tighter spacing for smaller view
        case .medium: return 3 // Standard spacing for medium view
        case .large: return 4 // Looser spacing for larger view
        }
    }
    private func previousMonth() {
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .month, value: -1, to: dateHolder.displayedDate) {
            dateHolder.displayedDate = newDate
        }
    }
    private func nextMonth() {
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .month, value: 1, to: dateHolder.displayedDate) {
            dateHolder.displayedDate = newDate
        }
    }
    var body: some View {
        VStack(spacing: spacingScale) { // Use spacingScale for Vstack spacing
           
            HStack {
                            Button("Previous Month", systemImage: "arrowshape.left.circle.fill", action: {
                                previousMonth()
                                
                            }).labelStyle(.iconOnly).font(.title).background(.white).clipShape(Circle()).foregroundStyle(Color.black).shadow(radius: 2, x: 3, y: 3).padding([.leading, .bottom], 10)
                            Spacer()
                ZStack {
                    
                    Text("TODAY").font(.headline).padding(5).background(Color("DefaultWhite")).clipShape(RoundedRectangle(cornerRadius: 20)).foregroundStyle(Color("DefaultWhite")).padding(.bottom, 10).shadow(radius: 2, x: 3, y: 3)
                    
                    
                    Button("TODAY   ", action: {
                        dateHolder.displayedDate = Date()
                    }).font(.caption).padding(5).bold().background(.black).clipShape(RoundedRectangle(cornerRadius: 20)).foregroundStyle(.white).padding(.bottom, 10)
                }
                            Spacer()
                            Button("Next Month", systemImage: "arrowshape.right.circle.fill", action: {
                                nextMonth()
                                
                            }).labelStyle(.iconOnly).font(.title).background(.white).clipShape(Circle()).foregroundStyle(Color.black).shadow(radius: 2, x: 3, y: 3).padding([.bottom, .trailing], 10)
                        }


            HStack(spacing: 0) {
                ForEach(viewModel.daysOfWeek, id: \.self) { day in
                    Text(day)
                        .textCase(.uppercase)
                        .font(.system(size: baseFontSize * 0.85))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, paddingScale) // Use paddingScale for internal padding
                }
            }
            .background(Color.black).clipShape(RoundedRectangle(cornerRadius: 20))
            .foregroundColor(.white)

            let columns = Array(repeating: GridItem(.flexible(), spacing: spacingScale), count: 7) // Use spacingScale for grid spacing
            LazyVGrid(columns: columns, spacing: spacingScale) { // And here
                ForEach(viewModel.days, id: \.self) { day in
                    Text("\(day.number)")
                        .font(.system(size: baseFontSize))
                        .padding(paddingScale) // Adjust padding to scale with the text
                        .background(day.isCurrentDay ? Color("DefaultBlack") : Color.clear)
                        .clipShape(Circle())
                        .foregroundColor(day.color)
                        .onTapGesture {
                            let calendar = Calendar.current
                            var dateComponents = DateComponents()
                            dateComponents.year = day.year
                            dateComponents.month = day.month
                            dateComponents.day = day.number

                            if let date = calendar.date(from: dateComponents) {
                                dateHolder.displayedDate = date
                            }
                        }
                }
            }
                           
        }.padding(.horizontal, 10)
            .onChange(of: dateHolder.displayedDate) { oldDate, newDate in
                
                print("date updated to \(newDate.formatted(date: .numeric, time: .omitted)) from \(oldDate.formatted(date: .numeric, time: .omitted))")
                
                viewModel.updateMonth(date: newDate)
                
                
                
            }
      Spacer()
        
    }
    
   
}







#Preview {
    ContentView()
        .environmentObject(DateHolder())
        .environmentObject(ThemeController())
}
