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
    @EnvironmentObject var orientationObserver: OrientationObserver
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var dateHolder: DateHolder
    @EnvironmentObject var themeController: ThemeController
    @State var isCoverVisible = false
    @State var isMenuVisible = false

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
                .themedBackground(themeController: themeController)
                

                
                VStack {
                    
                    
                    if UIDevice.current.userInterfaceIdiom == .phone { //IPHONE HEADER
                        
                        HStack {
                            Button("Menu", systemImage:"line.horizontal.3.circle.fill", action: {
                                isMenuVisible.toggle()
                            }).foregroundStyle(Color("DefaultBlack")).padding(.leading,padding).labelStyle(.iconOnly).font(.title2)
                            Button("Previous Day", systemImage: "arrowshape.backward.circle.fill", action: {
                                dateHolder.displayedDate = Calendar.current.date(byAdding: .day, value: -1, to: dateHolder.displayedDate)!
                            }).foregroundStyle(Color("DefaultBlack")).labelStyle(.iconOnly).font(.title2)
                            
                            Spacer()
                            
                            
                            Button(action: {
                                dateHolder.displayedDate = Date()
                            }, label: {
                                HStack{
                                    
                                    
                                    Text("\(dateHolder.displayedDate.shortDate.uppercased())").font(.headline).foregroundColor((Color("DefaultBlack"))).bold()
                                    
                                }
                            })
                            
                            Spacer()
                            
                            Button("Next Day", systemImage: "arrowshape.forward.circle.fill", action: {
                                dateHolder.displayedDate = Calendar.current.date(byAdding: .day, value: 1, to: dateHolder.displayedDate)!
                            }).foregroundStyle(Color("DefaultBlack")).padding([.trailing, .top, .bottom], padding).labelStyle(.iconOnly).font(.title2)
                            NavigationLink(destination: SettingsView()) {
                                Image(systemName: "gearshape.circle.fill").foregroundStyle(Color("DefaultBlack")).padding([.trailing, .top, .bottom], padding).labelStyle(.iconOnly).font(.title2)
                            }
                            
                            
                        }.background(Color("DefaultWhite")).cornerRadius(20).shadow(radius: 5, x: 5, y: 5)
                            .padding(.bottom, 10)
                        
                        
                    } else { //IPAD HEADER
                        
                        
                        HStack {
                            
                            Button("Menu", systemImage: "line.3.horizontal.circle.fill", action: {
                                withAnimation {
                                    isMenuVisible.toggle()
                                }
                            }).foregroundStyle(Color("DefaultBlack")).font(.title).padding(2).background(Color("DefaultWhite")).cornerRadius(20).shadow(radius: 5, x: 5, y: 5).labelStyle(.iconOnly)
                            
                            HStack {
                                Button("Previous Day", systemImage: "arrowshape.backward.circle.fill", action: {
                                    dateHolder.displayedDate = Calendar.current.date(byAdding: .day, value: -1, to: dateHolder.displayedDate)!
                                }).foregroundStyle(Color("DefaultBlack")).font(.title).padding(2).labelStyle(.iconOnly)
                                
                                Spacer()
                                
                                Button("\(dateHolder.displayedDate.formatted(date: .complete, time: .omitted).uppercased())", action: {
                                    dateHolder.displayedDate = Date()
                                }).font(.title2).foregroundColor((Color("DefaultBlack")))
                                
                                Spacer()
                                
                                Button("Next Day", systemImage: "arrowshape.forward.circle.fill", action: {
                                    dateHolder.displayedDate = Calendar.current.date(byAdding: .day, value: 1, to: dateHolder.displayedDate)!
                                }).foregroundStyle(Color("DefaultBlack")).font(.title).padding(2).labelStyle(.iconOnly)
                                
                                
                                
                            }.background(Color("DefaultWhite")).cornerRadius(20).shadow(radius: 5, x: 5, y: 5)
                            
                            
                            
                            NavigationLink(destination: SettingsView()) {
                                Image(systemName: "gearshape.circle.fill").foregroundStyle(Color("DefaultBlack")).font(.title).padding(2).background(Color("DefaultWhite")).cornerRadius(20).shadow(radius: 5, x: 5, y: 5).labelStyle(.iconOnly)
                            }
                        }.padding(.bottom, 10)
                        
                    } // END HEADER
                    VStack {
                        
                        // Using the size classes to determine the orientation
                        if orientationObserver.isLandscape {
                            LandscapeView()
                        } else {
                            PortraitView()
                        }
                        // Portrait orientation
                        
                        
                    }
                        
                       
                }.padding(.horizontal, padding)

                

                GeometryReader { geometry in
                

                    VStack {
                        VStack(alignment: .leading) {
                            Spacer()
                            if isMenuVisible {
                                MainMenuView(isMenuVisible: $isMenuVisible)
                                    .frame(maxWidth: .infinity)
                                    .transition(.move(edge: .leading))
                                    .gesture(
                                                           DragGesture()
                                                               .onEnded { drag in
                                                                   // Check if the drag is from trailing to leading
                                                                   if drag.translation.width < 0 {
                                                                       // This means the user swiped from trailing to leading
                                                                       withAnimation {
                                                                           isMenuVisible = false
                                                                       }
                                                                   }
                                                               }
                                                       )
                            }
                            Spacer()
                        }.frame(maxWidth: geometry.size.width / 2, maxHeight: geometry.size.height).shadow(radius: 10, x: 10, y: 10)
                            
                    }.frame(maxHeight: geometry.size.height)
                    
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                
            
            
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
