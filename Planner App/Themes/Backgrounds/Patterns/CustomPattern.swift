//
//  CustomPattern.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/27/24.
//

import SwiftUI

struct CustomPattern: View {
    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(self.patternImagePaint(in: geometry.size))
                .edgesIgnoringSafeArea(.all)
        }
    }
    
    private func patternImagePaint(in size: CGSize) -> ImagePaint {
        // Assuming the image is named "CustomPattern" in your asset catalog
        let image = Image(systemName: "heart.circle.fill")
        // ImagePaint allows the image to be used as a paint source, the scale can be adjusted as needed
        return ImagePaint(image: image, scale: 2) // Adjust the scale as needed for your pattern
    }
}

#Preview {
    CustomPattern()
}
