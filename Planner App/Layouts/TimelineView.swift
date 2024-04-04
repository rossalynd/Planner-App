//
//  TimelineView.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 4/1/24.
//

import SwiftUI
import EventKit

struct TimelineView: View {
    @EnvironmentObject var appModel: AppModel
    var layoutType: LayoutType
    var scale: SpaceView.Scale
    var date: Date
    private var store = EKEventStore()
    @State private var permissionGranted = false
    @State private var showingAlert = false
    @State private var events: [EKEvent] = []
    @State private var allDayEvents: [EKEvent] = []
    @State private var timedEvents: [EKEvent] = []
    @State private var showingEventView = true
    @State private var showingAddEventView = false
    @State private var expandedEventID: String? = nil
  

    
    public init(layoutType: LayoutType, scale: SpaceView.Scale, date: Date) {
            self.scale = scale
            self.layoutType = layoutType
            self.date = date
        }

    private var columns: [GridItem] {
        
        switch scale {
        case .small: return [GridItem(.fixed(150))] // Smaller parent view
        case .medium: return [GridItem(.fixed(200))]// Medium parent view
        case .large: return [GridItem(.fixed(200))]
        }
    }
    
    private var eventFontSize: Font {
        switch layoutType {
        case .elseLandscape: return .caption
        case .iphoneLandscape: return .subheadline
        case .elsePortrait: return .headline
        case .iphonePortrait: return .headline
        }
    }
    private var eventTimeFontSize: Font {
        switch layoutType {
        case .elseLandscape: return .caption2
        case .iphoneLandscape: return .caption
        case .elsePortrait: return .subheadline
        case .iphonePortrait: return .subheadline
        }
    }
    var body: some View {
        GeometryReader { geometry in
            
            let totalHeight = geometry.size.height // The total height for the timeline.
            let heightPerHour = totalHeight / 12
            let heightPerMinute = heightPerHour / 60
            
            VStack {
                if appModel.calendarPermissionGranted {
                    
                    ZStack {
                        Color.blue.frame(maxHeight: .infinity)
                            .edgesIgnoringSafeArea(.all)
                        VStack {
                            allDayEventsView

                            ScrollView {
                                        
                                ForEach(0..<24, id: \.self) { hour in
                                    ZStack(alignment: .topLeading) {
                                        HStack {
                                            Text("\(self.formatHour(hour: hour))")
                                            Spacer()
                                        }
                                        .frame(height: heightPerHour) // Fixed height for the hour slot
                                        .padding(.leading, 20)
                                        Divider()
                                        // Use GeometryReader to position events absolutely within the hour slot
                                        GeometryReader { geometry in
                                            ForEach(eventsGroupedByHour()[hour] ?? [], id: \.eventIdentifier) { event in
                                                if let eventPosition = self.calculateEventPosition(event: event, heightPerMinute: heightPerMinute) {
                                                
                                                
                                                    VStack {
                                                      
                                                            
                                                        HStack {
                                                            Text(event.title.uppercased()).font(.caption)
                                                                .bold().lineLimit(2)
                                                            Text("\(event.startDate, style: .time) - \(event.endDate, style: .time)")
                                                                .font(.caption)
                                                       Spacer()
                                                            
                                                            
                                                        }.frame(maxWidth: .infinity).border(.green).padding(.top, 20).padding()
                                                   
                                                          
                                                        
                                                    }
                                                    .position(x: geometry.size.width / 2, y: 0)
                                                    .background(Color(event.calendar.cgColor))
                                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                                    .shadow(radius: 3, x: 3, y: 3)
                                                    .frame(width: geometry.size.width / 1.2, height: eventPosition.height * 1.125)
                                                    .padding(.leading, geometry.size.width / 1.2)
                                                   
                                                }
                                            }
                                        }
                                    }
                                }
                                                   
                                               
                                                    
                                                    
                                                    
                                                    
                                                    
                                               
          
                                        
                                    
                                    
                                
                                .onAppear {
                                    self.loadEvents()
                                }
                            }
                        }
                           
                       
                        }
                    
                    
                } else {
                    VStack(alignment: .center) {
                        Text("\(date)")
                    Text("Unable to retrieve events. Please enable access to Calendar in Settings.")
                        Button("Request Calendar Access") {
                            appModel.requestCalendarAccess()
                        }
                    }
                        .onAppear(perform: appModel.requestCalendarAccess)
                }
                
            }
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("Need Calendar Access"),
                    message: Text("Calendar access request failed. Please go to the Settings app to allow access to Calendar."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    func calculateEventPosition(event: EKEvent, heightPerMinute: CGFloat) -> (startY: CGFloat, height: CGFloat)? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)

        // Calculate total minutes from the start of the day to the event's start time
        let eventStartMinutes = calendar.dateComponents([.hour, .minute], from: startOfDay, to: event.startDate).hour! * 60 +
                                calendar.dateComponents([.hour, .minute], from: startOfDay, to: event.startDate).minute!
        let eventDurationMinutes = Int(event.endDate.timeIntervalSince(event.startDate) / 60)

        let startY = CGFloat(eventStartMinutes) * heightPerMinute
        let height = CGFloat(eventDurationMinutes) * heightPerMinute

        return (startY, height)
    }



    func calculateEventHeight(for event: EKEvent, at hour: Int) -> CGFloat {
        let calendar = Calendar.current
        let eventStartDate = calendar.startOfDay(for: event.startDate)
        let eventEndDate = calendar.startOfDay(for: event.endDate)
        
        let startHour = calendar.component(.hour, from: event.startDate)
        let endHour = calendar.component(.hour, from: event.endDate) + (eventEndDate > eventStartDate ? 24 : 0) // Adjust for events spanning past midnight
        
        let totalHeightPerHour: CGFloat = 50 // Dynamically calculate based on available height
        
        var height: CGFloat = 0
        
        if startHour <= hour && hour <= endHour {
            if startHour == hour { // Event starts this hour
                let startMinute = calendar.component(.minute, from: event.startDate)
                let heightForStartHour = CGFloat(60 - startMinute) / 60.0 * totalHeightPerHour
                height = max(height, heightForStartHour)
            }
            if endHour == hour { // Event ends this hour
                let endMinute = calendar.component(.minute, from: event.endDate)
                let heightForEndHour = CGFloat(endMinute) / 60.0 * totalHeightPerHour
                height = max(height, heightForEndHour)
            }
            if startHour < hour && hour < endHour { // Event spans the entire hour
                height = totalHeightPerHour
            }
        }
        
        return height
    }


    func formatHour(hour: Int) -> String {
            let hourMod = hour % 12
            let suffix = hour < 12 ? "AM" : "PM"
            return "\(hourMod == 0 ? 12 : hourMod) \(suffix)"
        }
    
    var allDayEventsView: some View {
        //All Day Events
            ScrollView(.horizontal, showsIndicators: false) {
                ScrollViewReader { scrollView in
                    HStack {
                        Color.clear.frame(width: 0, height: 0)
                                .id("start")
                        ForEach(allDayEvents.indices, id: \.self) { index in
                            let event = allDayEvents[index]
                            NavigationLink {
                                EventInfoView(event: event)
                            } label: {
                                ADEventView(event: event, backgroundColor: Color(event.calendar.cgColor), fontSize: eventFontSize, expandedEventId: $expandedEventID).id(event.eventIdentifier)
                            }
                            
                        }
                    }
                        .onChange(of: expandedEventID) { oldID, newID in
                            withAnimation {
                                if let newID = newID {
                                    scrollView.scrollTo(newID, anchor: .center)
                                } else {
                                    scrollView.scrollTo("start", anchor: .leading)
                                }
                            }
                        }
                }
            }.padding()
    }
    
    struct EventView: View {
        var event: EKEvent
        var hour: Int
        var width: CGFloat
        var height: CGFloat
        var backgroundColor: Color
        var fontSize: Font
        var timeFontSize: Font
        var scale: SpaceView.Scale

        init(event: EKEvent, hour: Int, width: CGFloat, height: CGFloat, backgroundColor: Color, fontSize: Font, timeFontSize: Font, scale: SpaceView.Scale) {
            self.event = event
            self.hour = hour
            self.width = width
            self.height = height
            self.backgroundColor = backgroundColor
            self.fontSize = fontSize
            self.timeFontSize = timeFontSize
            self.scale = scale
        }



        var body: some View {
            VStack {
                HStack {
                    if scale != .large {
                        VStack(spacing: -1) {
                            HStack {
                                Text("\(event.startDate, style: .time) - \(event.endDate, style: .time)")
                                    .font(timeFontSize)
                                Spacer()
                            }
                            HStack {
                                Text(event.title.uppercased()).font(fontSize)
                                    .bold().lineLimit(2)
                                Spacer()
                            }
                        }
                    } else {
                        HStack(spacing: -5) {
                            Text("\(event.startDate, style: .time) - \(event.endDate, style: .time)")
                                .font(timeFontSize)
                            Spacer()
                            Text(event.title.uppercased()).font(fontSize)
                                .bold()
                        }
                    }
                }
                
            }
            
        }

       
    }

    struct ADEventView: View {
        var event: EKEvent
        var backgroundColor: Color
        var fontSize: Font
        @State private var showEventTitle = false
        @Binding var expandedEventId: String?

        init(event: EKEvent, backgroundColor: Color, fontSize: Font, expandedEventId: Binding<String?>) {
            self.event = event
            self.backgroundColor = backgroundColor
            self.fontSize = fontSize
            self._expandedEventId = expandedEventId
        }

        var body: some View {
            Button(action: {
                withAnimation {
                    showEventTitle.toggle()
                    if self.expandedEventId == event.eventIdentifier {
                        self.expandedEventId = nil // Collapse if it's already expanded
                    } else {
                        self.expandedEventId = event.eventIdentifier // Expand the event
                    }
                }
            }) {
                HStack() {
                    icon
                    
                    if showEventTitle {
                        Text(event.title.uppercased())
                            .font(fontSize)
                            .bold()
                            .foregroundColor(.black)
                            .padding(.trailing, 5)
                            
                        
                    }
                            
                    
                }
                .padding(5)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(radius: 3, x: 3, y: 3).padding(.bottom, 5)
                
                
            }
           
        }

        @ViewBuilder
        var icon: some View {
            if event.title.contains("Birthday") {
                Image(systemName: "gift.fill").iconStyle
            } else if event.calendar.title.contains("Holiday") {
                Image(systemName: "star.circle.fill").iconStyle
            } else if event.calendar.title.contains("Goals") {
                Image(systemName: "trophy.circle.fill").iconStyle
            } else if event.calendar.title.contains("Bills") {
                Image(systemName: "creditcard.circle.fill").iconStyle
            } else {
                Image(systemName: "calendar.circle.fill").iconStyle
            }
        }
    }

    

    

    func eventsGroupedByHour() -> [Int: [EKEvent]] {
        var eventsByHour = [Int: [EKEvent]]()

        for event in timedEvents {
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: event.startDate)

            if eventsByHour[hour] != nil {
                eventsByHour[hour]?.append(event)
            } else {
                eventsByHour[hour] = [event]
            }
        }

        return eventsByHour
    }

    func eventSpansThisHour(_ event: EKEvent, hour: Int) -> Bool {
        let calendar = Calendar.current
        let eventStartHour = calendar.component(.hour, from: event.startDate)
        let eventEndHour = calendar.component(.hour, from: event.endDate)
        let eventStartDay = calendar.component(.day, from: event.startDate)
        let eventEndDay = calendar.component(.day, from: event.endDate)

        // Adjust for events that span past midnight (crossing into the next day)
        let adjustedEndHour = eventEndDay > eventStartDay ? eventEndHour + 24 : eventEndHour

        // Check if the event spans the current hour
        let isSpanningHour = (eventStartHour <= hour && hour < adjustedEndHour) ||
                             (eventStartHour <= hour + 24 && hour + 24 < adjustedEndHour)
        
        // Special case for events that end exactly at the top of an hour
        if calendar.component(.minute, from: event.endDate) == 0 && eventEndHour == hour {
            return true
        }

        return isSpanningHour
    }


    

    func loadEvents() {
        let calendars = appModel.eventStore.calendars(for: .event)
        var startDate = date
        if date.formatted(date: .numeric, time: .omitted) == Date().formatted(date: .numeric, time: .omitted) {
            startDate = Date()
        } else {
            startDate = date
        }
        
        let endDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: startDate)!
        
        let predicate = appModel.eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
        
        let fetchedEvents = appModel.eventStore.events(matching: predicate).sorted { $0.startDate < $1.startDate }
        
        // Split events into all-day and timed
        allDayEvents = fetchedEvents.filter { $0.isAllDay }
        
        timedEvents = fetchedEvents.filter { !$0.isAllDay }
    }


    private func formatDayInfoDay(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"
        let dayString = dateFormatter.string(from: date)
        let firstLetterOfDay = String(dayString.prefix(1))
        return firstLetterOfDay
    }
    private func formatDayInfoDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "d" // Get the day of the month.
        let dayOfMonth = dateFormatter.string(from: date)
        
        return dayOfMonth // Combine the first letter with the day of the month.
    }
    

}


