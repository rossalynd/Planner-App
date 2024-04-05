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
        self.loadSettings()
        print("initiating app model")
    }
    
    //MENUS
    @Published var isCoverVisible: Bool = false
    @Published var isMenuVisible: Bool = false
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
    @Published var backgroundImage: String = "celestial"
    @Published var photoBackgroundImage: UIImage?
    @Published var photoBackgroundPath: String?
    @Published var moduleCornerRadius: CGFloat = 20
    @Published var headerFont: String = ""
    enum BackgroundType: String, CaseIterable {
        case bluePurpleGradient = "Blue > Purple"
        case beige = "Beige"
        case custom = "Custom"
        
        
        var id: Self { self }
    }
    enum OverlayType: String, CaseIterable {
        case color = "Color"
        case hearts = "Transparent Hearts"
        case backgroundImage = "Image"
        case photoBackground = "Photo"
        case none = "None"
        
        var id: Self { self }
    }


    func getBackgroundView(for backgroundType: BackgroundType) -> some View {
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
            case .color:
                return AnyView(getBackgroundView(for: self.backgroundType))
            case .hearts:
                return AnyView(Hearts())
            case .backgroundImage:
                return AnyView(SeamlessPattern(image: backgroundImage))
            case .photoBackground:
                print("Background is photo")
                if let imageName = UserDefaults.standard.string(forKey: "photoBackgroundKey") {
                    let fullPath = getDocumentsDirectory().appendingPathComponent(imageName).path
                    if FileManager.default.fileExists(atPath: fullPath), let photoBackgroundImage = UIImage(contentsOfFile: fullPath) {
                        print("Loading image from \(fullPath)")
                        return AnyView(Image(uiImage: photoBackgroundImage).resizable(resizingMode: .stretch).frame(maxWidth: .infinity, maxHeight: .infinity).ignoresSafeArea())
                    } else {
                        print("No file found at path \(fullPath)")
                        return AnyView(Image(systemName: "questionmark"))
                    }
                } else {
                    print("No image name in UserDefaults")
                    return AnyView(Image(systemName: "questionmark"))
                }

                
                
                
               
                
            case .none:
                return AnyView(Text(""))
                
            }
        }

    
   func saveSettings() {
        // Save BackgroundType
        UserDefaults.standard.set(backgroundType.rawValue, forKey: "backgroundType")

        // Save OverlayType
        UserDefaults.standard.set(overlayType.rawValue, forKey: "overlayType")

        // Save backgroundImage
        UserDefaults.standard.set(backgroundImage, forKey: "backgroundImage")

        // Assume photoBackground holds a reference (e.g., filename) to an image
       UserDefaults.standard.set("CurrentAppBackground", forKey: "photoBackgroundKey")

        // Save Color
        if let encodedColor = try? NSKeyedArchiver.archivedData(withRootObject: UIColor(color), requiringSecureCoding: false) {
            UserDefaults.standard.set(encodedColor, forKey: "color")
        }

        // Save SecondaryColor
        if let encodedSecondaryColor = try? NSKeyedArchiver.archivedData(withRootObject: UIColor(secondaryColor), requiringSecureCoding: false) {
            UserDefaults.standard.set(encodedSecondaryColor, forKey: "secondaryColor")
        }

        // Save moduleCornerRadius
        UserDefaults.standard.set(moduleCornerRadius, forKey: "moduleCornerRadius")
       
       // Save Header Font
       UserDefaults.standard.set(headerFont, forKey: "headerFont")
    }

    
    
    func loadImageFromDocumentsDirectory() -> Image? {
        guard let imagePath = UserDefaults.standard.string(forKey: "photoImagePath"),
              let uiImage = UIImage(contentsOfFile: imagePath) else { return nil }
        return Image(uiImage: uiImage)
    }
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    
    private func loadSettings() {
        // Load BackgroundType
        if let backgroundTypeRawValue = UserDefaults.standard.string(forKey: "backgroundType"),
           let savedBackgroundType = BackgroundType(rawValue: backgroundTypeRawValue) {
            backgroundType = savedBackgroundType
        }

        // Load OverlayType
        if let overlayTypeRawValue = UserDefaults.standard.string(forKey: "overlayType"),
           let savedOverlayType = OverlayType(rawValue: overlayTypeRawValue) {
            overlayType = savedOverlayType
        }

        // Load backgroundImage
         let backgroundImage = UserDefaults.standard.string(forKey: "backgroundImage")
         
        //Load Photo Background
        if let imageName = UserDefaults.standard.string(forKey: "photoBackgroundKey") {
            let fullPath = getDocumentsDirectory().appendingPathComponent(imageName).path
            if FileManager.default.fileExists(atPath: fullPath), let uiImage = UIImage(contentsOfFile: fullPath) {
                let photoBackgroundPath = UserDefaults.standard.string(forKey: "photoBackgroundKey")
            }
        }

        // Load Color
        if let colorData = UserDefaults.standard.data(forKey: "color"),
           let decodedColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) {
            color = Color(decodedColor)
        }

        // Load SecondaryColor
        if let secondaryColorData = UserDefaults.standard.data(forKey: "secondaryColor"),
           let decodedSecondaryColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: secondaryColorData) {
            secondaryColor = Color(decodedSecondaryColor)
        }

        // Load moduleCornerRadius
        moduleCornerRadius = CGFloat(UserDefaults.standard.double(forKey: "moduleCornerRadius"))
        
        // Load Header Font
        if let loadedHeaderFont = UserDefaults.standard.string(forKey: "headerFont") {
            headerFont = loadedHeaderFont
        }
        
        
        print("Settings loaded")
    }

    
    
}

enum WeekStartDay: String {
    case sunday = "Sunday"
    case monday = "Monday"
}

