//
//  MoodModel.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/28/24.
//
import Foundation

enum Mood: String, CaseIterable, Codable {
    case excited = "Excited"
    case happy = "Happy"
    case content = "Content"
    case sad = "Sad"
    case angry = "Angry"
    
    var imageName: String {
        switch self {
        case .excited: return "Excited" // replace with your actual image names
        case .happy: return "Happy"
        case .content: return "Content"
        case .sad: return "Sad"
        case .angry: return "Angry"
        }
    }
}

struct MoodEntry: Codable {
    let mood: Mood
    let date: Date
}

class MoodManager {
    static let shared = MoodManager()
    
    private let userDefaults = UserDefaults.standard
    private let key = "moodEntries"
    
    func saveMood(_ mood: Mood) {
        let entry = MoodEntry(mood: mood, date: Date())
        var entries = getMoodEntries()
        entries.append(entry)
        if let data = try? JSONEncoder().encode(entries) {
            userDefaults.set(data, forKey: key)
        }
    }
    
    func getMoodEntries() -> [MoodEntry] {
        guard let data = userDefaults.data(forKey: key),
              let entries = try? JSONDecoder().decode([MoodEntry].self, from: data) else {
            return []
        }
        return entries
    }
}
