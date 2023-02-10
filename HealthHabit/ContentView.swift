//  ContentView.swift
//  HealthHabit
//
//  Created by Kamil Caglar on 09/02/2023.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var vm: HealthHabitViewModel
    @State private var stepGoal = ""
    @State private var goalSet = false
    
    var body: some View {
        VStack {
            if vm.isAuthorized {
                VStack {
                    Text("Today's Step Count")
                        .font(.title3)
                    
                    Text("\(vm.userStepCount)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                
                if !goalSet {
                    HStack {
                        TextField("Enter step goal", text: $stepGoal)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .keyboardType(.numberPad)
                        
                        Button(action: {
                            self.vm.setStepGoal(goal: Int(self.stepGoal) ?? 0)
                            self.goalSet = true
                        }) {
                            Text("Set Goal")
                        }
                        .disabled(stepGoal.isEmpty)
                    }
                } else {
                    if let userStepCount = Int(vm.userStepCount), userStepCount >= vm.stepGoal {
                        Text("Congratulations! You have met your step goal.")
                            .font(.title)
                            .foregroundColor(.green)
                    } else {
                        Text("You have \(vm.stepGoal - (Int(vm.userStepCount) ?? 0)) steps left to reach your goal.")
                            .font(.title)
                            .foregroundColor(.red)
                    }
                }
            } else {
                VStack {
                    Text("Please Authorise Health!")
                        .font(.title3)
                    
                    Button(action: {
                        vm.healthRequest()
                    }) {
                        Text("Authorise HealthKit")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .frame(width: 320, height: 55)
                    .background(Color(.orange))
                    .cornerRadius(10)
                }
            }
            
        }
        .padding()
        .onAppear {
            if !self.vm.isAuthorized {
                self.vm.healthRequest()
            }
            
            let defaults = UserDefaults.standard
            if let savedStepCount = defaults.value(forKey: "stepCount") as? String {
                self.vm.userStepCount = savedStepCount
            } else {
                vm.readStepsTakenToday()
            }
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(HealthHabitViewModel())
    }
}
