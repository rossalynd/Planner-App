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
    let daysOfWeek = ["Su", "M", "Tu", "W", "Th", "F", "S"]

    init(date: Date) {
        self.date = date
        self.days = self.generateDaysInMonth()
    }

    func generateDaysInMonth() -> [Day] {
        var days = [Day]()
        let calendar = Calendar.current
        let today = date
        guard let range = calendar.range(of: .day, in: .month, for: today) else {
            print("Failed to get range of days in month for date \(today)")
            return []
        }
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: calendar.startOfDay(for: today)))!

        let weekday = calendar.component(.weekday, from: startOfMonth)
        let previousMonth = calendar.date(byAdding: .month, value: -1, to: startOfMonth)!
        guard let previousMonthRange = calendar.range(of: .day, in: .month, for: previousMonth) else {
            print("Failed to get range of days in previous month for startOfMonth \(startOfMonth)")
            return []
        }
        
        
        let components = Calendar.current.dateComponents([.year, .month], from: previousMonth)
        let previousMonthYear = components.year!
        let previousMonthIndex = components.month!

        if weekday > 1 {
            let daysInPreviousMonthToShow = weekday - 1
            // Ensure we calculate the start day in the previous month correctly
            let startDayOfPreviousMonthToShow = previousMonthRange.count - daysInPreviousMonthToShow + 1
            
            for day in startDayOfPreviousMonthToShow...previousMonthRange.count {
                days.append(Day(number: day, year: previousMonthYear, month: previousMonthIndex, color: .gray))
            }
           
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



