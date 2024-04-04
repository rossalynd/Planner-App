//
//  MoodModel.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/28/24.
//



import SwiftData
import Foundation
import SwiftUI

// MoodEntry Model with initializer and ID
@Model
class MoodEntry {
    @Attribute(.unique) var id = UUID() // Let SwiftData generate unique IDs
    var mood: Mood
    @Transient var currentMood: Mood = .none

  let date: Date

    init(mood: Mood, date: Date) {
    self.mood = mood
    self.date = date
  }

 
}

// Define Mood as an enum with raw values
enum Mood: String, CaseIterable, Codable {
    case excited = "excited"
    case happy = "happy"
    case content = "content"
    case sad = "sad"
    case angry = "angry"
    case none = "none"
}
