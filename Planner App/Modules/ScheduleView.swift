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
    @State private var showingEventView = false
    @State private var showingAddEventView = false
    @State private var expandedEventID: String? = nil
    @State private var showMenu: Bool = false


    
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
                if appModel.calendarPermissionGranted {
                    ZStack {
                        VStack {
                            ScrollView {
                                
                                VStack {
                                    AllDayEventsView(date: appModel.displayedDate)
                                    
                                    ForEach(timedEvents.indices, id: \.self) { index in
                                        let event = timedEvents[index]
                                        
                                        
                                            EventView(event: event, width: geometry.size.width, backgroundColor: Color(event.calendar.cgColor), fontSize: eventFontSize, timeFontSize: eventTimeFontSize, scale: scale).foregroundStyle(.black).padding(.horizontal, 5)
                                            .onTapGesture {
                                            
                                             showingEventView = true
                                            }
                                            .fullScreenCover(isPresented: $showingEventView, content: {
                                                
                                                    EventInfoView(event: event)
                                                
                                            })
                                        
                                    }
                                    

                                }
                                
                            }.scrollIndicators(.hidden)
                            .onAppear(perform: loadEvents)
                            .onChange(of: appModel.displayedDate) { newValue, oldValue in
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
                                                   
                                                }
                                                .themedBackground(appModel: appModel)
                                                VStack{
                                                    AddEventView(eventStore: appModel.eventStore).clipShape(RoundedRectangle(cornerRadius: 20))
                                                    
                                                    
                                                    
                                                }.padding()
                                            }
                                        }.clipShape(RoundedRectangle(cornerRadius: 20))
                                    
                                }
                            }
                        }
                    }
                } else {
                    VStack(alignment: .center) {
                    Text("Unable to retrieve events. Please enable access to Calendar in Settings.")
                        Button("Settings", action: {
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                        })
                    }.padding()
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
    
    struct EventView: View {
        var event: EKEvent
        var width: CGFloat
        var backgroundColor: Color
        var fontSize: Font
        var timeFontSize: Font
        var scale: SpaceView.Scale

        init(event: EKEvent, width: CGFloat, backgroundColor: Color, fontSize: Font, timeFontSize: Font, scale: SpaceView.Scale) {
            self.event = event
            self.width = width
            self.backgroundColor = backgroundColor
            self.fontSize = fontSize
            self.timeFontSize = timeFontSize
            self.scale = scale
        }

        var body: some View {
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
            .padding(scale == .small ? 5 : 10)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(radius: 3, x: 3, y: 3)
           
        }
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
    ScheduleView(layoutType: .elsePortrait, scale: .medium, date: Date())
        .environmentObject(AppModel())
}
