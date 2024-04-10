//
//  TimelineHorizontal.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 4/8/24.
//

import SwiftUI
import EventKit

struct HorizontalTimelineView: View {
    @EnvironmentObject var appModel: AppModel
    var layoutType: LayoutType
    var scale: SpaceView.Scale
    var date: Date
    private var store = EKEventStore()
    @State private var showingAlert = false
    @State private var events: [EKEvent] = []
    @State private var permissionGranted = false
    @State private var allDayEvents: [EKEvent] = []
    @State private var timedEvents: [EKEvent] = []
    @State private var showingEventView = true
    @State private var showingAddEventView = false
    @State private var expandedEventID: String? = nil
    @State private var startHour: Int = 8
    
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

    init(layoutType: LayoutType, scale: SpaceView.Scale, date: Date) {
        self.date = date
        self.scale = scale
        self.layoutType = layoutType

    }


    var body: some View {
        GeometryReader { geometry in
            HStack {
               
                ScrollViewReader { scrollView in
                    VStack {
                        
                    ScrollView(.horizontal, showsIndicators: false) {
                        
                            HStack(spacing: 0) {
                                ForEach(0..<24) { hour in
                                    HourColumn(hour: hour, width: geometry.size.width / 8, segments: 2).font(.caption2).foregroundStyle(Color(appModel.headerColor))
                                        .id(hour)
                                }
                            }.frame(maxHeight: .infinity)
                                .overlay(
                                    horizontalEventLayers(widthPerHour: geometry.size.width / 8, height: geometry.size.height),
                                    alignment: .topLeading
                                )
                        }.frame(maxHeight: geometry.size.height)
                            .onAppear {
                                loadEvents()
                                
                                scrollView.scrollTo("6-0", anchor: .leading)
                                
                            }
                            .onChange(of: appModel.displayedDate) {
                                loadEvents()
                            }
                    }
                }
            }
            
        }
        
    }
    
    
    
    // Helper function to determine if two events overlap
    private func eventsOverlap(_ event1: EKEvent, _ event2: EKEvent) -> Bool {
        let endBuffer = event1.endDate.addingTimeInterval(3600) // Adding 1 hour buffer
        return event1.startDate < endBuffer && event2.startDate < event1.endDate
    }

    
    
    private func horizontalEventLayers(widthPerHour: CGFloat, height: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            ForEach(timedEvents, id: \.eventIdentifier) { event in
                if let (startX, width) = calculateEventPositionHorizontally(event: event, widthPerHour: widthPerHour) {
                    let verticalOffset = calculateVerticalOffset(event)
                    let eventHeight = height / 8 // Adjust the height of each event rectangle

                    ZStack(alignment: .topLeading) {
                        Rectangle()
                            .frame(width: width, height: eventHeight)
                            .foregroundStyle(Color(event.calendar.cgColor).opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: appModel.moduleCornerRadius))

                        Text("\(event.title)")
                            .foregroundStyle(Color(event.calendar.cgColor))
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            .padding([.leading, .bottom], 10)
                    }
                    .offset(x: startX, y: verticalOffset)
                }
            }
        }
        .frame(maxHeight: .infinity)
    }


    
    
    private func ahorizontalEventLayers(widthPerHour: CGFloat, height: CGFloat) -> some View {
        ZStack(alignment: .leading) {
            ForEach(timedEvents, id: \.eventIdentifier) { event in
                if let (startX, width) = calculateEventPositionHorizontally(event: event, widthPerHour: widthPerHour) {
                    let overlapIndex = timedEvents.firstIndex { otherEvent in
                        otherEvent.eventIdentifier != event.eventIdentifier && eventsOverlap(event, otherEvent)
                    } ?? 0
                    let verticalOffset = CGFloat(overlapIndex) * (height / 2 * 0.3)  // Adjust vertical offset based on overlap index

                    ZStack(alignment: .bottomLeading) {
                        Rectangle()
                            .frame(width: width, height: height / 2)
                            .foregroundStyle(Color(event.calendar.cgColor).opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: appModel.moduleCornerRadius))

                        Text("\(event.title)").foregroundStyle(Color(event.calendar.cgColor))
                            .frame(maxWidth: .infinity, alignment: .topLeading).fixedSize(horizontal: true, vertical: true)
                            .padding([.leading, .bottom], 10)
                    }
                    .offset(x: startX, y: verticalOffset)  // Apply vertical offset here
                }
            }
        }
        .frame(maxHeight: .infinity)
    }






    private func calculateVerticalOffset(_ currentEvent: EKEvent) -> CGFloat {
        let lineHeight: CGFloat = 20 // Approximate line height
        var occupiedLines: [CGFloat] = []

        for event in timedEvents where event != currentEvent {
            if eventsOverlap(currentEvent, event) {
                if let index = timedEvents.firstIndex(of: event) {
                    let pos = CGFloat(index) * lineHeight
                    occupiedLines.append(pos)
                }
            }
        }

        var currentLine: CGFloat = 0
        while occupiedLines.contains(currentLine) {
            currentLine += lineHeight
        }
        return currentLine
    }



    private func calculateEventPositionHorizontally(event: EKEvent, widthPerHour: CGFloat) -> (CGFloat, CGFloat)? {
        guard let startHour = Calendar.current.dateComponents([.hour], from: event.startDate).hour else { return nil }
        let durationHours = event.endDate.timeIntervalSince(event.startDate) / 3600
        let startX = round(CGFloat(startHour) * widthPerHour)
        let width = CGFloat(durationHours) * widthPerHour
        
        return (startX, width)
    }
    
    private func loadEvents() {
        store.requestFullAccessToEvents { granted, error in
            if granted {
                let calendars = appModel.eventStore.calendars(for: .event)
                let startDate = date.startOfDay
                
                let endDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: startDate)!
                
                let predicate = appModel.eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
                
                let fetchedEvents = appModel.eventStore.events(matching: predicate).sorted { $0.startDate < $1.startDate }
                
                timedEvents = fetchedEvents.filter { !$0.isAllDay }
                
            } else {
                showingAlert = true
            }
        }
    }

    struct HourColumn: View {
        var hour: Int
        var width: CGFloat
        var segments: Int

        var body: some View {
            VStack(alignment: .leading) {
                HStack(spacing: 0) {
                    ForEach(0..<segments) { segment in
                        Group {
                            if segment == 0 {
                                // Only show text at the hour mark
                                Text(formatHour(hour: hour, segment: segment))
                                    .frame(width: width / CGFloat(segments), alignment: .leading)
                            } else {
                                Color.clear
                                    .frame(width: width / CGFloat(segments), height: 0, alignment: .leading)
                            }
                        }
                        .id("\(hour)-\(segment)")
                    }
                }
                HStack {
                    Divider().frame(maxWidth: 0, maxHeight: .infinity)
                     
                }.frame(maxWidth: 0, maxHeight: .infinity)
               
            }
            .frame(width: width)
            
        }

        func formatHour(hour: Int, segment: Int) -> String {
            let hourMod = hour % 12
            let suffix = hour < 12 ? "AM" : "PM"
            return "\(hourMod == 0 ? 12 : hourMod)\(suffix)"
        }
    }


}

#Preview {
   ContentView()
        .environmentObject(AppModel())
        .environmentObject(TasksUpdateNotifier())
        .modelContainer(for: [MoodEntry.self, Note.self])
}
