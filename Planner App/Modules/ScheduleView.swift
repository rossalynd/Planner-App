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
    var scale: SpaceView.Scale
    private var store = EKEventStore()
    @State private var permissionGranted = false
    @State private var showingAlert = false
    @State private var events: [EKEvent] = []
    @State private var allDayEvents: [EKEvent] = []
    @State private var timedEvents: [EKEvent] = []
    @State private var showingEventView = true
    @State private var showingAddEventView = false
    private var eventStore = EKEventStore()
    let allDayColors: [Color] = [.indigo, .pink, .blue, .orange, .purple] // Add more colors as needed
    let eventColors: [Color] = [.purple, .blue, .indigo]
    
    

    
    public init(scale: SpaceView.Scale) {
            self.scale = scale
            
        }

    private var columns: [GridItem] {
        
        switch scale {
        case .small: return [GridItem(.fixed(150))] // Smaller parent view
        case .medium: return [GridItem(.fixed(200))]// Medium parent view
        case .large: return [GridItem(.fixed(200))]
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                if permissionGranted {
                    ZStack {
                        VStack(alignment: .center) {
                            ScrollView {
                                
                                VStack {
                                    
                                    
                                    ForEach(allDayEvents.indices, id: \.self) { index in
                                        let event = allDayEvents[index]
                                        NavigationLink {
                                            EventInfoView(event: event)
                                        } label: {
                                            EventView(event: event, width: geometry.size.width * 0.9, backgroundColor: Color(event.calendar.cgColor)).foregroundStyle(.black)
                                        }
                                        
                                    }
                                    ForEach(timedEvents.indices, id: \.self) { index in
                                        let event = timedEvents[index]
                                        
                                        NavigationLink {
                                            EventInfoView(event: event)
                                        } label: {
                                            EventView(event: event, width: geometry.size.width * 0.9, backgroundColor: Color(event.calendar.cgColor)).foregroundStyle(.black)
                                        }
                                    }
                                    

                                }
                                
                            }
                            .onAppear(perform: loadEvents)
                            .onChange(of: dateHolder.displayedDate) { newValue, oldValue in
                                loadEvents()
                            }
                           
                        }
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                
                                Button("Add Event", systemImage: "plus.circle.fill", action: {
                                    showingAddEventView.toggle()
                                }).labelStyle(.iconOnly).font(.title).background(.white).clipShape(Circle()).foregroundStyle(Color("DefaultBlack")).padding(.horizontal, 5).shadow(radius: 2, x: 3, y: 3)
                                    .popover(isPresented: $showingAddEventView) {
                                        VStack{
                                            Button("Dismiss", action: {
                                                showingAddEventView = false
                                            })
                                            
                                        }.frame(width: 200, height: 200)
                                    }
                                
                            }
                        }
                    }
                } else {
                    VStack(alignment: .center) {
                    Text("Unable to retrieve events. Please enable access to Calendar in Settings.")
                        Button("Request Calendar Access") {
                            requestAccess()
                        }
                    }.padding()
                    .onAppear(perform: requestAccess)
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

        init(event: EKEvent, width: CGFloat, backgroundColor: Color) {
            self.event = event
            self.width = width
            self.backgroundColor = backgroundColor
        }

        var body: some View {
            HStack {
                
                if event.title.contains("Birthday") {
                    Image(systemName: "gift.fill") // Using SF Symbols for the present icon
                        .foregroundColor(Color("DefaultBlack")) // Optional: Change the color to fit your design
                }
                
                VStack {
                    Text(event.title.uppercased()).font(.headline)
                        .bold()
                    if !event.isAllDay {
                        Text("\(event.startDate, style: .time) - \(event.endDate, style: .time)")
                            .font(.subheadline)
                    }
                }
            }
            .padding()
            .frame(maxWidth: width, maxHeight: 50)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(radius: 3, x: 3, y: 3)
            .padding(.horizontal, 14)
        }
    }

    
    
    func requestAccess() {
        store.requestFullAccessToEvents { granted, error in
            DispatchQueue.main.async {
                if granted {
                    self.permissionGranted = true
                } else {
                    self.showingAlert = true
                }
            }
        }
    }
    func loadEvents() {
        let calendars = eventStore.calendars(for: .event)
        var startDate = dateHolder.displayedDate
        if dateHolder.displayedDate.formatted(date: .numeric, time: .omitted) == Date().formatted(date: .numeric, time: .omitted) {
        startDate = Date()
            
        } else {
            startDate = dateHolder.displayedDate
        }
        
        let endDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: startDate)!
        
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
        
        let fetchedEvents = eventStore.events(matching: predicate).sorted { $0.startDate < $1.startDate }
        
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
extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
}

#Preview {
    ContentView()
        .environmentObject(DateHolder())
}
