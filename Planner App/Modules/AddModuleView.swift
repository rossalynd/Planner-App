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
    var onSelect: (String) -> Void
    
    var body: some View {
        List {
            ForEach(moduleTypes.sorted(by: >), id: \.key) { key, displayName in
                Text(displayName).onTapGesture {
                    onSelect(key)
                }
            }
        }
    }
    
    
}


