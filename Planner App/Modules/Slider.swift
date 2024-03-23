//
//  Slider.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/23/24.
//

import SwiftUI

struct VerticalSlider: View {
    @Binding var value: CGFloat // Binding to the value you want to adjust
    var range: ClosedRange<CGFloat> // The range of values the slider can adjust
    var onEditingChanged: (Bool) -> Void

    var sliderLength: CGFloat = 200 // Define the vertical slider's length
    var sliderWidth: CGFloat = 20 // Define the slider's width for the touchable area

    var body: some View {
        ZStack {
            // The actual slider track
            Rectangle()
                .fill(Color.white)
                .frame(width: 5, height: sliderLength) // Use sliderLength for dynamic sizing
                .cornerRadius(2.5)
                
            // The draggable slider "handle"
            Circle()
                .fill(Color.blue)
                .frame(width: 20, height: 20) // Circle dimensions
                .offset(y: self.valueToY(value: value, height: sliderLength, range: range) - sliderLength / 2)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            // Adjust for the offset
                            let adjustedLocationY = gesture.location.y + 100 // Adjusting for the top of the slider being at -100
                            
                            self.onEditingChanged(true)
                            let newHeight = adjustedLocationY
                            self.value = self.yToValue(y: newHeight, height: sliderLength, range: range)
                        }
                        .onEnded { _ in
                            self.onEditingChanged(false)
                        }
                )
        }
        .frame(width: sliderWidth, height: sliderLength)
    }

    // Convert value to Y position
    private func valueToY(value: CGFloat, height: CGFloat, range: ClosedRange<CGFloat>) -> CGFloat {
        let valueRange = range.upperBound - range.lowerBound
        let yOffset = ((value - range.lowerBound) / valueRange) * height
        return yOffset
    }

    // Convert Y position back to value
    private func yToValue(y: CGFloat, height: CGFloat, range: ClosedRange<CGFloat>) -> CGFloat {
        let valueRange = range.upperBound - range.lowerBound
        var value = ((y / height) * valueRange) + range.lowerBound
        value = min(max(value, range.lowerBound), range.upperBound)
        return value
    }
}

#Preview {
    NotesView()
}
