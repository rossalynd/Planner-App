//
//  TodayBox.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/22/24.
//
import Foundation
import SwiftData


struct TodayBox: Identifiable, Hashable, Equatable {
    let id: UUID
    var type: String
    var size: Scale
    
    init(type: String, size: Scale) {
        self.id = UUID()
        self.type = type
        self.size = size
    }
    
    enum Scale {
        case small, medium, large
    }
}
