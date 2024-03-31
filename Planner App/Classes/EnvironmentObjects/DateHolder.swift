//
//  DateHolder.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/27/24.
//

import Foundation
class DateHolder: ObservableObject {
    @Published var displayedDate: Date = Date()
    @Published var startOfWeek: WeekStartDay = WeekStartDay.monday
    
    
    func datesInWeek(from date: Date, weekStartsOn startDay: WeekStartDay) -> [Date] {
        var calendar = Calendar.current
        // Adjust the calendar based on the start day of the week
        calendar.firstWeekday = startDay == startOfWeek ? 1 : 2
        
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

enum WeekStartDay: String {
    case sunday = "Sunday"
    case monday = "Monday"
}
