//
//  AddEventView.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/25/24.
//

import SwiftUI
import EventKit

struct AddEventView: View {
    var eventStore: EKEventStore

    @EnvironmentObject var appModel: AppModel
    @State private var eventTitle: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date().addingTimeInterval(+3600)
    @State private var eventLocation: String = ""
    @State private var eventURL: String = ""
    @State private var eventNotes: String = ""
    @State private var selectedCalendar: EKCalendar?
    @Environment(\.presentationMode) var presentationMode
    @State private var eventAvailability: EKEventAvailability = .busy
    @State private var  isAllDay: Bool = false
    @State private var selectedRecurrence: RecurrenceOption = .none
    @State var showAlarmOptions = false
    @State var alarms: [EKAlarm] = []
    

    var body: some View {
        VStack {
            
            
            Form {
                HStack {
                    Text("Add Event".uppercased()).font(.title2).bold()
                }.onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                Section(header: Text("Event Details")) {
                    TextField("Title", text: $eventTitle)
                    TextField("Location", text: $eventLocation)
                    
                    if !isAllDay {
                        DatePicker("Start Date", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                        DatePicker("End Date", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                    } else {
                        DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    }
                   
                    Toggle(isOn: $isAllDay) {
                        Text("All Day Event")
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
                }
                

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
                    
                    Button(action: {
                            showAlarmOptions = true
                        }) {
                            Text("Add Alarm")
                        }
                        .actionSheet(isPresented: $showAlarmOptions) {
                            ActionSheet(title: Text("Select time before event"), buttons: alarmOptions)
                        }
                    ForEach(alarms, id: \.self) { alarm in
                        Text("\(alarm.description)")
                    }
                    .onDelete(perform: deleteAlarm)
                }
                Button("Save") {
                    if isAllDay == true {
                        let calendar = Calendar.current
                        startDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: startDate)!
                        endDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: startDate)!
                    }
                    saveEventToStore()
                    print("New Event Created: \(eventTitle)  \(startDate) \(endDate)  \(eventLocation)  \(eventURL)  \(eventNotes)  \(eventAvailability.description) \(isAllDay)  \(selectedRecurrence) \(alarms.description)")
                    presentationMode.wrappedValue.dismiss()
                }
                
            }.frame(minWidth: 400, minHeight:800)
                .onAppear(perform: fetchCalendars)
                
            
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



