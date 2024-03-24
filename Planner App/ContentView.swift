//
//  ContentView.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/21/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var dateHolder: DateHolder
    

    var body: some View {
        

        NavigationStack {
            
            
            ZStack {
                VStack {
                    // Gradient Background
                    LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .top, endPoint: .bottom)
                        .edgesIgnoringSafeArea(.all)
                    
                }
                TodayView()
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            HStack {
                                
                                    Button("Edit", systemImage: "slider.horizontal.3", action: {
                                        
                                    }).foregroundStyle(Color("DefaultBlack")).background(Color("DefaultWhite")).cornerRadius(20).shadow(radius: 5, x: 5, y: 5)
                                HStack {
                                    Button("Previous Day", systemImage: "arrowshape.backward.circle.fill", action: {
                                        dateHolder.displayedDate = Calendar.current.date(byAdding: .day, value: -1, to: dateHolder.displayedDate)!
                                    }).foregroundStyle(Color("DefaultBlack"))
                                    Spacer()
                                    Text("\(dateHolder.displayedDate.formatted(date: .complete, time: .omitted).uppercased())").font(.title).padding(5)
                                    Spacer()
                                    Button("Next Day", systemImage: "arrowshape.forward.circle.fill", action: {
                                        dateHolder.displayedDate = Calendar.current.date(byAdding: .day, value: 1, to: dateHolder.displayedDate)!
                                    }).foregroundStyle(Color("DefaultBlack"))
                                }.background(Color("DefaultWhite")).cornerRadius(20).shadow(radius: 5, x: 5, y: 5)
                                
                                Button("Edit", systemImage: "slider.horizontal.3", action: {
                                    
                                }).foregroundStyle(Color("DefaultBlack")).background(Color("DefaultWhite")).cornerRadius(20).shadow(radius: 5, x: 5, y: 5)
                            }
                        }
                        
                    }
                  
            }
            
            
        }
                
                
            
            
            
        }
        
    
            
}

class DateHolder: ObservableObject {
    @Published var displayedDate: Date = Date()
}

#Preview {
    ContentView()
        .environmentObject(DateHolder())
      

}
