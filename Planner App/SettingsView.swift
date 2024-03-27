//
//  SettingsView.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/27/24.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var themeController: ThemeController
    @EnvironmentObject var customColor: CustomColor
    var body: some View {
        VStack {
            Text("Settings").font(.title)
            ChooseThemeView()
            
        }.padding()
    }
}

#Preview {
    SettingsView()
        .environmentObject(CustomColor())
        .environmentObject(ThemeController())
}
