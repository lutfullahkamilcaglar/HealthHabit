//
//  HealthHabitWidgetBundle.swift
//  HealthHabitWidget
//
//  Created by Kamil Caglar on 10/02/2023.
//

import WidgetKit
import SwiftUI

@main
struct HealthHabitWidgetBundle: WidgetBundle {
    var body: some Widget {
        HealthHabitWidget()
        HealthHabitWidgetLiveActivity()
    }
}
