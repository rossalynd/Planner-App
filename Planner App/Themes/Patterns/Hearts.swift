//
//  Hearts.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/28/24.
//

import SwiftUI

struct Hearts: View {
    
    let image = Image(systemName: "heart.fill")
    let imageSize = CGSize(width: 50, height: 50)
    let spacing: CGFloat = 20
    
    
    var body: some View {
        SpacedPattern(image: image, imageSize: imageSize, spacing: spacing)
    }
}

#Preview {
    Hearts()
}
