//
//  ScheduleView.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/23/24.
//
import SwiftUI
import EventKit
import EventKitUI

struct ScheduleView: View {
    @EnvironmentObject var dateHolder: DateHolder
    @EnvironmentObject var permissions: Permissions
    @EnvironmentObject var orientation: OrientationObserver
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
            VStack {
                if permissions.calendarPermissionGranted {
                    ZStack {
                        VStack {
                            ScrollView {
                                
                                VStack {
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
                                                
                                                Spacer()
                                            }.padding(.horizontal)
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
                                    ForEach(timedEvents.indices, id: \.self) { index in
                                        let event = timedEvents[index]
                                        
                                        NavigationLink {
                                            EventInfoView(event: event)
                                        } label: {
                                            EventView(event: event, width: geometry.size.width, backgroundColor: Color(event.calendar.cgColor), fontSize: eventFontSize, timeFontSize: eventTimeFontSize).foregroundStyle(.black).padding(.horizontal)
                                        }
                                    }
                                    

                                }
                                
                            }
                            .onAppear(perform: loadEvents)
                            .onChange(of: dateHolder.displayedDate) { newValue, oldValue in
                                loadEvents()
                            }
                           
                        }
                        if layoutType == .elsePortrait || layoutType == .iphonePortrait {
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    
                                    Button("Add Event", systemImage: "plus.circle.fill", action: {
                                        showingAddEventView.toggle()
                                    }).labelStyle(.iconOnly).font(.title).background(.white).clipShape(Circle()).foregroundStyle(Color.black).padding(.horizontal, 5).shadow(radius: 2, x: 3, y: 3)
                                        .sheet(isPresented: $showingAddEventView, onDismiss: {loadEvents()}) {
                                            ZStack {
                                                VStack {
                                                    // Gradient Background
                                                    LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .top, endPoint: .bottom)
                                                        .edgesIgnoringSafeArea(.all)
                                                }
                                                VStack{
                                                    AddEventView(eventStore: permissions.eventStore).clipShape(RoundedRectangle(cornerRadius: 20))
                                                    
                                                    
                                                    
                                                }.padding()
                                            }
                                        }.clipShape(RoundedRectangle(cornerRadius: 20))
                                    
                                }
                            }
                        }
                    }
                } else {
                    VStack(alignment: .center) {
                        Text("\(date)")
                    Text("Unable to retrieve events. Please enable access to Calendar in Settings.")
                        Button("Request Calendar Access") {
                            permissions.requestCalendarAccess()
                        }
                    }.padding()
                        .onAppear(perform: permissions.requestCalendarAccess)
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
    
    struct EventView: View {
        var event: EKEvent
        var width: CGFloat
        var backgroundColor: Color
        var fontSize: Font
        var timeFontSize: Font

        init(event: EKEvent, width: CGFloat, backgroundColor: Color, fontSize: Font, timeFontSize: Font) {
            self.event = event
            self.width = width
            self.backgroundColor = backgroundColor
            self.fontSize = fontSize
            self.timeFontSize = timeFontSize
        }

        var body: some View {
            HStack {
                
                if event.title.contains("Birthday") {
                    Image(systemName: "gift.fill") // Using SF Symbols for the present icon
                        .foregroundColor(Color("DefaultBlack")) // Optional: Change the color to fit your design
                }
                
                VStack {
                    Text(event.title.uppercased()).font(fontSize)
                        .bold()
                        Text("\(event.startDate, style: .time) - \(event.endDate, style: .time)")
                            .font(timeFontSize)
                    
                }
            }
            .padding(5)
            .frame(maxWidth: width, maxHeight: 40)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(radius: 3, x: 3, y: 3)
           
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
                        Text("hello world".uppercased())
                            .font(fontSize)
                            .bold()
                            .foregroundColor(.black)
                            .padding(.trailing, 5)
                            
                        
                    }
                            
                    
                }
                .padding(5)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(radius: 3, x: 3, y: 3)
                
                
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

    

    

    
    

    func loadEvents() {
        let calendars = permissions.eventStore.calendars(for: .event)
        var startDate = date
        if date.formatted(date: .numeric, time: .omitted) == Date().formatted(date: .numeric, time: .omitted) {
            startDate = Date()
        } else {
            startDate = date
        }
        
        let endDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: startDate)!
        
        let predicate = permissions.eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
        
        let fetchedEvents = permissions.eventStore.events(matching: predicate).sorted { $0.startDate < $1.startDate }
        
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

struct ConditionalShape: Shape {
    var showEventTitle: Bool
    var radius: CGFloat

    func path(in rect: CGRect) -> Path {
        if !showEventTitle {
            return Circle().path(in: rect)
        } else {
            return RoundedRectangle(cornerRadius: radius).path(in: rect)
        }
    }
}




#Preview {
    ContentView()
        .environmentObject(DateHolder())
        .environmentObject(ThemeController())
        .environmentObject(CustomColor())
        .environmentObject(TasksUpdateNotifier())
        .environmentObject(OrientationObserver())
        .environmentObject(Permissions())
    
        
}
