//
//  BluePurple.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/27/24.
//

import Foundation
import SwiftUI

struct BluePurpleGradientBackground: View {
    var body: some View {
        ZStack {
            
            LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            Color.defaultClear.frame(maxWidth: .infinity, maxHeight: .infinity).ignoresSafeArea()
        }
    }
}

#Preview {
    BluePurpleGradientBackground()
}
