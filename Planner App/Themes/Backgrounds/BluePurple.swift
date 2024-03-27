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
        LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    BluePurpleGradientBackground()
}
