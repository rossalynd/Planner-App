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
    @EnvironmentObject var dateHolder: DateHolder
    
    var body: some View {
        VStack {
            Text("Settings").font(.title)
            Picker("Start of Week", selection: $dateHolder.startOfWeek) {
                Text("Monday").tag(WeekStartDay.sunday)
                Text("Sunday").tag(WeekStartDay.monday)
            }
            
            ChooseThemeView()
            
        }.padding()
    }
}

#Preview {
    SettingsView()
        .environmentObject(CustomColor())
        .environmentObject(ThemeController())
        .environmentObject(DateHolder())
}

