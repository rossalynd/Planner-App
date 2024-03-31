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
    case none = "None"
    
    var imageName: String {
        switch self {
        case .excited: return "Excited" 
        case .happy: return "Happy"
        case .content: return "Content"
        case .sad: return "Sad"
        case .angry: return "Angry"
        case .none: return "None"
        }
    }
}

struct MoodEntry: Codable {
    let mood: Mood
    let date: Date
    var dateComponent: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return calendar.date(from: components)!
    }
}

class MoodManager {
    static let shared = MoodManager()
    
    private let userDefaults = UserDefaults.standard
    private let key = "moodEntries"
    
    func saveMood(_ mood: Mood, forDate date: Date) {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            guard let dateOnly = calendar.date(from: components) else { return }

            var entries = getMoodEntries().filter { $0.dateComponent != dateOnly }
            let entry = MoodEntry(mood: mood, date: dateOnly)
            entries.append(entry)

            if let data = try? JSONEncoder().encode(entries) {
                userDefaults.set(data, forKey: key)
            }
        }
        
    func mood(forDate date: Date) -> Mood? {
        let entries = getMoodEntries()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        guard let dateOnly = calendar.date(from: components) else { return nil }
        
        return entries.first(where: { $0.dateComponent == dateOnly })?.mood
    }
    
    func getMoodEntries() -> [MoodEntry] {
        guard let data = userDefaults.data(forKey: key),
              let entries = try? JSONDecoder().decode([MoodEntry].self, from: data) else {
            return []
        }
        return entries
    }
}
