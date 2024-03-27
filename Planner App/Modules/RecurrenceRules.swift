//
//  RecurrenceRules.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/25/24.
//



import SwiftUI
import EventKit

enum RecurrenceOption: String, CaseIterable, Identifiable {
    case none = "None"
    case daily = "Daily"
    case weekly = "Weekly"
    case biweekly = "Biweekly"
    case monthly = "Monthly"
    case yearly = "Yearly"

    var id: String { self.rawValue }

    func toEKRecurrenceRule() -> EKRecurrenceRule? {
        switch self {
        case .none:
            return nil
        case .daily:
            return EKRecurrenceRule(recurrenceWith: .daily, interval: 1, end: nil)
        case .weekly:
            return EKRecurrenceRule(recurrenceWith: .weekly, interval: 1, end: nil)
        case .biweekly:
            return EKRecurrenceRule(recurrenceWith: .weekly, interval: 2, end: nil)
        case .monthly:
            return EKRecurrenceRule(recurrenceWith: .monthly, interval: 1, end: nil)
        case .yearly:
            return EKRecurrenceRule(recurrenceWith: .yearly, interval: 1, end: nil)
        }
    }
}

struct RecurrenceRuleView: View {
    @Binding var selectedRecurrence: RecurrenceOption

    var body: some View {
        Picker("Repeat", selection: $selectedRecurrence) {
            ForEach(RecurrenceOption.allCases) { option in
                Text(option.rawValue).tag(option)
            }
        }
    }
}

// Example Usage in your ContentView

   

   
