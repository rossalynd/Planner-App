//
//  AllDayEvents.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 4/10/24.
//

import SwiftUI
import EventKit

struct AllDayEventsView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var allDayEvents: [EKEvent] = []
    var date: Date
    @State private var expandedEventID: String? = nil
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { scrollView in
                HStack {
                    Color.clear.frame(width: 0, height: 0)
                        .id("start")
                    ForEach(allDayEvents.indices, id: \.self) { index in
                        let event = allDayEvents[index]
                       
                        ADEventView(event: event, backgroundColor: Color(event.calendar.cgColor), fontSize: .caption).id(event.eventIdentifier).onLongPressGesture(perform: {
                            // Here you can handle long press events.
                        })
                    }
                    Spacer()
                }
                .onChange(of: expandedEventID) {
                    if let expandedID = expandedEventID {
                        scrollView.scrollTo(expandedID, anchor: .center)
                    } else {
                        scrollView.scrollTo("start", anchor: .leading)
                    }
                }
                .onChange(of: appModel.displayedDate) {
                    loadEvents()
                }
            }
        }
    }
    func loadEvents() {
        let calendars = appModel.eventStore.calendars(for: .event)
        let startDate = date
        let endDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: startDate)!
        let predicate = appModel.eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
        let fetchedEvents = appModel.eventStore.events(matching: predicate).sorted { $0.startDate < $1.startDate }
        allDayEvents = fetchedEvents.filter { $0.isAllDay }

    }
    struct ADEventView: View {
        var event: EKEvent
        var backgroundColor: Color
        var fontSize: Font
        @State private var showEventTitle = false
        @State var expandedEventId: String?

        init(event: EKEvent, backgroundColor: Color, fontSize: Font) {
            self.event = event
            self.backgroundColor = backgroundColor
            self.fontSize = fontSize
           
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
}


