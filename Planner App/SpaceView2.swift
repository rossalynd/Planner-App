//
//  SpaceView.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/23/24.
//



import SwiftUI

struct SpaceView: View {
    @State var type: String
    @State var showingAssignView = false
    var scale: Scale
    var maxHeight = 0.0
    
    enum Scale {
        case small, medium, large
    }
    
    

    var body: some View {
        GeometryReader { geometry in
            VStack {
                if type != "Calendar" {
                    Text(type.uppercased()).font(.headline).padding(.top)
                } else {

                        Text(currentMonthName())
                            .textCase(.uppercase).font(.headline).padding(.top)
                }
                
                if type == "Calendar" {
                    MiniMonthCalendarView(scale: scale)
                } else if type == "Tasks" {
                    TasksView()
                } else {
                    Text("No view to display")
                    
                }
                Spacer()
                HStack{
                    Spacer()
                    Button("Settings", systemImage: "gearshape.fill", action: {
                        showingAssignView = true
                    }).labelStyle(.iconOnly).padding().foregroundColor(.black)
                }
                
            }
            .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .background(.gray)
            .cornerRadius(20)
            .shadow(radius: 10, x:5,y:5)
            
            .onTapGesture {
                
            }
            .sheet(isPresented: $showingAssignView) {
                AddModuleView(type: $type).onDisappear()
            }
                
        }
        
    }

    func currentMonthName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM" // "MMMM" is the format string for the full month name.
        let monthName = dateFormatter.string(from: Date())
        return monthName
    }
}



#Preview {
    SpaceView(type: "Calendar", scale: .small)
}
