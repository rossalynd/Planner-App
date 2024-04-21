//
//  Celestial.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 4/3/24.
//

import SwiftUI

struct Celestial: View {
    
    var image: Image = Image("celestial")
    
    
    var body: some View {
        VStack(spacing: 0) {
        
        ForEach(0..<5) { column in
            
            HStack(spacing: 0) {
                ForEach(0..<5) { row in
                  
                        
                        
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 500, height: 500)
                    }
                    
                    
                }
            }
        }
        
    }
}

#Preview {
    Celestial()
}
