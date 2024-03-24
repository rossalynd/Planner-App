//
//  MiniMonthCalendarView.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/21/24.
//

import SwiftUI

struct MiniMonthCalendarView: View {
    @ObservedObject var viewModel = CalendarViewModel()
    @EnvironmentObject var dateHolder: DateHolder
    var scale: SpaceView.Scale

    private var baseFontSize: CGFloat {
        switch scale {
        case .small: return 14 // Smaller parent view
        case .medium: return 16 // Medium parent view
        case .large: return 18 // Larger parent view
        }
    }
    
    private var paddingScale: CGFloat {
        switch scale {
        case .small: return 2 // Reduced padding for smaller view
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

    var body: some View {
        VStack(spacing: spacingScale) { // Use spacingScale for Vstack spacing
           

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
            
            
               
        }.padding(10)
      
        
        
    }
    
   
}

class CalendarViewModel: ObservableObject {
    @Published var days = [Day]()
    let daysOfWeek = ["Su", "M", "Tu", "W", "Th", "F", "S"]

    init() {
        self.days = self.generateDaysInMonth()
    }

    func generateDaysInMonth() -> [Day] {
        var days = [Day]()
        let calendar = Calendar.current
        let today = Date()
        let range = calendar.range(of: .day, in: .month, for: today)!
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: calendar.startOfDay(for: today)))!
        
        let weekday = calendar.component(.weekday, from: startOfMonth)
        let previousMonth = calendar.date(byAdding: .month, value: -1, to: startOfMonth)!
        let previousMonthRange = calendar.range(of: .day, in: .month, for: previousMonth)!
        
        let daysInPreviousMonthToShow = weekday - 1
        let startDayOfPreviousMonthToShow = previousMonthRange.count - daysInPreviousMonthToShow + 1
        
        let components = Calendar.current.dateComponents([.year, .month], from: previousMonth)
        let previousMonthYear = components.year!
        let previousMonthIndex = components.month!

        for day in startDayOfPreviousMonthToShow...previousMonthRange.count {
            days.append(Day(number: day, year: previousMonthYear, month: previousMonthIndex, color: .gray))
        }

        
        for day in 1...range.count {
            let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)!
            let isCurrentDay = calendar.isDateInToday(date)
            let components = calendar.dateComponents([.year, .month], from: date)
            if let year = components.year, let month = components.month {
                days.append(Day(number: day, year: year, month: month, isCurrentDay: isCurrentDay, color: isCurrentDay ? .white : Color("DefaultBlack")))
            }
        }

        
        return days
    }
    
}

struct Day: Identifiable, Hashable {
    let id = UUID()
    let number: Int
    let year: Int
    let month: Int
    let isCurrentDay: Bool
    let isDisplayedDate: Bool
    let color: Color

    init(number: Int, year: Int, month: Int, isCurrentDay: Bool = false, isDisplayedDate: Bool = false, color: Color = .black) {
        self.number = number
        self.year = year
        self.month = month
        self.isCurrentDay = isCurrentDay
        self.isDisplayedDate = isDisplayedDate
        self.color = color
    }
}







#Preview {
    ContentView()
        .environmentObject(DateHolder())
}
