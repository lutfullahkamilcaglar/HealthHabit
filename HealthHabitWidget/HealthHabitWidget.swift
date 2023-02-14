//
//  HealthHabitWidget.swift
//  HealthHabitWidget
//
//  Created by Kamil Caglar on 10/02/2023.
//

import WidgetKit
import SwiftUI
import Intents
import HealthKit

struct Provider: IntentTimelineProvider {
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), stepCount: 0, advice: MotivationQuote(FQuote: "", SQuote: ""))
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), stepCount: 0, advice: MotivationQuote(FQuote: "", SQuote: ""))
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        // Request the step count data from the HealthKit framework.
        let healthStore = HKHealthStore()
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                var fAdvice: String = ""
                var sAdvice: String = ""
                for advice in advice {
                    fAdvice = advice.FQuote
                    sAdvice = advice.SQuote
                } // yukari tasi
                completion(Timeline(entries: [SimpleEntry(date: Date(), stepCount: 0, advice: MotivationQuote(FQuote: fAdvice, SQuote: sAdvice))], policy: .atEnd))
                return
            }
            let stepCount = Int(sum.doubleValue(for: HKUnit.count()))
            let quote = advice.randomElement()
            let date = Date()
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 10, to: date)
            let entry = SimpleEntry(date: Date(), stepCount: stepCount, advice: quote ?? MotivationQuote(FQuote: "", SQuote: ""))
            completion(Timeline(entries: [entry], policy: .after(nextUpdate!)))
        }
        healthStore.execute(query)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let stepCount: Int
    let advice: MotivationQuote
}

struct HealthHabitWidgetEntryView : View {
    var entry: SimpleEntry
    
    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(.purple.gradient)
            VStack{
                Text("Steps: \(entry.stepCount)")
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                if entry.stepCount >= 0 {
                    if !entry.advice.FQuote.isEmpty {
                        Text(entry.advice.FQuote)
                            .foregroundColor(.yellow)
                    }
                } else if entry.stepCount > 10000 {
                    if !entry.advice.SQuote.isEmpty {
                        Text(entry.advice.SQuote)
                            .foregroundColor(.yellow)
                    }
                }
            }
        }
    }
}


struct HealthHabitWidget: Widget {
    let kind: String = "HealthHabitWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            HealthHabitWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget showing the step count.")
    }
}

struct HealthHabitWidget_Previews: PreviewProvider {
    static var previews: some View {
        HealthHabitWidgetEntryView(entry: SimpleEntry(date: Date(), stepCount: 0, advice: MotivationQuote(FQuote:  "", SQuote: "")))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
