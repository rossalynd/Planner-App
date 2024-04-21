//
//  WaterView.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/23/24.
//

import SwiftUI
import HealthKit

struct WaterView: View {
    @EnvironmentObject var appModel: AppModel
    @State private var consumedWater: Double = 0
    @State private var animateDropletIndex: Int? = nil
    @State private var animatingDroplet: Bool = false
    private let goalOunces = 64.0
    private var healthStore = HKHealthStore()

    init() {
        let waterType = HKObjectType.quantityType(forIdentifier: .dietaryWater)!
        let typesToShare: Set = [waterType]
        let typesToRead: Set = [waterType]
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            if let error = error {
                print("Authorization failed with error: \(error)")
            }
        }
    }

    var body: some View {
        VStack {
            
            Spacer()
            ZStack(alignment: .bottom) {
                Button(action:
                        addWater
                ) {
                    ZStack(alignment: .bottom) {
                        Image(systemName: "drop.fill")
                            .resizable()
                            .frame(width: 50, height: 70)
                            .foregroundColor(.gray.opacity(0.2))
                            .symbolEffect(.bounce.wholeSymbol, value: animatingDroplet)
                        Image(systemName: "drop.fill")
                            .resizable()
                            .foregroundStyle(.blue)
                            .frame(width: 50, height: 70)
                            .mask(
                                Rectangle()
                                    .frame(width: 100, height: (70 * CGFloat(consumedWater / goalOunces)) + 20, alignment: .bottom)
                                    .animation(.linear, value: consumedWater)
                                    .offset(y: ((90 - 70 * CGFloat(consumedWater / goalOunces)) / 2))
                                
                                
                            )
                            .symbolEffect(.bounce.wholeSymbol, value: animatingDroplet)
                    }
                    .scaleEffect(1.5)
                    .padding()
                }
            }
            Spacer()
            Text("\(consumedWater, specifier: "%.0f") oz").font(Font.custom(appModel.headerFont, size: 20)).foregroundColor(appModel.headerColor)
            
            Spacer()
               
        }
        .onChange(of: appModel.displayedDate) {
            fetchWaterIntake()
        }
        .onAppear {
            fetchWaterIntake()
        }
    }

    private func addWater() {
        let quantityType = HKQuantityType.quantityType(forIdentifier: .dietaryWater)!
        let quantity = HKQuantity(unit: .fluidOunceUS(), doubleValue: 8)
        let date = appModel.displayedDate

        let waterSample = HKQuantitySample(type: quantityType, quantity: quantity, start: date, end: date)
        healthStore.save(waterSample) { success, error in
            if success {
                print("Water intake saved successfully")
                fetchWaterIntake()
                animatingDroplet.toggle()
            } else if let error = error {
                print("Error saving water intake: \(error.localizedDescription)")
            }
        }
    }

    private func fetchWaterIntake() {
        let quantityType = HKQuantityType.quantityType(forIdentifier: .dietaryWater)!
        let startOfDay = Calendar.current.startOfDay(for: appModel.displayedDate)
        let endOfDay = Calendar.current.date(byAdding: .hour, value: 23, to: startOfDay)!
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)

        let query = HKSampleQuery(sampleType: quantityType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, results, error in
            guard let samples = results as? [HKQuantitySample], error == nil else {
                print("Failed to fetch water samples: \(String(describing: error))")
                return
            }

            DispatchQueue.main.async {
                self.consumedWater = samples.reduce(0) { acc, sample in
                    acc + sample.quantity.doubleValue(for: .fluidOunceUS())
                }
            }
        }

        healthStore.execute(query)
    }
}

struct Droplet: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))  // Move to the top center, narrow point

        // Curve right down to bottom
        path.addCurve(to: CGPoint(x: rect.midX, y: rect.maxY),
                      control1: CGPoint(x: rect.midX, y: rect.minY),
                      control2: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addCurve(to:CGPoint(x: rect.midX, y: rect.minY),
                      control1: CGPoint(x: rect.midX, y: rect.maxY),
                      control2: CGPoint(x: rect.minX, y: rect.maxY)
        )
                      

       
        
                      
        
        path.closeSubpath()
        return path
    }
}


#Preview {
    WaterView()
        .environmentObject(AppModel())
}
