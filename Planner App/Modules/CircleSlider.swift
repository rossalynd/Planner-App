//
//  CircleSlider.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/23/24.
//

import SwiftUI

struct CircleSlider: View {
    @Binding var value: CGFloat // Binding to the value you want to adjust
    var range: ClosedRange<CGFloat> // Adjusted for demonstration
    var onEditingChanged: (Bool) -> Void

    // A mock function to mimic the scaling of .monoline pen sizes.
    // Adjust this function based on actual observations or scaling data.
    private func scaledCircleSize(forValue value: CGFloat) -> CGFloat {
        let minSize: CGFloat = 10
        let maxSize: CGFloat = 60
        // Assuming a non-linear scaling, adjust this formula as needed
        let scaleFactor = pow((value - range.lowerBound) / (range.upperBound - range.lowerBound), 0.5) // Square root scaling for demonstration
        return minSize + (maxSize - minSize) * scaleFactor
    }

    var body: some View {
        VStack {
            
            
            Circle()
                .fill(Color.blue)
                .frame(width: scaledCircleSize(forValue: value), height: scaledCircleSize(forValue: value))
                .overlay(Text("\(Int(value))").foregroundColor(.white))
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            self.onEditingChanged(true)
                            let sensitivity: CGFloat = 1
                            let delta = gesture.translation.height * sensitivity
                            self.value -= delta
                            self.value = min(max(range.lowerBound, self.value), range.upperBound)
                        }
                        .onEnded { _ in
                            self.onEditingChanged(false)
                        }
                )
                .animation(.linear, value: value)
        }
    }
}
