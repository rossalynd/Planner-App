//
//  MoodView.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/23/24.
//

import SwiftUI
import SwiftUI

struct MoodView: View {
    @State private var showPopover: Bool = false
    @State private var currentMood: Mood = .happy // Default mood, can be changed
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Image(currentMood.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .padding()
                    .onTapGesture {
                        self.showPopover = true
                    }
                    .popover(isPresented: $showPopover) {
                        HStack(spacing: 10) {
                            ForEach(Mood.allCases, id: \.self) { mood in
                                Image(mood.imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .onTapGesture {
                                        self.currentMood = mood
                                        MoodManager.shared.saveMood(mood)
                                        self.showPopover = false
                                    }
                            }
                        }.padding(10)
                        
                    }
            }
        }.frame(maxHeight: .infinity)
    }
}

#Preview {
    MoodView()
}
