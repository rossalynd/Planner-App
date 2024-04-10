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
        
       
                
                
                HStack(spacing: appModel.moduleSpacing) {
                    
                    Button("Menu", systemImage: "line.3.horizontal.circle.fill", action: {
                        withAnimation {
                            appModel.isMenuVisible.toggle()
                        }
                    }).foregroundStyle(Color("DefaultBlack")).font(.title).padding(2).background(Color("DefaultWhite")).cornerRadius(appModel.moduleCornerRadius).shadow(radius: 5, x: 5, y: 5).labelStyle(.iconOnly)
                    
                    HStack {
                        Button("Previous Day", systemImage: "arrowshape.backward.circle.fill", action: {
                            appModel.displayedDate = Calendar.current.date(byAdding: .day, value: -1, to: appModel.displayedDate)!
                        }).foregroundStyle(Color("DefaultBlack")).font(.title).padding(2).labelStyle(.iconOnly)
                        
                        Spacer()
                        
                        Button("\(appModel.headerCase.apply(to:appModel.displayedDate.formatted(date: .complete, time: .omitted)))", action: {
                            appModel.displayedDate = Date()
                        }).font(Font.custom(appModel.headerFont, size: 20)).foregroundColor(appModel.headerColor)
                        
                        Spacer()
                        
                        Button("Next Day", systemImage: "arrowshape.forward.circle.fill", action: {
                            appModel.displayedDate = Calendar.current.date(byAdding: .day, value: 1, to: appModel.displayedDate)!
                        }).foregroundStyle(Color("DefaultBlack")).font(.title).padding(2).labelStyle(.iconOnly)
                        
                        
                        
                    }.background(Color("DefaultWhite")).cornerRadius(appModel.moduleCornerRadius).shadow(radius: 5, x: 5, y: 5)
                    
                    
                    
                    NavigationLink(destination: SettingsView(appModel: appModel)) {
                        Image(systemName: "gearshape.circle.fill").foregroundStyle(Color("DefaultBlack")).font(.title).padding(2).background(Color("DefaultWhite")).cornerRadius(appModel.moduleCornerRadius).shadow(radius: 5, x: 5, y: 5).labelStyle(.iconOnly)
                    }
                }
                    
                
                
           
                
                
              
                 // END HEADER
        }
    }

#Preview {
    AppHeader()
}
