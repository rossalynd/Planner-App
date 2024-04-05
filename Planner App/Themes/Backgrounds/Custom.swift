//
//  CustomBackground.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/27/24.
//

import SwiftUI

struct CustomBackground: View {
    @EnvironmentObject var appModel: AppModel
    var mainColor: Color = .white
    var secondaryColor: Color? = nil
    
    var body: some View {
        
        ZStack {
            
            
            Group {
                if secondaryColor != mainColor {
                    // If secondaryColor is not nil, create a LinearGradient with both colors
                    LinearGradient(gradient: Gradient(colors: [appModel.color, appModel.secondaryColor]), startPoint: .top, endPoint: .bottom)
                        .edgesIgnoringSafeArea(.all)
                } else {
                    // If secondaryColor is nil, use mainColor as a solid background
                    mainColor
                        .edgesIgnoringSafeArea(.all)
                }
            }
            
            Color.defaultClear.frame(maxWidth: .infinity, maxHeight: .infinity).ignoresSafeArea()
            
        }
    }
}


#Preview {
    CustomBackground(mainColor: .blue, secondaryColor: .gray)
        .environmentObject(AppModel())
}
