//
//  YearlyMoodView.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 4/2/24.
//
import SwiftData
import SwiftUI

struct YearlyMoodView: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject var appModel: AppModel
    @State private var showPopover: Bool = false
    @State private var selectedDate: Date? // Track the selected date for mood assignment
    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 7) // 7 days for each week
    @State private var refreshTrigger: Bool = false
    @Query var entries: [MoodEntry]
   
    
    var body: some View {
        ZStack(alignment: .leading) {
            VStack {
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                // Assuming themedBackground is a custom modifier you have defined elsewhere.
                .themedBackground(appModel: appModel)
            VStack(alignment: .leading) {
                Text("Moods of the Year").font(.largeTitle).bold().padding([.top, .leading])
                ScrollView {
                    VStack {
                        ForEach(1...12, id: \.self) { month in
                            VStack(alignment: .leading) {
                                Text("\(monthName(from: month))").font(.headline).padding()
                                LazyVGrid(columns: columns, spacing: 10) {
                                    ForEach(1...daysInMonth(month: month), id: \.self) { day in
                                        HStack {
                                            Group {
                                                if let mood = moodForDay(year: currentYear(), month: month, day: day) {
                                                    Image(mood.mood.rawValue)
                                                        .resizable()
                                                        .scaledToFit()
                                                } else {
                                                    Rectangle()
                                                        .fill(Color.gray)
                                                        .clipShape(Circle()).opacity(0.3)
                                                }
                                            }
                                        }
                                        .frame(width: 50, height: 50)
                                        .onTapGesture {
                                            self.selectedDate = dateForDay(year: currentYear(), month: month, day: day)
                                            print("\(String(describing: selectedDate))")
                                            print("showing popover")
                                            self.showPopover = true
                                        }
                                        
                                    }
                                }
                            }
                        }
                        
                    }.padding()
                }
                .popover(isPresented: $showPopover) {
                    moodSelectionPopover()
                }
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding([.leading, .trailing, .bottom])
                
            }
        }
    }

    private func moodSelectionPopover() -> some View {
        HStack(spacing: 10) {
          ForEach(Mood.allCases.filter { $0 != .none }, id: \.self) { mood in
            Image(mood.rawValue)
              .resizable()
              .scaledToFit()
              .frame(width: 50, height: 50)
              .onTapGesture {
                  if selectedDate != nil {
                      print("saving \(mood.rawValue) to \(selectedDate!)")
                      context.insert(MoodEntry(mood: mood, date: selectedDate!))
                      context.processPendingChanges()
                  } else {
                      print("No date selected")
                  }
                // Save mood using SwiftData (implementation needed)
                self.showPopover = false
              }
          }
        }
        .padding(10)
    }

    private func currentYear() -> Int {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: Date())
        return year
    }
    
    private func daysInMonth(month: Int) -> Int {
        let calendar = Calendar.current
        let dateComponents = DateComponents(year: currentYear(), month: month)
        let date = calendar.date(from: dateComponents)!
        let range = calendar.range(of: .day, in: .month, for: date)!
        return range.count
    }

    private func monthName(from month: Int) -> String {
        let dateFormatter = DateFormatter()
        let monthName = dateFormatter.monthSymbols[month - 1]
        return monthName
    }
    
    private func moodForDay(year: Int, month: Int, day: Int) -> MoodEntry? {
        guard let date = dateForDay(year: year, month: month, day: day) else { return nil }
        return entries.filter { $0.date.startOfDay == date.startOfDay }.sorted(by: { $0.date > $1.date }).last
    }

    private func dateForDay(year: Int, month: Int, day: Int) -> Date? {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        return calendar.date(from: dateComponents)
    }
}



#Preview {
    YearlyMoodView()
        .environmentObject(AppModel())
}
