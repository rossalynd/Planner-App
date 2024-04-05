//
//  SeamlessPattern.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 4/3/24.
//

import SwiftUI

struct SeamlessPattern: View {
    
    let image: String
    
    
    var body: some View {
        ZStack{
            
            
            VStack(spacing: 0) {
                
                ForEach(0..<5) { column in
                    
                    HStack(spacing: 0) {
                        ForEach(0..<5) { row in
                            
                            
                            
                            Image(image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 500, height: 500)
                                .blur(radius: 0)
                        }
                        
                        
                    }
                }
            }
          
            
            
            Color.defaultClear.frame(maxWidth: .infinity, maxHeight: .infinity).ignoresSafeArea()
        }
        
        
    }
}
#Preview {
   ContentView()
        .environmentObject(AppModel())
        .environmentObject(TasksUpdateNotifier())
        .modelContainer(for: MoodEntry.self)
}
