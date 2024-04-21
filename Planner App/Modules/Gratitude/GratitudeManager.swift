//
//  GratitudeManager.swift
//  Planner App
//
//  Created by Rosie on 4/13/24.
//

import Foundation

class GratitudeManager {
    static let shared = GratitudeManager()
    private var gratitudeEntries: [GratitudeEntry] = []
    
    func gratitudeText(for date: Date) -> String {
        if let latestEntry = gratitudeEntries.filter({ Calendar.current.isDate($0.date, inSameDayAs: date) }).sorted(by: { $0.date > $1.date }).first {
            return latestEntry.text
        }
        return ""
    }
    
    func saveGratitude(text: String, for date: Date) {
        let entry = GratitudeEntry(date: date, text: text)
        gratitudeEntries.append(entry)
    }
}

struct GratitudeEntry: Identifiable {
    let id = UUID()
    let date: Date
    let text: String
}
