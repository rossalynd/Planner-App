//
//  CycleView.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 4/21/24.
//
import SwiftUI
import HealthKit
import HealthKitUI

struct CycleView: View {
    private var healthStore = HKHealthStore()
    

    var body: some View {
        Text("Hello, World!")
            .onAppear {
                requestAuth()
            }
    }
    
    func requestAuth() {
        let readTypes = Set([
            HKObjectType.categoryType(forIdentifier: .menstrualFlow)!,
            HKObjectType.categoryType(forIdentifier: .abdominalCramps)!,
            HKObjectType.categoryType(forIdentifier: .acne)!,
            HKObjectType.categoryType(forIdentifier: .bloating)!,
            HKObjectType.categoryType(forIdentifier: .breastPain)!,
            HKObjectType.categoryType(forIdentifier: .fatigue)!,
            HKObjectType.categoryType(forIdentifier: .cervicalMucusQuality)!,
            HKObjectType.categoryType(forIdentifier: .contraceptive)!,
            HKObjectType.categoryType(forIdentifier: .moodChanges)!,
            HKObjectType.categoryType(forIdentifier: .sexualActivity)!,
            HKObjectType.categoryType(forIdentifier: .sleepChanges)!
        ])
        
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            if let error = error {
                print("Authorization failed with error: \(error)")
                return
            }
            if success {
                print("Authorization successful")
                fetchMenstrualData()
            }
        }
    }
    
    func fetchMenstrualData() {
        guard let menstrualType = HKObjectType.categoryType(forIdentifier: .menstrualFlow) else {
            return
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: menstrualType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            guard samples is [HKCategorySample] else {
                print("Failed to load samples: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // Process the fetched samples
            DispatchQueue.main.async {
                // Update UI based on the fetched data
            }
        }
        
        healthStore.execute(query)
    }
   

    


}
