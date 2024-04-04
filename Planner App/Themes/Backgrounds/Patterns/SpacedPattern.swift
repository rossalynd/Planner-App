//
//  SpacedPattern.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/27/24.
//

import SwiftUI
import SwiftUI

struct SpacedPattern: View {
    let image: Image
    let imageSize: CGSize
    let spacing: CGFloat
    
    
    var body: some View {
        GeometryReader { geometry in
            let columns = Int((geometry.size.width / (imageSize.width + spacing)).rounded(.down))
            let rows = Int((geometry.size.height / (imageSize.height + spacing)).rounded(.down))
            
            ZStack {
                ForEach(0..<rows, id: \.self) { row in
                    ForEach(0..<columns, id: \.self) { column in
                        image
                            .resizable()
                            .frame(width: imageSize.width, height: imageSize.height)
                            .position(x: positionX(forColumn: column, inRow: row),
                                      y: CGFloat(row) * (imageSize.height + spacing) + imageSize.height / 2)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity).padding()
        }
    }
    
    private func positionX(forColumn column: Int, inRow row: Int) -> CGFloat {
        let baseX = CGFloat(column) * (imageSize.width + spacing) + imageSize.width / 2
        if row % 2 == 1 {
            // Shift every other row to the right by half of the (image width + spacing)
            return baseX + (imageSize.width + spacing) / 2
        } else {
            return baseX
        }
    }
}


struct SpacedPattern_Previews: PreviewProvider {
    static var previews: some View {
        // This is where you instantiate SpacedPattern and return it for the preview
        let image = Image(systemName: "heart.fill")
        let imageSize = CGSize(width: 20, height: 20)
        let spacing: CGFloat = 20
        
        SpacedPattern(image: image, imageSize: imageSize, spacing: spacing).padding()
    }
}

