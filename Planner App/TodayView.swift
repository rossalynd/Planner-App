
//  TodayView.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/21/24.
//

import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var todayBoxes = [TodayBox]() // Track boxes
    @State private var editMode: EditMode = .inactive
    @State private var showingAddModuleViewLeft = false // To control the presentation from left column
    @State private var showingAddModuleViewRight = false // To control the presentation from right column
    @State private var selectedModuleType: String?
    @State private var showingReplaceModuleViewLeft = false // To control the presentation for replacing a module
    @State private var showingReplaceModuleViewRight = false // To control the presentation for replacing a module
    @State private var indexToReplace: Int?

    
    var body: some View {
        
        
        
        GeometryReader { geometry in
            HStack(spacing: 15) {
                //Left Column -- SMALL BOXES
                VStack {
                    
                    // Button to add Box
                    if editMode == .active {
                        HStack {
                            Spacer()
                            Button("Add", systemImage: "plus.circle.fill", action: {
                                showingAddModuleViewLeft = true
                            })
                            .labelStyle(.iconOnly).padding()
                        }
                    }
                    
                    ForEach(todayBoxes.filter { $0.size == .small }) { id in
                        
                        //Edit Mode Buttons
                        if editMode == .active {
                            
                            HStack {
                                //Up Button
                                Button(action: {
                                    if let currentIndex = todayBoxes.firstIndex(of: id),
                                       currentIndex > 0 {
                                        todayBoxes.swapAt(currentIndex, currentIndex - 1)
                                    }
                                }) {
                                    Image(systemName: "chevron.up.circle.fill")
                                }
                                
                                
                                //Down Button
                                Button(action: {
                                    if let currentIndex = todayBoxes.firstIndex(of: id),
                                       currentIndex < todayBoxes.count - 1 {
                                        todayBoxes.swapAt(currentIndex, currentIndex + 1)
                                    }
                                }) {
                                    Image(systemName: "chevron.down.circle.fill")
                                }
                                
                                
                                //Replace button
                                Button(action: {
                                    // Ensure 'id' is a UUID representing the 'id' of a TodayBox
                                    if let currentIndex = todayBoxes.firstIndex(of: id) {
                                        indexToReplace = currentIndex // Correctly finds the index based on UUID comparison
                                        showingReplaceModuleViewLeft = true
                                    }
                                }) {
                                    Image(systemName: "arrow.2.squarepath")
                                }
                                
                                .sheet(isPresented: $showingReplaceModuleViewLeft) {
                                    // Assuming AddModuleView correctly handles selection and returns a String type for the module
                                    AddModuleView(onSelect: { selectedType in
                                        if let replaceIndex = indexToReplace, replaceIndex >= 0 && replaceIndex < todayBoxes.count {
                                            let newBox = TodayBox(type: selectedType, size: .small) // Create a new TodayBox with the selected type
                                            todayBoxes[replaceIndex] = newBox // Replace at the stored index
                                            showingReplaceModuleViewLeft = false
                                            indexToReplace = nil // Reset
                                        }
                                    })
                                }
                                
                                //Remove button
                                Button(action: {
                                    if let currentIndex = todayBoxes.firstIndex(of: id) {
                                        todayBoxes.remove(at: currentIndex)
                                    }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                }
                                
                                
                            }
                        }
                        // View Box
                        TodayBoxView(todayBoxType: id.type, scale: .small)
                            .id(id)
                        
                    }
                    
                    Spacer()
                }.frame(width: geometry.size.width * 3 / 8)
                
                
                
                
                
                
                
                
                
                
                //Right Column -- LARGE BOXES
                VStack {
                    // Button to add Box
                    if editMode == .active {
                        HStack {
                            Spacer()
                            Button("Add", systemImage: "plus.circle.fill", action: {
                                showingAddModuleViewRight = true
                            })
                            .labelStyle(.iconOnly).padding()
                        }
                    }
                    ForEach(todayBoxes.filter { $0.size == .large }) { id in
                        
                        if editMode == .active {
                            //Buttons to move up and down
                            HStack {
                                //Up Button
                                Button(action: {
                                    if let currentIndex = todayBoxes.firstIndex(of: id),
                                       currentIndex > 0 {
                                        todayBoxes.swapAt(currentIndex, currentIndex - 1)
                                    }
                                }) {
                                    Image(systemName: "chevron.up.circle.fill")
                                }
                                .disabled(todayBoxes.first == id || editMode == .inactive)
                                
                                //Down Button
                                Button(action: {
                                    if let currentIndex = todayBoxes.firstIndex(of: id),
                                       currentIndex < todayBoxes.count - 1 {
                                        todayBoxes.swapAt(currentIndex, currentIndex + 1)
                                    }
                                }) {
                                    Image(systemName: "chevron.down.circle.fill")
                                }
                                .disabled(todayBoxes.last == id || editMode == .inactive)
                                
                                //Replace button
                                Button(action: {
                                    // Ensure 'id' is a UUID representing the 'id' of a TodayBox
                                    if let currentIndex = todayBoxes.firstIndex(of: id) {
                                        indexToReplace = currentIndex // Correctly finds the index based on UUID comparison
                                        showingReplaceModuleViewRight = true
                                    }
                                }) {
                                    Image(systemName: "arrow.2.squarepath")
                                }
                                .disabled(todayBoxes.isEmpty)
                                .sheet(isPresented: $showingReplaceModuleViewRight) {
                                    // Assuming AddModuleView correctly handles selection and returns a String type for the module
                                    AddModuleView(onSelect: { selectedType in
                                        if let replaceIndex = indexToReplace, replaceIndex >= 0 && replaceIndex < todayBoxes.count {
                                            let newBox = TodayBox(type: selectedType, size: .large) // Create a new TodayBox with the selected type
                                            todayBoxes[replaceIndex] = newBox // Replace at the stored index
                                            showingReplaceModuleViewRight = false
                                            indexToReplace = nil // Reset
                                        }
                                    })
                                }
                                
                                //Remove button
                                Button(action: {
                                    if let currentIndex = todayBoxes.firstIndex(of: id) {
                                        todayBoxes.remove(at: currentIndex)
                                    }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                }
                                .disabled(editMode == .inactive)
                                
                            }
                        }
                        TodayBoxView(todayBoxType: id.type, scale: .large)
                            .id(id)
                        
                        
                    }
                    
                    Spacer()
                }.frame(minWidth: 0, maxWidth: .infinity)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(editMode == .active ? "Done" : "Edit") {
                        editMode = editMode == .active ? .inactive : .active
                    }
                }
            }
            .sheet(isPresented: $showingAddModuleViewLeft) {
                AddModuleView(onSelect: { selectedType in
                    let newBox = TodayBox(type: selectedType, size: .small) // Specify size as .small
                    todayBoxes.append(newBox)
                    showingAddModuleViewLeft = false
                })
            }
            .sheet(isPresented: $showingAddModuleViewRight) {
                AddModuleView(onSelect: { selectedType in
                    let newBox = TodayBox(type: selectedType, size: .large) // Specify size as .large
                    todayBoxes.append(newBox)
                    showingAddModuleViewRight = false
                })
            }
        }.environment(\.editMode, $editMode)
    }
}
    

    




#Preview {
    TodayView()
}
