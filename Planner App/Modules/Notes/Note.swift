//
//  Note.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 4/9/24.
//

import Foundation
import SwiftData
import PencilKit

@Model
final class Note {
    var data: Data
    @Attribute(.unique) var dateCreated: Date
    var dateModified: Date
    var tags: [String]
    
    init(data: Data, dateCreated: Date = .now, dateModified: Date = .now, tags: [String]) {
        self.data = data
        self.dateCreated = dateCreated
        self.dateModified = dateModified
        self.tags = tags
    }
}
