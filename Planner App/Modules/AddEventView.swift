//
//  AddEventView.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/25/24.
//

import SwiftUI
import EventKit
import NaturalLanguage

struct AddEventView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appModel: AppModel

    var eventStore: EKEventStore
    @State private var userInput: String = ""
    @State private var eventTitle: String = ""
    @State private var startDate: Date? = nil
    @State private var endDate: Date? = nil
    @State private var eventLocation: String = ""
    @State private var eventURL: String = ""
    @State private var eventNotes: String = ""
    @State private var selectedCalendar: EKCalendar?
    @State private var eventAvailability: EKEventAvailability = .busy
    @State private var isAllDay: Bool = false
    @State private var selectedRecurrence: RecurrenceOption = .none
    @State private var showAlarmOptions = false
    @State private var alarms: [EKAlarm] = []

    var body: some View {
        VStack {
            Form {
                HStack {
                    Button(appModel.headerCase.apply(to:"Save"), systemImage: "plus.app.fill") {
                        saveEventToStore()
                        presentationMode.wrappedValue.dismiss()
                    }.font(Font.custom(appModel.headerFont, size: 30)).foregroundColor(appModel.headerColor)
                    Spacer()
                    Text(appModel.headerCase.apply(to:"Add Event")).font(Font.custom(appModel.headerFont, size: 30)).foregroundColor(appModel.headerColor)
                  
                    
                }.background(.clear)
                Section(header: Text("Event Details")) {
                    TextField("Add Event (e.g., Dinner with mom on Saturday at 5 PM)", text: $userInput, onEditingChanged: { _ in
                        parseInput()
                    }, onCommit: parseInput)
                    if let date = startDate {
                        Text("Event: \(eventTitle) on \(date, style: .date) at \(date, style: .time)")
                    }
                    TextField("Location", text: $eventLocation)
                    Toggle("All Day Event", isOn: $isAllDay)
                    if !isAllDay {
                        DatePicker("Start Date", selection: nonOptionalBinding($startDate, defaultValue: Date()), displayedComponents: isAllDay ? .date : [.date, .hourAndMinute])
                        DatePicker("End Date", selection: nonOptionalBinding($endDate, defaultValue: Date()), displayedComponents: [.date, .hourAndMinute])
                    } else {
                        DatePicker("Start Date", selection: nonOptionalBinding($startDate, defaultValue: Date()), displayedComponents: isAllDay ? .date : [.date, .hourAndMinute])
                    }
                }

                Section(header: Text("Calendar")) {
                    Picker("Select Calendar", selection: $selectedCalendar) {
                        ForEach(eventStore.calendars(for: .event), id: \.self) { calendar in
                            Text(calendar.title).tag(calendar as EKCalendar?)
                        }
                    }
                }

                TextField("URL", text: $eventURL)
                TextField("Notes", text: $eventNotes)

                Section(header: Text("Recurrence")) {
                    RecurrenceRuleView(selectedRecurrence: $selectedRecurrence)
                }

                Section(header: Text("Availability")) {
                    Picker("Availability", selection: $eventAvailability) {
                        Text("Busy").tag(EKEventAvailability.busy)
                        Text("Free").tag(EKEventAvailability.free)
                    }
                }

                Section(header: Text("Alarms")) {
                    Button("Add Alarm") {
                        showAlarmOptions = true
                    }
                    .actionSheet(isPresented: $showAlarmOptions) {
                        ActionSheet(title: Text("Select time before event"), buttons: alarmOptions)
                    }
                    ForEach(alarms, id: \.self) { alarm in
                        Text("\(alarm.description)")
                    }
                    .onDelete(perform: deleteAlarm)
                }

               
            }
        }.scrollContentBackground(.hidden)
            .background(.defaultWhite)
        .onAppear(perform: fetchCalendars)
    }

    
    func nonOptionalBinding<T>(_ binding: Binding<T?>, defaultValue: T) -> Binding<T> {
        Binding<T>(
            get: { binding.wrappedValue ?? defaultValue },
            set: { binding.wrappedValue = $0 }
        )
    }

    func parseInput() {
            let dates = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
            if let matches = dates?.matches(in: userInput, options: [], range: NSRange(location: 0, length: userInput.utf16.count)),
               let match = matches.first {
                startDate = match.date
                endDate = startDate?.addingTimeInterval(3600) // Default to one hour later
                let dateRange = Range(match.range, in: userInput)!
                eventTitle = String(userInput[..<dateRange.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                // No date found, consider everything as potential title
                eventTitle = userInput
            }
        }

        
    func saveEventToStore() {
        let event = EKEvent(eventStore: eventStore)
        event.title = eventTitle
        event.startDate = startDate
        event.endDate = endDate
        event.location = eventLocation
        event.notes = eventNotes
        event.availability = eventAvailability
        event.isAllDay = isAllDay
        alarms.forEach { event.addAlarm($0) }
        if let selectedCalendar = selectedCalendar {
                event.calendar = selectedCalendar
            } else {
                // Handle the case where no calendar is selected, or provide a default
                print("No calendar selected")
                return
            }
        
        // Handle recurrence rule
        switch selectedRecurrence {
        case .daily:
            event.addRecurrenceRule(EKRecurrenceRule(recurrenceWith: .daily, interval: 1, end: nil))
        case .weekly:
            event.addRecurrenceRule(EKRecurrenceRule(recurrenceWith: .weekly, interval: 1, end: nil))
        // Add other cases as necessary
        default:
            break
        }
        
        do {
            try eventStore.save(event, span: .thisEvent)
            print("Event saved")
        } catch {
            print("Error saving event: \(error)")
        }
    }


    var cancelButton: some View {
        Button("Cancel") {
            presentationMode.wrappedValue.dismiss()
        }
    }

    func fetchCalendars() {
        let calendars = eventStore.calendars(for: .event) // Fetches all calendars that can have events
        if let firstCalendar = calendars.first {
            selectedCalendar = firstCalendar // Default to the first calendar if available
        }
    }
    
   
    
   






    
    var alarmOptions: [ActionSheet.Button] {
        let buttons: [ActionSheet.Button] = [
            .default(Text("At time of event")) { addAlarm(minutesBefore: 0) },
            .default(Text("5 minutes before")) { addAlarm(minutesBefore: 5) },
            .default(Text("15 minutes before")) { addAlarm(minutesBefore: 15) },
            .default(Text("30 minutes before")) { addAlarm(minutesBefore: 30) },
            .default(Text("1 hour before")) { addAlarm(minutesBefore: 60) },
            .default(Text("2 hours before")) { addAlarm(minutesBefore: 120) },
            .default(Text("1 day before")) { addAlarm(minutesBefore: 1440) },
            .default(Text("2 days before")) { addAlarm(minutesBefore: 2880) },
            .cancel()
        ]
        return buttons
    }

    func addAlarm(minutesBefore: Int) {
        let alarm = EKAlarm(relativeOffset: TimeInterval(-minutesBefore * 60))
        alarms.append(alarm)

    }
    func deleteAlarm(at offsets: IndexSet) {
        alarms.remove(atOffsets: offsets)
    }



    
    
}

extension EKEventAvailability {
    var description: String {
        switch self {
        case .notSupported:
            return "Not Supported"
        case .free:
            return "Free"
        case .busy:
            return "Busy"
        case .tentative:
            return "Tentative"
        case .unavailable:
            return "Unavailable"
        @unknown default:
            return "Unknown"
        }
    }
}


extension EKAlarm {
    open override var description: String {
        if let date = self.absoluteDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            return "Absolute date: \(dateFormatter.string(from: date))"
        } else if self.relativeOffset == 0 {
            return "At time of event"
        } else {
            let totalSeconds = self.relativeOffset
            let days = Int(totalSeconds / 86400)
            let hours = Int((totalSeconds.truncatingRemainder(dividingBy: 86400)) / 3600)
            let minutes = Int((totalSeconds.truncatingRemainder(dividingBy: 3600)) / 60)

            var description = ""
            if days != 0 {
                description += "\(abs(days)) \(days == 1 ? "day" : "days") "
            }
            if hours != 0 {
                description += "\(abs(hours)) \(hours == 1 ? "hour" : "hours") "
            }
            if minutes != 0 || (days == 0 && hours == 0) {
                description += "\(abs(minutes)) \(minutes == 1 ? "minute" : "minutes") "
            }
            return description.trimmingCharacters(in: .whitespaces) + " before"
        }
    }
}



extension NLTagger {
    static func parseDate(from string: Substring) -> Date? {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
        let matches = detector?.matches(in: String(string), options: [], range: NSRange(location: 0, length: string.utf16.count))
        return matches?.first?.date
    }
}


#Preview {
    AddEventView(eventStore: EKEventStore())
        .environmentObject(AppModel())
}
