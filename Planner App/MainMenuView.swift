//
//  MainMenuView.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/25/24.
//

import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var appModel: AppModel
    @Binding var isMenuVisible: Bool
    @State var smallSpaceTop = "Calendar"
    
    var body: some View {
        VStack(alignment: .leading) {
            
            ZStack {
                VStack {
                    
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                .themedBackground(appModel: appModel)
                VStack(spacing:15) {
                    SpaceView(type: smallSpaceTop, scale: .small, layoutType: .elsePortrait).frame(maxHeight: 230).padding([.top, .leading, .trailing]).padding(.top, 30)
                    
                    NavigationStack{
                        NavigationLink {MiniMonthCalendarView(scale: .large, layoutType: .elsePortrait, appModel: appModel)} label: {Text("Calendar")}
                        NavigationLink {TimelineView(layoutType: .elsePortrait, scale: .large, date: appModel.displayedDate)} label: {Text("Timeline")}
                        NavigationLink {YearlyMoodView()} label: {Text("Yearly Mood")}
                            
                        
                       
                        Text("Menu Item One")
                        Text("Menu Item One")
                        
                    }.frame(maxWidth: .infinity).padding().background(Color("DefaultWhite")).clipShape(RoundedRectangle(cornerRadius: appModel.moduleCornerRadius)).padding(.horizontal)
                    Spacer()
                }
            }
        }// Adjust the menu width as needed
            .background(Color.white)
            .edgesIgnoringSafeArea(.all)
            .clipShape(RightRoundedRectangle(radius: appModel.moduleCornerRadius))
    }
}





struct RightRoundedRectangle: Shape {
    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let topLeft = rect.origin
        let topRight = CGPoint(x: rect.maxX, y: rect.minY)
        let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)
        let bottomLeft = CGPoint(x: rect.minX, y: rect.maxY)
        
        path.move(to: topLeft)
        path.addLine(to: CGPoint(x: topRight.x - radius, y: topRight.y))
        path.addArc(center: CGPoint(x: topRight.x - radius, y: topRight.y + radius), radius: radius, startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)
        path.addLine(to: CGPoint(x: bottomRight.x, y: bottomRight.y - radius))
        path.addArc(center: CGPoint(x: bottomRight.x - radius, y: bottomRight.y - radius), radius: radius, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        path.addLine(to: bottomLeft)
        path.closeSubpath()
        
        return path
    }
}

