
//  TodayView.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/21/24.
//


import SwiftUI
import SwiftData

struct PortraitView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var appModel: AppModel

    var body: some View {
#if os(iOS)
        VStack {
            
            // Dynamically choose between iPad and iPhone views at runtime
            if UIDevice.current.userInterfaceIdiom == .pad {
                DayView()
            } else {
                iPhoneDayView()
            }
        }.background(.clear)
#elseif os(watchOS)
            Text("Hello, watchOS!")
            #elseif os(macOS)
            Text("Hello, macOS!")
            #else
            Text("Unsupported platform")
            #endif
    }
}
    

    




