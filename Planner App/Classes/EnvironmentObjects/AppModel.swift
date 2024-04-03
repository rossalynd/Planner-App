//
//  AppEnvironment.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 4/1/24.
//

import Foundation
import EventKit
import SwiftUI

class AppModel: ObservableObject {
    
    init() {
        self.isLandscape = isLandscapeOrientation
        NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main) { [weak self] _ in
            self?.isLandscape = self?.isLandscapeOrientation ?? false
        }
        self.startOfWeek = loadStartOfWeek()
    }
    
    
    //DATES
    @Published var displayedDate: Date = Date()
    @Published var startOfWeek: WeekStartDay = WeekStartDay.monday {
            didSet {
                saveStartOfWeek()
            }
        }
    
    private func saveStartOfWeek() {
           UserDefaults.standard.set(startOfWeek.rawValue, forKey: "startOfWeek")
       }

       private func loadStartOfWeek() -> WeekStartDay {
           guard let rawValue = UserDefaults.standard.string(forKey: "startOfWeek"),
                 let loadedStartOfWeek = WeekStartDay(rawValue: rawValue) else {
               return .monday // Default value
           }
           return loadedStartOfWeek
       }
    
    func datesInWeek(from date: Date, weekStartsOn startDay: WeekStartDay) -> [Date] {
        var calendar = Calendar.current
        // Adjust the calendar based on the start day of the week
        calendar.firstWeekday = startDay == startOfWeek ? 1 : 2
        
        // Find the start of the week
        guard let startDateOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)) else {
            return []
        }
        
        // Generate the list of dates in the week
        var dates: [Date] = []
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: startDateOfWeek) {
                dates.append(date)
            }
        }
        
        return dates
    }
    
    
    //PERMISSIONS
    @Published var calendarPermissionGranted: Bool = false
    @Published var remindersPermissionGranted: Bool = false
    @Published var eventStore = EKEventStore()
    
    func requestCalendarAccess() {
        eventStore.requestFullAccessToEvents { granted, error in
            DispatchQueue.main.async {
                if granted {
                    self.calendarPermissionGranted = true
                } else {
                    self.calendarPermissionGranted = false
                }
            }
        }
    }

    func requestRemindersAccess(completion: @escaping (Bool) -> Void) {
        eventStore.requestFullAccessToReminders { granted, error in
            DispatchQueue.main.async {
                self.remindersPermissionGranted = granted
                completion(granted)
            }
        }
    }
    
    
    //DEVICE ORIENTATION
    @Published var isLandscape: Bool = false
    

    private var isLandscapeOrientation: Bool {
        // Attempt to get a reference to the current UIWindowScene
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return false
        }
        return windowScene.interfaceOrientation.isLandscape
    }
    
    //COLORS
    @Published var color: Color = Color(.blue)
    @Published var secondaryColor: Color = (.blue)
    @Published var patternColor: Color = (.white)
    @Published var moduleColor: Color = Color("DefaultWhite")
    
    
    //THEMES
    @Published var backgroundType: BackgroundType = .bluePurpleGradient
    @Published var overlayType: OverlayType = .none
    
    enum BackgroundType: String, CaseIterable {
        case bluePurpleGradient = "Blue > Purple"
        case beige = "Beige"
        case custom = "Custom"
        
        var id: Self { self }
    }
    enum OverlayType: String, CaseIterable {
        case hearts = "Hearts"
        case stripes = "Stripes"
        case customPattern = "Custom"
        case none = "None"
        
        var id: Self { self }
    }


    func getBackgroundView() -> some View {
        switch self.backgroundType {
        case .bluePurpleGradient:
            return AnyView(BluePurpleGradientBackground())
        case .beige:
            return AnyView(BeigeBackground())
        case .custom:
            return AnyView(CustomBackground())
            
        }
    }
    func getOverlayView() -> some View {
            switch self.overlayType {
            case .hearts:
                return AnyView(Hearts())
            case .stripes:
                return AnyView(Text("Stripes"))
            case .customPattern:
                return AnyView(Text("Custom"))
            case .none:
                return AnyView(Text(""))
            }
        }

    
    
}

enum WeekStartDay: String {
    case sunday = "Sunday"
    case monday = "Monday"
}

