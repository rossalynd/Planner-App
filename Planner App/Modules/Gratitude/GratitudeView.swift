//
//  GratitudeView.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/23/24.
//

import SwiftUI

struct GratitudeView: View {
    @EnvironmentObject var appModel: AppModel
    @State private var gratitudeText: String = ""
    @State private var isEditing: Bool = false
    
    private var gratitudeManager = GratitudeManager.shared
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                Spacer()
                if gratitudeText.isEmpty && !isEditing {
                    Text("What are you grateful for?").font(Font.custom(appModel.headerFont, size: 20)).foregroundColor(appModel.headerColor).multilineTextAlignment(.center)
                }
                    if isEditing {
                        
                        TextField("What are you grateful for?", text: $gratitudeText)
                            .onSubmit {
                                gratitudeManager.saveGratitude(text: gratitudeText, for: appModel.displayedDate)
                                isEditing = false
                            }
                            .textFieldStyle(.plain).background(Color.clear).multilineTextAlignment(.center).submitLabel(.done)
                            .padding()
                            .onAppear {
                                self.gratitudeText = gratitudeManager.gratitudeText(for: appModel.displayedDate)
                            }
                    
                } else {
                    
                        Text(appModel.headerCase.apply(to: gratitudeText.isEmpty ? "" : gratitudeText)).font(Font.custom(appModel.headerFont, size: 20)).foregroundColor(appModel.headerColor).multilineTextAlignment(.center).lineSpacing(-200)
                    }
                
           Spacer()
            }
            .onKeyPress(.return, action: {
                self.isEditing = false
                self.gratitudeText = gratitudeManager.gratitudeText(for: appModel.displayedDate)
                return .handled
            })
            .onTapGesture {
               self.isEditing = true
               self.gratitudeText = gratitudeManager.gratitudeText(for: appModel.displayedDate)
           }
            .onChange(of: appModel.displayedDate) { oldDate, newDate in
                self.gratitudeText = gratitudeManager.gratitudeText(for: newDate)
                self.isEditing = self.gratitudeText.isEmpty
            }
            
        }
    }
}

#Preview {
   ContentView()
        .environmentObject(AppModel())
        .environmentObject(TasksUpdateNotifier())
        .modelContainer(for: [MoodEntry.self, Note.self])
}
