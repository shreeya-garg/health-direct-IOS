//
//  healthkit.swift
//  health direct
//
//  Created by Shreeya Garg on 9/28/24.
//

import SwiftUI
import HealthKit
import AVFoundation
//import SpeechManager

// HealthKit Manager class to handle HealthKit operations
class HealthKitManager: ObservableObject {
    private let healthStore = HKHealthStore()
    
    @Published var isAuthorized: Bool
    @Published var testRate: Double?
    @Published var testSystolic: Double?
    @Published var testDiastolic: Double?
    @Published var testHeartRate: Double?
    @Published var testActualHeartRate: Double?
    var validEmergency : Bool
    
    init() {
        self.testSystolic = 0.0
        self.testDiastolic = 0.0
        self.testRate = 0.0
        self.testHeartRate = 0.0
        self.testActualHeartRate = 0.0
        self.isAuthorized = false
        self.validEmergency = false
        
        requestPermission()
    }
    
    func requestPermission() {
//        let readTypes: Set<HKObjectType> = [
//            HKObjectType.quantityType(forIdentifier: .respiratoryRate),
//            HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic),
//            HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)
//        ]
        
        var readTypes = Set<HKObjectType>()
            
        if let respiratoryRateType = HKObjectType.quantityType(forIdentifier: .respiratoryRate) {
            readTypes.insert(respiratoryRateType)
        }
        if let systolicType = HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic) {
            readTypes.insert(systolicType)
        }
        if let diastolicType = HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic) {
            readTypes.insert(diastolicType)
        }
        if let hrType = HKObjectType.quantityType(forIdentifier: .restingHeartRate) {
            readTypes.insert(hrType)
        }
        if let actualHRType = HKObjectType.quantityType(forIdentifier: .heartRate) {
            readTypes.insert(actualHRType)
        }
        
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
        
//        print("resp requestPermission" + String(self.testRate ?? 35))
    }
    
    func startMonitoring() {
        monitorRespRate()
        monitorBP()
        monitorHR()
        monitorActualHR()
//        print("resp startMonitoring" + String(self.testRate!))
        print("monitoring...")
    }
    
    func monitorRespRate() {
        guard let respRateType = HKObjectType.quantityType(forIdentifier: .respiratoryRate)
        else {
            print("error")
            return
        }
        fetchRespRateData()
        let query = HKObserverQuery(sampleType: respRateType, predicate: nil) { [weak self] query, completionHandler, error in
            if let error = error {
                print("Error observing respiratory rate: \(error.localizedDescription)")
                return
            }
            print("resp monitorRespRate" + String(self?.testRate ?? 0))
            self?.fetchRespRateData()
            completionHandler()
            print("monitoring respiratory rate..." + String(self?.testRate ?? 0))
        }
        healthStore.execute(query)
    }


    
    func monitorBP() {
        guard let systolicType = HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic) else {
            return
        }
        guard let diastolicType = HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic) else {
            return
        }
        
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
     guard let respRateType = HKObjectType.quantityType(forIdentifier: .respiratoryRate)
        else {
            return
        }
       // print(respRateType)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: respRateType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { (query, results, error) in
            print(results?.first)
            guard let sample = results?.first as? HKQuantitySample else { return }
            let rate = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
            print("Fetched respiratory rate: \(rate)")
//            let testRate = 35
            //self.testRate = 35
            self.testRate = rate
           // print("is resp rate ok??")
            DispatchQueue.main.async {
                self.testRate = Double(self.testRate ?? 35)
                print("Updated respiratory rate: \(self.testRate ?? 35)")
                if (self.testRate ?? 35 > 30) {
                    self.triggerEmergencyResponse()
                 //   print("resp rate is greater than 20 breaths per min!!")
                }
            }
        }
        healthStore.execute(query)
    }
    
    func fetchBPData() {
        guard let systolicType = HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)
        else {
            return
        }
        guard let diastolicType = HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)
        else {
            return
        }
        
        let sortDescriptorSystolic = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let systolicQuery = HKSampleQuery(sampleType: systolicType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptorSystolic]) { (query, results, error) in
            guard let sample = results?.first as? HKQuantitySample else { return }
            let systolic = sample.quantity.doubleValue(for: HKUnit.millimeterOfMercury())
            print("Fetched systolic BP: \(systolic)")
//            let testSystolic = 200
//            self.testSystolic = 200
            self.testSystolic = systolic
            print("is bp systolic ok??")
            DispatchQueue.main.async {
                self.testSystolic = Double(self.testSystolic ?? 35)
                if (self.testSystolic ?? 35 > 180) {
                    self.triggerEmergencyResponse()
                    print("blood pressure is higher than 180/120!!")
                }
            }
        }
        
        let sortDescriptorDiastolic = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let diastolicQuery = HKSampleQuery(sampleType: diastolicType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptorDiastolic]) { (query, results, error) in
            guard let sample = results?.first as? HKQuantitySample else { return }
            let diastolic = sample.quantity.doubleValue(for: HKUnit.millimeterOfMercury())
//            let testDiastolic = 130
//            self.testDiastolic = 130
            self.testDiastolic = diastolic
            print("is bp diastolic ok??")
            DispatchQueue.main.async {
                self.testDiastolic = Double(self.testDiastolic ?? 34)
                if (self.testDiastolic ?? 34 > 120) {
                    self.triggerEmergencyResponse()
                    print("blood pressure is higher than 180/120!!")
                }
            }
        }
        
        healthStore.execute(systolicQuery)
        healthStore.execute(diastolicQuery)
    }
    
   /* func triggerEmergencyResponse() {
        print("Emergency detected! listen up folks...")
        // You can implement text-to-speech or any other response mechanism here
    } */
    
//    HKObjectType.quantityType(forIdentifier: .restingHeartRate)!


    func monitorHR() {
        guard let hrType = HKObjectType.quantityType(forIdentifier: .restingHeartRate) else {
            return
        }
        
        let query = HKObserverQuery(sampleType: hrType, predicate: nil) { [weak self] query, completionHandler, error in
            if let error = error {
                print("Error observing heart rate: \(error.localizedDescription)")
                return
            }
            self?.fetchHRData()
            completionHandler()
            print("monitoring heart rate...")
        }
        healthStore.execute(query)
    }


    func fetchHRData() {
        guard let hrType = HKObjectType.quantityType(forIdentifier: .restingHeartRate) else {
            return
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
           
        let query = HKSampleQuery(sampleType: hrType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { (query, results, error) in
            guard let sample = results?.first as? HKQuantitySample else { return }
            let heart_rate = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
            print("is heart rate??")
            
            self.testHeartRate = heart_rate
            
            DispatchQueue.main.async {
                self.testHeartRate = Double(self.testHeartRate ?? 72)
                if (self.testHeartRate ?? 72 > 120) {
                    self.triggerEmergencyResponse()
                    print("heart rate is higher than 105!")
                }
                
            }
            
        }
        healthStore.execute(query)
    }
    
    func monitorActualHR() {
        guard let actualHRType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            return
        }
        
        let query = HKObserverQuery(sampleType: actualHRType, predicate: nil) { [weak self] query, completionHandler, error in
            if let error = error {
                print("Error observing heart rate: \(error.localizedDescription)")
                return
            }
            self?.fetchActualHRData()
            completionHandler()
            print("monitoring heart rate...")
        }
        healthStore.execute(query)
    }


    func fetchActualHRData() {
        guard let actualHRType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            return
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
           
        let query = HKSampleQuery(sampleType: actualHRType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { (query, results, error) in
            guard let sample = results?.first as? HKQuantitySample else { return }
            let heart_rate = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
            print("is heart rate??")
            
            self.testActualHeartRate = heart_rate
            
            DispatchQueue.main.async {
                self.testActualHeartRate = Double(self.testActualHeartRate ?? 72)
                if (self.testActualHeartRate ?? 72 > 120) {
                    self.triggerEmergencyResponse()
                    print("heart rate is higher than 110!")
                }
                
            }
            
        }
        healthStore.execute(query)
    }
    
    func triggerEmergencyResponse() {
        let speechManager = SpeechManager()
        speechManager.configureAudioSession()
            self.validEmergency = true
            //navigateToEmergency = true
            if (self.validEmergency) {
                // soundManager.playAlertSound()
                
                speechManager.speakText("User is potentially facing a medical emergency. Please select no or write any situational context in the textbox provided.")
            }
    }

}

// SwiftUI View to display health data and trigger monitoring
//struct HealthKitView: View {
//    @StateObject private var healthKitManager = HealthKitManager()
//    
//    var body: some View {
//        VStack {
//            if healthKitManager.isAuthorized {
//                Text("Health Monitoring Active")
//                    .font(.headline)
//                    .padding()
//                
//                if let respRate = healthKitManager.lastRespRate {
//                    Text("Respiratory Rate: \(respRate, specifier: "%.2f") breaths/min")
//                        .padding()
//                        .foregroundColor(respRate > 30 ? .red : .primary)
//                }
//                
//                if let systolic = healthKitManager.lastSystolicBP, let diastolic = healthKitManager.lastDiastolicBP {
//                    Text("Blood Pressure: \(systolic, specifier: "%.2f") / \(diastolic, specifier: "%.2f") mmHg")
//                        .padding()
//                        .foregroundColor(systolic > 180 ? .red : .primary)
//                }
//            } else {
//                Text("Requesting HealthKit Authorization...")
//                    .font(.subheadline)
//                    .foregroundColor(.gray)
//            }
//        }
//        .onAppear {
//            healthKitManager.requestPermission()
//        }
//        .padding()
//    }
//}

#Preview {
    ContentView()
}

