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

    init(layoutType: LayoutType, scale: SpaceView.Scale) {
        self.scale = scale
        self.layoutType = layoutType

    }

    var body: some View {
        GeometryReader { geometry in
            VStack {
                if appModel.calendarPermissionGranted {
                    if !allDayEvents.isEmpty {
                        allDayEventsView
                    }
                    
                    ScrollViewReader { scrollView in
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(0..<24) { hour in
                                    HourRow(hour: hour, height: geometry.size.height / 8).foregroundStyle(appModel.headerColor).id(hour).font(.caption)
                                }
                            }
                            .overlay(
                                eventLayers(heightPerHour: geometry.size.height / 8),
                                alignment: .topLeading
                            )
                            .onChange(of: appModel.displayedDate) {
                                loadEvents()
                                scrollView.scrollTo(startHour, anchor: .top)
                            }
                        }.onAppear {
                            // Scroll to the desired hour when the view appears
                            scrollView.scrollTo(startHour, anchor: .top)
                        }
                    }
                    
                } else {
                    VStack {
                        Text("Unable to retrieve events. Please enable access to Calendar in Settings.")
                        Button("Request Calendar Access") {
                            appModel.requestCalendarAccess()
                        }
                    }
                }
            }.padding()
            .alert("Need Calendar Access", isPresented: $showingAlert) {
                Button("OK", role: .cancel) {}
            }
        }
        .onAppear {
            loadEvents()
        }
    }

    private func eventLayers(heightPerHour: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            ForEach(timedEvents, id: \.eventIdentifier) { event in
                if let (startY, height) = calculateEventPosition(event: event, heightPerHour: heightPerHour) {
                    Text(event.title)
                        .padding()
                        .frame(width: 150, height: height, alignment: .topLeading)
                        .background(Color(event.calendar.cgColor).opacity(0.5))
                        .offset(y: startY)
                        .padding(.leading, 100)
                }
            }
        }
    }

    private func calculateEventPosition(event: EKEvent, heightPerHour: CGFloat) -> (CGFloat, CGFloat)? {
        let startMinutes = Calendar.current.dateComponents([.hour, .minute], from: event.startDate).hour! * 60 + Calendar.current.dateComponents([.hour, .minute], from: event.startDate).minute!
        let durationMinutes = event.endDate.timeIntervalSince(event.startDate) / 60
        
        let startY = (CGFloat(startMinutes) * heightPerHour / 60) + (heightPerHour / 2)
        let height = CGFloat(durationMinutes) * heightPerHour / 60
        
        return (startY, height)
    }

    private func loadEvents() {
        store.requestFullAccessToEvents { granted, error in
            if granted {
                let calendars = appModel.eventStore.calendars(for: .event)
                var startDate = appModel.displayedDate
                if appModel.displayedDate.formatted(date: .numeric, time: .omitted) == Date().formatted(date: .numeric, time: .omitted) {
                    startDate = Date()
                } else {
                    startDate = appModel.displayedDate
                }
                
                let endDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: startDate)!
                
                let predicate = appModel.eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
                
                let fetchedEvents = appModel.eventStore.events(matching: predicate).sorted { $0.startDate < $1.startDate }
                
                // Split events into all-day and timed
                allDayEvents = fetchedEvents.filter { $0.isAllDay }
                
                timedEvents = fetchedEvents.filter { !$0.isAllDay }
                
            } else {
                showingAlert = true
            }
        }
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
    
       
    struct HourRow: View {
        var hour: Int
        var height: CGFloat

        var body: some View {
            HStack(alignment: .center) {
                Text(formatHour(hour: hour))
                VStack {
                    Divider()
                }
            }
            .frame(height: height)
        }
        
        func formatHour(hour: Int) -> String {
                   let hourMod = hour % 12
                   let suffix = hour < 12 ? "AM" : "PM"
                   return "\(hourMod == 0 ? 12 : hourMod) \(suffix)"
               }
    }

    


}




#Preview {
    TimelineView(layoutType: .elsePortrait, scale: .large)
        .environmentObject(AppModel())
}
