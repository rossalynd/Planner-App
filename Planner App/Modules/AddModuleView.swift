//
//  AddModuleView.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/21/24.
//

import SwiftUI

struct AddModuleView: View {
    @Environment(\.dismiss) private var dismiss
    
    var moduleTypes: [String: String] = ModuleViews().names
    @Binding var type: String
    
    
    
    var body: some View {
        List {
            ForEach(moduleTypes.sorted(by: >), id: \.key) { key, displayName in
                Text(displayName).onTapGesture {
                    type = key
                    dismiss()
                    
                }
            }
        }
    }
    
    
}


