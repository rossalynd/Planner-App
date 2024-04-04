//
//  CreateSeamlessPattern.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 4/3/24.
//

import SwiftUI

struct CreateSeamlessPattern: View, ShapeStyle {
    
    
    let image: Image
    
    
    var body: some View {
        VStack(spacing: 0) {
               
                    HStack(spacing: 0) {
                    
                        image
                            .resizable()
                            .scaledToFill()
                            .scaleEffect(x: 1, y: 1)
                            .frame(width: 500, height: 500)// Adjust size as needed
                        image
                            .resizable()
                            .scaledToFill()
                            .scaleEffect(x: -1, y: 1)
                            .frame(width: 500, height: 500)// Adjust size as needed
                        image
                            .resizable()
                            .scaledToFill()
                            .scaleEffect(x: 1, y: 1)
                            .frame(width: 500, height: 500)// Adjust size as needed
                    }.scaleEffect(x: 1, y: -1)
                    HStack(spacing: 0) {
                    
                        image
                            .resizable()
                            .scaledToFill()
                            .scaleEffect(x: 1, y: 1)
                            .frame(width: 500, height: 500)// Adjust size as needed
                        image
                            .resizable()
                            .scaledToFill()
                            .scaleEffect(x: -1, y: 1)
                            .frame(width: 500, height: 500)// Adjust size as needed
                        image
                            .resizable()
                            .scaledToFill()
                            .scaleEffect(x: 1, y: 1)
                            .frame(width: 500, height: 500)// Adjust size as needed
                    }
            HStack(spacing: 0) {
            
                image
                    .resizable()
                    .scaledToFill()
                    .scaleEffect(x: 1, y: 1)
                    .frame(width: 500, height: 500)// Adjust size as needed
                image
                    .resizable()
                    .scaledToFill()
                    .scaleEffect(x: -1, y: 1)
                    .frame(width: 500, height: 500)// Adjust size as needed
                image
                    .resizable()
                    .scaledToFill()
                    .scaleEffect(x: 1, y: 1)
                    .frame(width: 500, height: 500)// Adjust size as needed
            }.scaleEffect(x: 1, y: -1)
                
            }
        }
    

}
