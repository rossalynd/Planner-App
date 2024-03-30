//
//  LandscapeView.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/28/24.
//


import SwiftUI
import SwiftData

struct LandscapeView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var dateHolder: DateHolder

    var body: some View {
#if os(iOS)
            // Dynamically choose between iPad and iPhone views at runtime
        if UIDevice.current.userInterfaceIdiom == .pad {
            TodayLayoutView()
        } else {
            iPhoneLandscapeView()
        }
#elseif os(watchOS)
            Text("Hello, watchOS!")
            #elseif os(macOS)
            Text("Hello, macOS!")
            #else
            Text("Unsupported platform")
            #endif
    }
}
    

    




#Preview {
    LandscapeView()
        .environmentObject(DateHolder())
        .environmentObject(ThemeController())
}
