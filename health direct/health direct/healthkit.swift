import SwiftUI
import UIKit
import HealthKit

class ViewController: UIViewController {
    let healthStore = HKHealthStore()

    override func viewDidLoad() {
        super.viewDidLoad()
        requestPermission()
    }

    func requestPermission() {
        let readTypes: Set = [
            HKObjectType.quantityType(forIdentifier: .respRate)!,
            HKObjectType.quantityType(forIdentifier: .bpSystolic)!,
            HKObjectType.quantityType(forIdentifier: .bpDiastolic)!
        ]
        print("requesting permission")
        healthStore.requestAuthorization(toShare: [], read: readTypes) { (success, error) in
            if success {
                // Authorization succeeded, start monitoring
                self.monitoring()
            } else {
                // Handle error
                print("Not authorized by the user to collect health monitoring data: \(String(describing: error))")
            }
        }
    }

    func monitoring() {
        monitorRespRate()
        monitorBP()
        print("monitoring...")
    }

    func monitorRespRate() {
        let respRateType = HKObjectType.quantityType(forIdentifier: .respiratoryRate)!
        let query = HKObserverQuery(sampleType: respRateType, predicate: nil) { query, completionHandler, error in
            if let error = error {
                print("Error observing respiratory rate: \(error.localizedDescription)")
                return
            }
            self.fetchRespRateData()
            completionHandler()
            print("monitoring respiratory rate...")
        }
        healthStore.execute(query)
    }

    func monitorBP() {
        let systolicType = HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)!
        let diastolicType = HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)!

        let query = HKObserverQuery(sampleType: systolicType, predicate: nil) { query, completionHandler, error in
            if let error = error {
                print("Error observing blood pressure: \(error.localizedDescription)")
                return
            }
            self.fetchBPData()
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
            print("is resp rate ok??")
            let testRate = 25
            // Check for abnormal respiratory rate (example: above 30)
            if testRate > 20 {
                self.triggerEmergency() // Trigger emergency if rate is abnormal
                print("resp rate is greater than 20 breaths per min!!")
            }
        }
        healthStore.execute(query)
    }

    func fetchBPData() {
        let systolicType = HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)!
        let diastolicType = HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)!

        let query = HKSampleQuery(sampleType: systolicType, predicate: nil, limit: 1, sortDescriptors: nil) { (query, results, error) in
            guard let sample = results?.first as? HKQuantitySample else { return }
            let systolic = sample.quantity.doubleValue(for: HKUnit.millimeterOfMercury())
            print("is bp ok??")
            let testSystolic = 200
            let testDiastolic = 130
            if testSystolic > 180 && testDiastolic > 120 { // Example abnormal blood pressure
                self.triggerEmergency() // Trigger emergency if blood pressure is abnormal
                print("blood pressure is higher than 180/120!!")
            }
        }
        healthStore.execute(query)
    }

}
