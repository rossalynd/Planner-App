//
//  AppHeader.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 4/4/24.
//

import SwiftUI

struct AppHeader: View {
    @EnvironmentObject var appModel: AppModel
    
    
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
        
            if UIDevice.current.userInterfaceIdiom == .phone { //IPHONE HEADER
                
                HStack {
                    Button("Menu", systemImage:"line.horizontal.3.circle.fill", action: {
                        appModel.isMenuVisible.toggle()
                    }).foregroundStyle(Color("DefaultBlack")).padding(.leading,padding).labelStyle(.iconOnly).font(.title2)
                    Button("Previous Day", systemImage: "arrowshape.backward.circle.fill", action: {
                        appModel.displayedDate = Calendar.current.date(byAdding: .day, value: -1, to: appModel.displayedDate)!
                    }).foregroundStyle(Color("DefaultBlack")).labelStyle(.iconOnly).font(.title2)
                    
                    Spacer()
                    
                    
                    Button(action: {
                        appModel.displayedDate = Date()
                    }, label: {
                        HStack{
                            
                            
                            Text("\(appModel.displayedDate.shortDate.uppercased())").font(.headline).foregroundColor((Color("DefaultBlack"))).bold()
                            
                        }
                    })
                    
                    Spacer()
                    
                    Button("Next Day", systemImage: "arrowshape.forward.circle.fill", action: {
                        appModel.displayedDate = Calendar.current.date(byAdding: .day, value: 1, to: appModel.displayedDate)!
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
                            appModel.isMenuVisible.toggle()
                        }
                    }).foregroundStyle(Color("DefaultBlack")).font(.title).padding(2).background(Color("DefaultWhite")).cornerRadius(20).shadow(radius: 5, x: 5, y: 5).labelStyle(.iconOnly)
                    
                    HStack {
                        Button("Previous Day", systemImage: "arrowshape.backward.circle.fill", action: {
                            appModel.displayedDate = Calendar.current.date(byAdding: .day, value: -1, to: appModel.displayedDate)!
                        }).foregroundStyle(Color("DefaultBlack")).font(.title).padding(2).labelStyle(.iconOnly)
                        
                        Spacer()
                        
                        Button("\(appModel.displayedDate.formatted(date: .complete, time: .omitted).uppercased())", action: {
                            appModel.displayedDate = Date()
                        }).font(.title2).foregroundColor((Color("DefaultBlack")))
                        
                        Spacer()
                        
                        Button("Next Day", systemImage: "arrowshape.forward.circle.fill", action: {
                            appModel.displayedDate = Calendar.current.date(byAdding: .day, value: 1, to: appModel.displayedDate)!
                        }).foregroundStyle(Color("DefaultBlack")).font(.title).padding(2).labelStyle(.iconOnly)
                        
                        
                        
                    }.background(Color("DefaultWhite")).cornerRadius(20).shadow(radius: 5, x: 5, y: 5)
                    
                    
                    
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape.circle.fill").foregroundStyle(Color("DefaultBlack")).font(.title).padding(2).background(Color("DefaultWhite")).cornerRadius(20).shadow(radius: 5, x: 5, y: 5).labelStyle(.iconOnly)
                    }
                }.padding(.bottom, 10)
                
            } // END HEADER
        }
    }

#Preview {
    AppHeader()
}
