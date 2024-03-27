//
//  CustomBackground.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/27/24.
//

import SwiftUI

struct CustomBackground: View {
    @EnvironmentObject var color: CustomColor
    var mainColor: Color = .white
    var secondaryColor: Color? = nil
    
    var body: some View {
        Group {
            if secondaryColor != mainColor {
                // If secondaryColor is not nil, create a LinearGradient with both colors
                LinearGradient(gradient: Gradient(colors: [color.color, color.secondaryColor]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
            } else {
                // If secondaryColor is nil, use mainColor as a solid background
                mainColor
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
}


#Preview {
    CustomBackground(mainColor: .blue, secondaryColor: .gray)
        .environmentObject(CustomColor())
}
