//
//  DateHolder.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/27/24.
//

import Foundation
class DateHolder: ObservableObject {
    @Published var displayedDate: Date = Date()
    
    func updateDate(to newDate: Date, changeHandler: (Date, Date) -> Void) {
        let currentDate = self.displayedDate
        self.displayedDate = newDate
        changeHandler(currentDate, newDate)
    }
}
