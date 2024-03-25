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
                                
                            }).labelStyle(.iconOnly).font(.title).background(.white).clipShape(Circle()).foregroundStyle(Color("DefaultBlack")).padding([.leading, .bottom], 10).shadow(radius: 2, x: 3, y: 3)
                            Spacer()
                Button("TODAY", action: {
                    dateHolder.displayedDate = Date()
                }).font(.headline).padding(5).background(.white).clipShape(RoundedRectangle(cornerRadius: 20)).foregroundStyle(Color("DefaultBlack")).shadow(radius: 2, x: 3, y: 3)
                            Spacer()
                            Button("Next Month", systemImage: "arrowshape.right.circle.fill", action: {
                                nextMonth()
                                
                            }).labelStyle(.iconOnly).font(.title).background(.white).clipShape(Circle()).foregroundStyle(Color("DefaultBlack")).padding([.bottom, .trailing], 10).shadow(radius: 2, x: 3, y: 3)
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
      
        
    }
    
   
}

class CalendarViewModel: ObservableObject {
    @Published var days = [Day]()
    @Published var date = Date()
    let daysOfWeek = ["Su", "M", "Tu", "W", "Th", "F", "S"]

    init(date: Date) {
        self.date = date
        self.days = self.generateDaysInMonth()
    }

    func generateDaysInMonth() -> [Day] {
        var days = [Day]()
        let calendar = Calendar.current
        let today = date
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
            let originalDate = date
            let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)!
            let selectedDate = calendar.component(.day, from: originalDate)
            let isCurrentDay = calendar.isDateInToday(date)
            let isSelectedDate = selectedDate == day
            let components = calendar.dateComponents([.year, .month], from: date)
            if let year = components.year, let month = components.month {
                
                let color: Color
                            if isCurrentDay {
                                color = .white // Current day color
                            } else if isSelectedDate {
                                color = .pink // Highlight day color
                            } else {
                                color = Color("DefaultBlack") // Default color
                            }
                
                days.append(Day(number: day, year: year, month: month, isCurrentDay: isCurrentDay, color: color))
            }
        }
        
        // Calculate the number of days to show for the next month
        let endOfWeekday = calendar.component(.weekday, from: calendar.date(byAdding: .day, value: range.count - 1, to: startOfMonth)!)
        let daysInNextMonthToShow = 7 - endOfWeekday
        if daysInNextMonthToShow > 0 {
            let nextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
            let componentsNextMonth = Calendar.current.dateComponents([.year, .month], from: nextMonth)
            let nextMonthYear = componentsNextMonth.year!
            let nextMonthIndex = componentsNextMonth.month!

            for day in 1...daysInNextMonthToShow {
                days.append(Day(number: day, year: nextMonthYear, month: nextMonthIndex, color: .gray))
            }
        }
        
        return days
    }

    
    func nextMonth1(date: Date) {
          let calendar = Calendar.current
          self.days = self.generateDaysInMonth()
          
      }

      func previousMonth1(date: Date) {
          let calendar = Calendar.current
          self.days = self.generateDaysInMonth()
          
      }
    func nextMonth(date: Date) {
          let calendar = Calendar.current
          if let newDate = calendar.date(byAdding: .month, value: -1, to: date) {
              self.date = newDate
              self.days = self.generateDaysInMonth()
          }
      }

      func previousMonth(date: Date) {
          let calendar = Calendar.current
          if let newDate = calendar.date(byAdding: .month, value: 1, to: date) {
              self.date = newDate
              self.days = self.generateDaysInMonth()
          }
      }
    func updateMonth(date: Date) {
        
        self.date = date
        print(date)
        self.days = self.generateDaysInMonth()
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
