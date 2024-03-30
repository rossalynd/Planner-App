//
//  HorizontalSlider.swift
//  Planner App
//
//  Created by Rosie on 3/24/24.
//

import SwiftUI

struct HorizontalSlider: View {
    @Binding var value: CGFloat // Binding to the value you want to adjust
    var range: ClosedRange<CGFloat> // The range of values the slider can adjust
    var onEditingChanged: (Bool) -> Void

    var sliderWidth: CGFloat = 200 // Define the horizontal slider's width
    var sliderHeight: CGFloat = 50 // Define the slider's height for the touchable area

    var body: some View {
        ZStack {
            // The actual slider track
            Rectangle()
                .fill(Color(hue: 1.0, saturation: 0.01, brightness: 0.546, opacity: 0.553))
                .frame(width: sliderWidth, height: 10) // Use sliderWidth for dynamic sizing
                .cornerRadius(20)
            
            // The draggable slider "handle"
            ZStack {
                
                Circle()
                    .fill(Color.black)
                    .frame(width: 40, height: 40)
                    .padding(2)
                    .background(.white).clipShape(Circle()).shadow(radius: 2, x: 3, y: 3)
                // Circle dimensions
                    .offset(x: self.valueToX(value: value, width: sliderWidth, range: range) - sliderWidth / 2)
                
                Text(value, format: .number.precision(.fractionLength(1)))
                    .offset(x: self.valueToX(value: value, width: sliderWidth, range: range) - sliderWidth / 2).bold().foregroundStyle(.white)
            }
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        // Adjust for the offset
                        let adjustedLocationX = gesture.location.x + sliderWidth / 2 - 25 // Adjusting for the slider's position
                        
                        self.onEditingChanged(true)
                        self.value = self.xToValue(x: adjustedLocationX, width: sliderWidth, range: range)
                    }
                    .onEnded { _ in
                        self.onEditingChanged(false)
                    }
            )
            
        }
        .frame(width: sliderWidth, height: sliderHeight)
    }

    // Convert value to X position
    private func valueToX(value: CGFloat, width: CGFloat, range: ClosedRange<CGFloat>) -> CGFloat {
        let valueRange = range.upperBound - range.lowerBound
        let xOffset = ((value - range.lowerBound) / valueRange) * width
        return xOffset
    }

    // Convert X position back to value
    private func xToValue(x: CGFloat, width: CGFloat, range: ClosedRange<CGFloat>) -> CGFloat {
        let valueRange = range.upperBound - range.lowerBound
        var value = ((x / width) * valueRange) + range.lowerBound
        value = min(max(value, range.lowerBound), range.upperBound)
        return value
    }
}

