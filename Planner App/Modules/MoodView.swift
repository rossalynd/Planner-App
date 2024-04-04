//
//  MoodView.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/23/24.
//

import SwiftUI
import SwiftData


struct MoodView: View {
    @EnvironmentObject var appModel: AppModel // Inject DateHolder to access the displayedDate
    @Environment(\.modelContext) private var context
    @State private var showPopover: Bool = false
    @Query var entries: [MoodEntry]
    
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Image(entries.filter { $0.date.startOfDay == appModel.displayedDate.startOfDay }.sorted(by: { $0.date > $1.date }).first?.mood.rawValue ?? "none")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .padding()
                    .onTapGesture {
                        self.showPopover = true
                    }
                    .popover(isPresented: $showPopover) {
                        HStack(spacing: 10) {
                            ForEach(Mood.allCases.filter { $0 != .none }, id: \.self) { mood in
                                Image("\(mood.rawValue)")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .onTapGesture {
                                        
                                            if appModel.displayedDate.startOfDay == Date().startOfDay {
                                                let savedDate = Date()
                                                context.insert(MoodEntry(mood: mood, date: savedDate))
                                                context.processPendingChanges()
                                                print("Saved mood \(mood) to \(savedDate)")
                                            } else {
                                                let savedDate = appModel.displayedDate
                                                context.insert(MoodEntry(mood: mood, date: savedDate))
                                                context.processPendingChanges()
                                                print("Saved mood \(mood) to \(savedDate)")
                                            }
                                        self.showPopover = false
                                    }
                            }
                        }
                        .padding(10)
                    }
            }
        }
        .frame(maxHeight: .infinity)
    }
}








