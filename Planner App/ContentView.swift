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
    @State var isCoverVisible = false
    @State var isMenuVisible = false
    

    var body: some View {
        

        NavigationStack {
            
            
            ZStack(alignment: .leading) {
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
                                
                                    Button("Menu", systemImage: "line.3.horizontal", action: {
                                        withAnimation {
                                            isMenuVisible.toggle()
                                        }
                                    }).foregroundStyle(Color("DefaultBlack")).background(Color("DefaultWhite")).cornerRadius(20).shadow(radius: 5, x: 5, y: 5)
                                HStack {
                                    Button("Previous Day", systemImage: "arrowshape.backward.circle.fill", action: {
                                        dateHolder.displayedDate = Calendar.current.date(byAdding: .day, value: -1, to: dateHolder.displayedDate)!
                                    }).foregroundStyle(Color("DefaultBlack"))
                                    Spacer()
                                    Button("\(dateHolder.displayedDate.formatted(date: .complete, time: .omitted).uppercased())", action: {
                                        dateHolder.displayedDate = Date()
                                    }).font(.title2).foregroundColor((Color("DefaultBlack")))
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
                GeometryReader { geometry in
                    VStack {
                        VStack(alignment: .leading) {
                            Spacer()
                            if isMenuVisible {
                                MainMenuView(isMenuVisible: $isMenuVisible)
                                    .transition(.move(edge: .leading))
                                    .gesture(
                                                           DragGesture()
                                                               .onEnded { drag in
                                                                   // Check if the drag is from trailing to leading
                                                                   if drag.translation.width < 0 {
                                                                       // This means the user swiped from trailing to leading
                                                                       withAnimation {
                                                                           isMenuVisible = false
                                                                       }
                                                                   }
                                                               }
                                                       )
                            }
                            Spacer()
                        }.frame(maxWidth: geometry.size.width / 3.2, maxHeight: geometry.size.height / 1.01).shadow(radius: 10, x: 10, y: 10)
                            
                    }.frame(maxHeight: geometry.size.height)
                    
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                .gesture(
                                       DragGesture()
                                           .onEnded { drag in
                                               // Check if the drag is from trailing to leading
                                               if drag.translation.width > 0 {
                                                   // This means the user swiped from trailing to leading
                                                   withAnimation {
                                                       isMenuVisible = true
                                                   }
                                               }
                                           }
                                   )
            
            
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
