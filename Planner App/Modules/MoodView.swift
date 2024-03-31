//
//  MoodView.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/23/24.
//

import SwiftUI
import SwiftUI

import SwiftUI

struct MoodView: View {
    @EnvironmentObject var dateHolder: DateHolder // Inject DateHolder to access the displayedDate
    @State private var showPopover: Bool = false
    @State private var currentMood: Mood = .none // Default mood, will be updated based on the displayedDate

    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Image(currentMood.imageName) // Assuming you're using system images or have these named images in your assets
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .padding()
                    .onTapGesture {
                        self.showPopover = true
                    }
                    .popover(isPresented: $showPopover) {
                        HStack(spacing: 10) {
                            ForEach(Mood.allCases.filter {$0 != .none}, id: \.self) { mood in
                                Image(mood.imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .onTapGesture {
                                        self.currentMood = mood
                                        MoodManager.shared.saveMood(mood, forDate: dateHolder.displayedDate)
                                        self.showPopover = false
                                    }
                            }
                        }.padding(10)
                    }
            }
        }
        .frame(maxHeight: .infinity)
        .onAppear {
            loadMoodForDisplayedDate()
        }
        .onChange(of: dateHolder.displayedDate) {
            loadMoodForDisplayedDate()
        }
    }

    private func loadMoodForDisplayedDate() {
        if let moodForDate = MoodManager.shared.mood(forDate: dateHolder.displayedDate) {
            self.currentMood = moodForDate
        } else {
            self.currentMood = .none
        }
    }
}

// Ensure you have an ObservableObject that holds the displayed date.
// You should already have this based on your previous code


#Preview {
    MoodView()
        .environmentObject(DateHolder())
}
