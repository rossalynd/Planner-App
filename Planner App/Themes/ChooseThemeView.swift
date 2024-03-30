//
//  ChooseThemeView.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/27/24.
//

import SwiftUI

struct ChooseThemeView: View {
    @EnvironmentObject var color: CustomColor
    @EnvironmentObject var theme: ThemeController
    @State var backgroundChoice: String = "Default"
    @State var isGradient: Bool = false
    var body: some View {
        ZStack(alignment: .leading) {
            VStack {
                HStack {
                    Text("Background")
                    Spacer()
                    Picker("Background Type", selection: $theme.backgroundType) {
                        ForEach(ThemeController.BackgroundType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }.pickerStyle(MenuPickerStyle())
                if theme.backgroundType == .custom {
                    HStack {
                        Text("Choose Color")
                        ColorPickerView(selectedColor: $color.color).onChange(of: color.color) { oldValue, newValue in
                            if !isGradient {
                                color.secondaryColor = color.color
                            }
                        }
                    }
                    if isGradient {
                        HStack {
                            Text("Choose Gradient Color")
                            ColorPickerView(selectedColor: $color.secondaryColor)
                        }
                    }
                    Toggle("Gradient", isOn: $isGradient).onChange(of: isGradient) { oldValue, newValue in
                        if !newValue {
                            // Set secondaryColor to nil if not a gradient
                            color.secondaryColor = color.color
                        }
                    }
                }
                
                HStack {
                    Text("Background")
                    Spacer()
                    Picker("Background Type", selection: $theme.overlayType) {
                        ForEach(ThemeController.OverlayType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
                
            }.padding()
                .onAppear {
                    if isGradient == false {
                        color.secondaryColor = color.color
                    }
                }
        }
    }
}

#Preview {
    ChooseThemeView()
        .environmentObject(ThemeController())
        .environmentObject(CustomColor())
}
