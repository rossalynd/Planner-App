
//  TodayView.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/21/24.
//


import SwiftUI
import SwiftData

struct PortraitView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var dateHolder: DateHolder

    var body: some View {
#if os(iOS)
            // Dynamically choose between iPad and iPhone views at runtime
        if UIDevice.current.userInterfaceIdiom == .pad {
            TodayLayoutView()
        } else {
            iPhoneLayoutView()
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
    PortraitView()
        .environmentObject(DateHolder())
        .environmentObject(ThemeController())
}
