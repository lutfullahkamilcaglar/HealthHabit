//
//  HealthHabitApp.swift
//  HealthHabit
//
//  Created by Kamil Caglar on 09/02/2023.
//

import SwiftUI

@main
struct HealthHabitApp: App {
    var healthVM = HealthHabitViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(healthVM)
        }
    }
}
