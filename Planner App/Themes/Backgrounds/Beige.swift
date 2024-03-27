//
//  Beige.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/27/24.
//

import Foundation
import SwiftUI

struct BeigeBackground: View {
    
    
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [Color("Beige"),Color("Beige")]), startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    BeigeBackground()
}
