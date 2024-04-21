//
//  PinkDaisies.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 4/3/24.
//

import SwiftUI

struct PinkDaisies: View, ShapeStyle {
    
    
    var image: Image = Image("pinkdaisies")
    
    
    var body: some View {
        CreateSeamlessPattern(image: image)
        
    }
}

#Preview {
   PinkDaisies()
}


