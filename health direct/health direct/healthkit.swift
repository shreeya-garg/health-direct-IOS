//
//  healthkit.swift
//  health direct
//
//  Created by Shreeya Garg on 9/28/24.
//

import SwiftUI
import HealthKit

// HealthKit Manager class to handle HealthKit operations
class HealthKitManager: ObservableObject {
    private let healthStore = HKHealthStore()
    
    @Published var isAuthorized: Bool = false
    @Published var lastRespRate: Double?
    @Published var lastSystolicBP: Double?
    @Published var lastDiastolicBP: Double?
    
    init() {
        requestPermission()
    }
    
    func requestPermission() {
        let readTypes: Set = [
            HKObjectType.quantityType(forIdentifier: .respiratoryRate)!,
            HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)!,
            HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)!
        ]
        
        healthStore.requestAuthorization(toShare: [], read: readTypes) { (success, error) in
            DispatchQueue.main.async {
                if success {
                    self.isAuthorized = true
                    self.startMonitoring()
                } else {
                    print("Not authorized by the user to collect health monitoring data: \(String(describing: error))")
                }
            }
        }
    }
    
    func startMonitoring() {
        monitorRespRate()
        monitorBP()
        print("monitoring...")
    }
    
    func monitorRespRate() {
        let respRateType = HKObjectType.quantityType(forIdentifier: .respiratoryRate)!
        let query = HKObserverQuery(sampleType: respRateType, predicate: nil) { [weak self] query, completionHandler, error in
            if let error = error {
                print("Error observing respiratory rate: \(error.localizedDescription)")
                return
            }
            self?.fetchRespRateData()
            completionHandler()
            print("monitoring respiratory rate...")
        }
        healthStore.execute(query)
    }
    
    func monitorBP() {
        let systolicType = HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)!
        let diastolicType = HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)!
        
        let query = HKObserverQuery(sampleType: systolicType, predicate: nil) { [weak self] query, completionHandler, error in
            if let error = error {
                print("Error observing blood pressure: \(error.localizedDescription)")
                return
            }
            self?.fetchBPData()
            completionHandler()
            print("monitoring blood pressure...")
        }
        healthStore.execute(query)
    }
    
    func fetchRespRateData() {
        let respRateType = HKObjectType.quantityType(forIdentifier: .respiratoryRate)!
        let query = HKSampleQuery(sampleType: respRateType, predicate: nil, limit: 1, sortDescriptors: nil) { (query, results, error) in
            guard let sample = results?.first as? HKQuantitySample else { return }
            let rate = sample.quantity.doubleValue(for: HKUnit(from: "breaths/min"))
            let testRate = 35
            print("is resp rate ok??")
            DispatchQueue.main.async {
                self.lastRespRate = Double(testRate)
                if testRate > 30 {
                    self.triggerEmergencyResponse()
                    print("resp rate is greater than 20 breaths per min!!")
                }
            }
        }
        healthStore.execute(query)
    }
    
    func fetchBPData() {
        let systolicType = HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)!
        let diastolicType = HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)!
        
        let systolicQuery = HKSampleQuery(sampleType: systolicType, predicate: nil, limit: 1, sortDescriptors: nil) { (query, results, error) in
            guard let sample = results?.first as? HKQuantitySample else { return }
            let systolic = sample.quantity.doubleValue(for: HKUnit.millimeterOfMercury())
            let testSystolic = 200
            print("is bp systolic ok??")
            DispatchQueue.main.async {
                self.lastSystolicBP = Double(testSystolic)
                if testSystolic > 180 {
                    self.triggerEmergencyResponse()
                    print("blood pressure is higher than 180/120!!")
                }
            }
        }
        
        let diastolicQuery = HKSampleQuery(sampleType: diastolicType, predicate: nil, limit: 1, sortDescriptors: nil) { (query, results, error) in
            guard let sample = results?.first as? HKQuantitySample else { return }
            let diastolic = sample.quantity.doubleValue(for: HKUnit.millimeterOfMercury())
            let testDiastolic = 130
            print("is bp diastolic ok??")
            DispatchQueue.main.async {
                self.lastDiastolicBP = Double(testDiastolic)
                if testDiastolic > 120 {
                    self.triggerEmergencyResponse()
                    print("blood pressure is higher than 180/120!!")
                }
            }
        }
        
        healthStore.execute(systolicQuery)
        healthStore.execute(diastolicQuery)
    }
    
    func triggerEmergencyResponse() {
        print("Emergency detected! listen up folks...")
        // You can implement text-to-speech or any other response mechanism here
    }
}

// SwiftUI View to display health data and trigger monitoring
struct HealthKitView: View {
    @StateObject private var healthKitManager = HealthKitManager()
    
    var body: some View {
        VStack {
            if healthKitManager.isAuthorized {
                Text("Health Monitoring Active")
                    .font(.headline)
                    .padding()
                
                if let respRate = healthKitManager.lastRespRate {
                    Text("Respiratory Rate: \(respRate, specifier: "%.2f") breaths/min")
                        .padding()
                        .foregroundColor(respRate > 30 ? .red : .primary)
                }
                
                if let systolic = healthKitManager.lastSystolicBP, let diastolic = healthKitManager.lastDiastolicBP {
                    Text("Blood Pressure: \(systolic, specifier: "%.2f") / \(diastolic, specifier: "%.2f") mmHg")
                        .padding()
                        .foregroundColor(systolic > 180 ? .red : .primary)
                }
            } else {
                Text("Requesting HealthKit Authorization...")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .onAppear {
            healthKitManager.requestPermission()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

