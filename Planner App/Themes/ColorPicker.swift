//
//  ColorPicker.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/27/24.
//

import SwiftUI

struct ColorPickerView: View {
    @Binding var selectedColor: Color

    var body: some View {
        VStack {
           
                // Display the Color Picker
                ColorPicker("", selection: $selectedColor)
                .onChange(of: selectedColor) { oldValue, newValue in
                    selectedColor = newValue
                }
        }
    }
}

