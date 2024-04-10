//
//  ContentView.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/21/24.
//

import SwiftUI
import SwiftData
import UIKit


import SwiftUI
    

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject var appModel: AppModel
    @State private var selectedTab: String = "monthly"

    init() {
        UITabBar.appearance().unselectedItemTintColor = UIColor.gray
    }
    private var padding: CGFloat {
            switch currentDeviceType() {
            case .iPhone:
                return 10
            case .iPad:
                return 20
            default:
                return 15 // Fallback padding
            }
        }
 

    enum DeviceType {
        case iPhone
        case iPad
        case unknown
    }

    func currentDeviceType() -> DeviceType {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return .iPhone
        case .pad:
            return .iPad
        default:
            return .unknown
        }
    }

    var body: some View {
        

        NavigationStack {
            
            
            ZStack(alignment: .leading) {
                VStack {
                    
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                .themedBackground(appModel: appModel)
                

                
                VStack {
                    
                    AppHeader()
                    
                    if appModel.mainView == "Planner" {
                        
                        TabView {
                            VStack {
                                if currentDeviceType() == .iPhone {
                                    iPhoneDayView()
                                } else {
                                    DayView()
                                }
                            }
                            .tabItem{
                                Label("Daily", systemImage: "sun.max.fill")
                                
                            }.background(BackgroundHelper()).transition(.opacity)
                            WeekView().padding(.bottom, 10)
                                .tabItem{
                                    Label("Weekly", systemImage: "chart.bar.xaxis")
                                }.background(BackgroundHelper()).transition(.opacity)
                            MonthlyView(scale: .large, layoutType: .elsePortrait, appModel: appModel)
                                .tabItem{
                                    Label("Monthly", systemImage: "calendar")
                                }.background(BackgroundHelper()).transition(.opacity)
                            YearlyMoodView()
                                .tabItem{
                                    Label("Yearly", systemImage: "globe.desk.fill")
                                }.background(BackgroundHelper()).transition(.opacity)
                        }.tint(appModel.headerColor).shadow(color: .black.opacity(0.2), radius: 5, x: 5, y: 5)
                        
                    } else if appModel.mainView == "Wellbeing" {
                        
                        TabView {
                           
                                YearlyMoodView()
                                .tabItem{
                                    Label("Moods", systemImage: "sun.max.fill")
                                }.background(BackgroundHelper()).transition(.opacity)
                            
                            MiniMonthCalendarView(scale: .large, layoutType: .elsePortrait, appModel: appModel)
                                .tabItem{
                                    Label("Calendar", systemImage: "calendar")
                                }.background(BackgroundHelper()).transition(.opacity)
                            
                               
                        }.tint(.defaultWhite).shadow(color: .black.opacity(0.2), radius: 5, x: 5, y: 5)
                        
                    } else {
                        TimelineView(layoutType: .elsePortrait, scale: .large)
                    }
                    
                }.padding([.leading, .trailing])

                

                GeometryReader { geometry in
                

                    VStack {
                        VStack(alignment: .leading) {
                            Spacer()
                            if appModel.isMenuVisible {
                                MainMenuView(isMenuVisible: $appModel.isMenuVisible)
                                    .frame(maxWidth: .infinity)
                                    .transition(.move(edge: .leading))
                                    .gesture(
                                                           DragGesture()
                                                               .onEnded { drag in
                                                                   // Check if the drag is from trailing to leading
                                                                   if drag.translation.width < 0 {
                                                                       // This means the user swiped from trailing to leading
                                                                       withAnimation {
                                                                           appModel.isMenuVisible = false
                                                                       }
                                                                   }
                                                               }
                                                       )
                            }
                            Spacer()
                        }.frame(maxWidth:  UIDevice.current.userInterfaceIdiom != .phone ? geometry.size.width / 3 : geometry.size.width / 1.25, maxHeight: .infinity).shadow(radius: 10, x: 10, y: 10).ignoresSafeArea()
                            
                    }.frame(maxHeight: geometry.size.height)
                        
                    
                }

                
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.clear) // Make the rectangle invisible
                        .frame(width: 20) // Adjust the width to increase or decrease the sensitive area
                        .contentShape(Rectangle()) // Ensure the invisible area is still tappable
                        .gesture(
                            DragGesture(minimumDistance: 20) // Adjust minimumDistance as needed
                                .onEnded { drag in
                                    if drag.translation.width > 0 {
                                        // Detect swipe right
                                        withAnimation {
                                            appModel.isMenuVisible = true
                                        }
                                    }
                                }
                        )
                    Spacer() // Ensures the rectangle stays at the left edge
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                
            
                //END ZSTACK ^^
            
            
        }.onAppear {
            appModel.loadSettings()
        }
          
                
                
            
            
            
    }
    
            
}


struct BackgroundHelper: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            // find first superview with color and make it transparent
            var parent = view.superview
            repeat {
                if parent?.backgroundColor != nil {
                    parent?.backgroundColor = UIColor.clear
                    break
                }
                parent = parent?.superview
            } while (parent != nil)
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

#Preview {
   ContentView()
        .environmentObject(AppModel())
        .environmentObject(TasksUpdateNotifier())
        .modelContainer(for: MoodEntry.self)
}
