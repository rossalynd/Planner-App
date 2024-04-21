//
//  MonthlyCalendarView.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 4/21/24.
//

import SwiftUI

import SwiftUI

struct MonthlyCalendarView: View {
    @State private var selectedDate = Date()
    @EnvironmentObject var appModel: AppModel
    private var year: Int
    private var month: Int
    let daysInWeek = 7
    let calendar = Calendar.current

    init(year: Int, month: Int) {
        self.year = year
        self.month = month
    }
    
    private var days: [String] {
        let weekSymbols = calendar.shortWeekdaySymbols
        return weekSymbols
    }
    
    private var numberOfDaysInMonth: Int {
        let dateComponents = DateComponents(year: year, month: month)
        let date = calendar.date(from: dateComponents)!
        let range = calendar.range(of: .day, in: .month, for: date)!
        return range.count
    }
    
    private var firstDayOfMonth: Date {
        let dateComponents = DateComponents(year: year, month: month)
        return calendar.date(from: dateComponents)!
    }
    
    private var startingSpaces: Int {
        let weekDay = calendar.component(.weekday, from: firstDayOfMonth)
        return (weekDay - 1) % daysInWeek
    }
    
    var body: some View {
        VStack {
            // Weekday headers
            HStack {
                ForEach(days, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Days in month grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: daysInWeek)) {
                ForEach(0..<startingSpaces, id: \.self) { _ in
                    Text("")
                }
                ForEach(1..<(numberOfDaysInMonth + 1)) { day in
                    Text("\(day)")
                        .frame(width: 40, height: 40)
                        .background(self.isSelected(day: day) ? Color.blue : Color.clear)
                        .clipShape(Circle())
                        .onTapGesture {
                            let dateComponents = DateComponents(year: self.year, month: self.month, day: day)
                            self.selectedDate = self.calendar.date(from: dateComponents) ?? appModel.displayedDate
                        }
                }
            }
        }
        .padding()
    }
    
    private func isSelected(day: Int) -> Bool {
        return calendar.isDate(selectedDate, inSameDayAs: calendar.date(from: DateComponents(year: year, month: month, day: day))!)
    }
}

