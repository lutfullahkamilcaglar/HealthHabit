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
                    .background(Color(.blue))
                    .cornerRadius(10)
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
}
