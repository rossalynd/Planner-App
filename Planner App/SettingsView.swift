//
//  SettingsView.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/27/24.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var appModel: AppModel
    
    var body: some View {
        ZStack(alignment: .leading) {
            VStack {
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
            // Assuming themedBackground is a custom modifier you have defined elsewhere.
                .themedBackground(appModel: appModel)
            VStack {
                Text("Settings").font(.title)
                
                Picker("Start of Week", selection: $appModel.startOfWeek) {
                    Text("Sunday").tag(WeekStartDay.sunday)
                    Text("Monday").tag(WeekStartDay.monday)
                }
                
                ChooseThemeView()
                Spacer()
                
            }.padding(20).background(Color("DefaultWhite")).clipShape(RoundedRectangle(cornerRadius: appModel.moduleCornerRadius)).padding(50)
        }.onDisappear() {
            appModel.saveSettings()
            print("Saving settings")
        }
        
    }
    
    
}

#Preview {
    SettingsView()
        .environmentObject(AppModel())

}

