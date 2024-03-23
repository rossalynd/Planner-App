//
//  Modules.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/23/24.
//

import Foundation
import SwiftData

@Model
final class LayoutOneModules {
    var smallSpaceTop: String = "Calendar"
    var smallSpaceMiddleTop: String = "Schedule"
    var smallSpaceMiddleBottom: String = "Tasks"
    var smallSpaceBottom: String = "Mood"
    var largeSpaceTop: String = "default"
    var largeSpaceBottom: String = "default"
    var mediumSpaceLeft: String = "default"
    var mediumSpaceRight: String = "default"
    
    init() {
        
    }
}
