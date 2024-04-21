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
    @State private var currentScale: CGFloat = 1.0
    
    var defaultHourWidth: CGFloat = 60 // Default width of one hour column at scale 1.0
    var minScale: CGFloat = 0.5
    var maxScale: CGFloat = 3.0

    var hourWidth: CGFloat {
        max(minScale, min(maxScale, currentScale)) * defaultHourWidth
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

    init(layoutType: LayoutType, scale: SpaceView.Scale, date: Date) {
        self.date = date
        self.scale = scale
        self.layoutType = layoutType

    }


    var body: some View {
        if appModel.calendarPermissionGranted {
            GeometryReader { geometry in
                let defaultHourWidth = geometry.size.width / 8  // Calculate default width dynamically
                
                var hourWidth: CGFloat {
                    max(0.5 * defaultHourWidth, min(3.0 * defaultHourWidth, currentScale * defaultHourWidth))
                }
                HStack {
                    
                    ScrollViewReader { scrollView in
                        VStack {
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                
                                HStack(spacing: 0) {
                                    ForEach(0..<24) { hour in
                                        HourColumn(hour: hour, width: hourWidth, segments: 2).font(.caption2).foregroundStyle(Color(appModel.headerColor))
                                            .id(hour)
                                    }
                                }.frame(maxHeight: .infinity)
                                    .overlay(
                                        horizontalEventLayers(widthPerHour: hourWidth, height: geometry.size.height),
                                        alignment: .topLeading
                                    )
                            }
                            .frame(maxHeight: geometry.size.height)
                            .gesture(MagnificationGesture()
                                .onChanged { value in
                                    currentScale = value.magnitude
                                }
                                .onEnded { value in
                                    if abs(value - 1.0) < 0.1 { // Snap to default scale if close
                                        currentScale = 1.0
                                    } else {
                                        currentScale = max(minScale, min(maxScale, value.magnitude))
                                    }
                                }
                            )
                            .onAppear {
                                loadEvents()
                                
                                scrollView.scrollTo("6-0", anchor: .leading)
                                
                            }
                            .onChange(of: appModel.displayedDate) {
                                loadEvents()
                            }
                        }
                    }
                }.padding(.horizontal, 2)
                
            }
        } else {
            VStack {
                Text("Unable to retrieve calendar events. Please enable access to Calendar in Settings")
                Button("Open Settings", action: {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                })
            } 
            .padding()
            .onAppear(perform: appModel.requestCalendarAccess)
        }
    }
    
    
    
    // Helper function to determine if two events overlap
    private func eventsOverlap(_ event1: EKEvent, _ event2: EKEvent) -> Bool {
        // Ending time of the first event plus a 15-minute buffer.
        let endBuffer = event1.endDate.addingTimeInterval(900) // 900 seconds = 15 minutes
        // Checking if the start of the second event is before the endBuffer.
        return event2.startDate > endBuffer
    }

   

    
    private func horizontalEventLayers(widthPerHour: CGFloat, height: CGFloat) -> some View {
        VStack(alignment: .leading) {
            ForEach(timedEvents, id: \.eventIdentifier) { event in
                if let (startX, width) = calculateEventPositionHorizontally(event: event, widthPerHour: widthPerHour) {
                    let verticalOffset = calculateVerticalOffset(event, timedEvents, height: height)
                    let eventHeight = height / 8 // Adjust the height of each event rectangle

                    ZStack(alignment: .topLeading) {
                        Rectangle()
                            .frame(maxWidth: width, maxHeight: eventHeight)
                            .foregroundStyle(Color(event.calendar.cgColor).opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: appModel.moduleCornerRadius))

                        Text("\(event.title)")
                            .frame(width: width, alignment: .topLeading)
                            .fixedSize()
                            .font(.footnote)
                            .lineLimit(1)
                            .foregroundStyle(Color(event.calendar.cgColor))
                            .padding([.leading, .top], 5)
                        
                    }
                    .offset(x: startX, y: verticalOffset)
                    
                }
            }
            
        }
        .frame(maxHeight: .infinity)
    }


    
    
    
    private func calculateAllEventOffsets(_ timedEvents: [EKEvent]) -> [EKEvent: CGFloat] {
        let lineHeight: CGFloat = 40  // Vertical space each line of events will occupy
        var eventOffsets: [EKEvent: CGFloat] = [:]  // Dictionary to store calculated offsets
        var offsetLevels: [CGFloat] = []  // List to track which levels (offsets) are currently occupied

        // Sort events by start time
        let sortedEvents = timedEvents.sorted(by: { $0.startDate <= $1.startDate })

        for currentEvent in sortedEvents {
            // Find the first available offset level that is not overlapping with other events
            var foundFreeOffset = false
            var currentOffset: CGFloat = 0

            while !foundFreeOffset {
                foundFreeOffset = true  // Assume the current offset is free until proven otherwise

                for otherEvent in sortedEvents where otherEvent != currentEvent && otherEvent.endDate > currentEvent.startDate {
                    let otherOffset = eventOffsets[otherEvent] ?? 0
                    if otherOffset == currentOffset {
                        foundFreeOffset = false  // This level is occupied, increment and check again
                        currentOffset += lineHeight
                        break
                    }
                }
            }

            // Assign the free offset to the current event
            eventOffsets[currentEvent] = currentOffset
            // Ensure this level is marked as occupied
            if !offsetLevels.contains(currentOffset) {
                offsetLevels.append(currentOffset)
            }
        }

        return eventOffsets
    }

    private func calculateVerticalOffsets(_ timedEvents: [EKEvent], height: CGFloat) -> [EKEvent: CGFloat] {
        let lineHeight = height / 7  // Vertical space each line of events will occupy
        var eventOffsets: [EKEvent: CGFloat] = [:]  // Dictionary to store calculated offsets
        var activeEvents: [(event: EKEvent, offset: CGFloat)] = []  // List to keep track of active events and their offsets

        // Sort events by start time
        let sortedEvents = timedEvents.sorted { $0.startDate < $1.startDate }

        for currentEvent in sortedEvents {
            // Remove events that have ended 15 minutes before the current event's start
            activeEvents = activeEvents.filter { $0.event.endDate.addingTimeInterval(900) > currentEvent.startDate }

            // Determine the lowest free offset by checking currently active events
            var currentOffset: CGFloat = 0
            var offsetFound: Bool = false
            while !offsetFound {
                offsetFound = true
                for (event, offset) in activeEvents {
                    if offset == currentOffset {
                        currentOffset += lineHeight
                        offsetFound = false
                        print(event)
                        break  // Offset is occupied, try the next one
                    }
                }
            }

            // Assign the found free offset to the current event
            eventOffsets[currentEvent] = currentOffset
            // Add the current event to the list of active events
            activeEvents.append((currentEvent, currentOffset))
        }

        return eventOffsets
    }

    private func calculateVerticalOffset(_ currentEvent: EKEvent, _ timedEvents: [EKEvent], height: CGFloat) -> CGFloat {
        let offsets = calculateVerticalOffsets(timedEvents, height: height)
        return offsets[currentEvent] ?? 0
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
                    ForEach(0..<2) { segment in
                        Group {
                            if segment == 0 {
                                // Only show text at the hour mark
                                Text(formatHour(hour: hour, segment: segment)).fixedSize()
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
