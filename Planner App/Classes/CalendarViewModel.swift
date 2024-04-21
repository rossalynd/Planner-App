





//
//  CalendarViewModel.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/26/24.
//

import Foundation
import SwiftUI

class CalendarViewModel: ObservableObject {
    @Published var days = [Day]()
    @Published var date = Date()
    var startOfWeek: WeekStartDay
    var daysOfWeekMonday: [String] = ["M", "Tu", "W", "Th", "F", "S", "Su"]
    var daysOfWeekSunday: [String] = ["Su", "M", "Tu", "W", "Th", "F", "S"]
    var dayColor: Color = .pink
    
    
    


    // Updated the daysOfWeek order based on typical start from Sunday. Adjust as needed.
    
    init(date: Date, startOfWeek: WeekStartDay, dayColor: Color) {
        self.date = date
        self.startOfWeek = startOfWeek
        print("Initializing with startOfWeek:", self.startOfWeek)
        self.days = self.generateDaysInMonth()
        self.dayColor = dayColor
    }

    var calendar: Calendar {
        var cal = Calendar.current
        // Correctly configure the firstWeekday based on startOfWeek
        cal.firstWeekday = self.startOfWeek == .monday ? 2 : 1
        return cal
    }

    func generateDaysInMonth() -> [Day] {
        var days = [Day]()
        let today = date
        guard let range = calendar.range(of: .day, in: .month, for: today) else {
            print("Failed to get range of days in month for date \(today)")
            return []
        }
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: calendar.startOfDay(for: today)))!

        // Adjustments here are based on the correctly set firstWeekday
        let components = calendar.dateComponents([.weekday, .year, .month], from: startOfMonth)
        let weekday = components.weekday!
        let previousMonth = calendar.date(byAdding: .month, value: -1, to: startOfMonth)!
        guard let previousMonthRange = calendar.range(of: .day, in: .month, for: previousMonth) else {
            return []
        }
        let daysToAddFromPrevMonth = weekday - calendar.firstWeekday
        let prevMonthDaysToShow = daysToAddFromPrevMonth >= 0 ? daysToAddFromPrevMonth : 7 + daysToAddFromPrevMonth

        // Correcting the range to ensure lowerBound is always <= upperBound
        let startDayIndex = max(1, previousMonthRange.count - prevMonthDaysToShow + 1)
        let endDayIndex = previousMonthRange.count

        if startDayIndex <= endDayIndex { // Ensure the range is valid
            for day in startDayIndex...endDayIndex {
                let prevMonthComponents = Calendar.current.dateComponents([.year, .month], from: previousMonth)
                days.append(Day(number: day, year: prevMonthComponents.year!, month: prevMonthComponents.month!, color: .gray))
            }
        }


        // Current month days
        for day in 1...range.count {
            let originalDate = date
            let dayDate = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)!
            let isCurrentDay = calendar.isDateInToday(dayDate)
            let selectedDate = calendar.component(.day, from: originalDate)
            let isSelectedDate = selectedDate == day
            let dayComponents = calendar.dateComponents([.year, .month], from: dayDate)
            
            if (components.year != nil), (components.month != nil) {
                let color: Color
                if isSelectedDate {
                    color = dayColor// Highlight day color
                } else if isCurrentDay {
                    color = Color("DefaultWhite") // Current day color
                } else {
                    color = Color("DefaultBlack") // Default color
                }
                days.append(Day(number: day, year: dayComponents.year!, month: dayComponents.month!, isCurrentDay: isCurrentDay, color: color))
            }
        }
        
        
        

        // Check if additional days from next month are needed to fill the last week
        let totalDays = days.count
        let extraDays = 7 - (totalDays % 7)
        if extraDays < 7 {
            let nextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
            let nextMonthComponents = Calendar.current.dateComponents([.year, .month], from: nextMonth)
            for day in 1..<extraDays {
                days.append(Day(number: day, year: nextMonthComponents.year!, month: nextMonthComponents.month!, color: .gray))
            }
        }

        return days
    }
    func startOfWeek(for date: Date) -> Date {
        var calendar: Calendar {
                var cal = Calendar.current
                cal.firstWeekday = self.startOfWeek == .monday ? 2 : 2
                return cal
            }
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        print("Func startOfWeek is date: \(String(describing: calendar.date(from: components)))")
        return calendar.date(from: components)!
    }
    func nextMonth() {
        guard let newDate = Calendar.current.date(byAdding: .month, value: 1, to: date) else { return }
        self.date = newDate
        self.days = self.generateDaysInMonth()
    }

    func previousMonth() {
        guard let newDate = Calendar.current.date(byAdding: .month, value: -1, to: date) else { return }
        self.date = newDate
        self.days = self.generateDaysInMonth()
    } 
    func updateMonth(date: Date) {
        
        self.date = date
        self.days = self.generateDaysInMonth()
    }
    
    
    func updateStartOfWeek(newStartOfWeek: WeekStartDay) {
        self.startOfWeek = newStartOfWeek
        self.days = self.generateDaysInMonth()
    }
    
}

struct Day: Identifiable, Hashable {
    let id = UUID()
    let number: Int
    let year: Int
    let month: Int
    let isCurrentDay: Bool
    let color: Color

    init(number: Int, year: Int, month: Int, isCurrentDay: Bool = false, color: Color) {
        self.number = number
        self.year = year
        self.month = month
        self.isCurrentDay = isCurrentDay
        self.color = color
    }
}
