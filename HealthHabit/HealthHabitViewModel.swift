//
//  HealthHabitViewModel.swift
//  HealthHabit
//
//  Created by Kamil Caglar on 09/02/2023.
//

import Foundation
import HealthKit

class HealthHabitViewModel: ObservableObject {
    
    let healthStore = HKHealthStore()
       let healthKitManager = HealthKitManager()
       @Published var userStepCount = ""
       @Published var isAuthorized = false
       @Published var stepGoal = 0
       @Published var goalMet = false

       init() {
           changeAuthorizationStatus()
           let defaults = UserDefaults.standard
           if let savedStepGoal = defaults.value(forKey: "stepGoal") as? Int {
               self.stepGoal = savedStepGoal
           }
       }
    
    func setStepGoal(goal: Int) {
        let defaults = UserDefaults.standard
        self.stepGoal = goal
        defaults.set(goal, forKey: "stepGoal")
    }

        
        //MARK: - HealthKit Authorisation Request Method
        func healthRequest() {
            healthKitManager.setUpHealthRequest(healthStore: healthStore) {
                self.changeAuthorizationStatus()
                self.readStepsTakenToday()
            }
        }
        
        func changeAuthorizationStatus() {
            guard let stepQtyType = HKObjectType.quantityType(forIdentifier: .stepCount) else { return }
            let status = self.healthStore.authorizationStatus(for: stepQtyType)
            
            switch status {
            case .notDetermined:
                isAuthorized = false
            case .sharingDenied:
                isAuthorized = false
            case .sharingAuthorized:
                DispatchQueue.main.async {
                    self.isAuthorized = true
                }
            @unknown default:
                isAuthorized = false
            }
        }
        
        //MARK: - Read User's Step Count
    func readStepsTakenToday() {
        healthKitManager.readStepCount(forToday: Date(), healthStore: healthStore) { step in
            if step != 0.0 {
                DispatchQueue.main.async {
                    self.userStepCount = String(format: "%.0f", step)
                    let defaults = UserDefaults.standard
                    defaults.set(self.userStepCount, forKey: "stepCount")
                }
            }
        }
    }

}
