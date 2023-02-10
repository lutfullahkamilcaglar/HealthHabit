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
        SimpleEntry(date: Date(), stepCount: 0, advice: "Loading...")
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), stepCount: 0, advice: "Loading...")
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        //var entries: [SimpleEntry] = []

        // Request the step count data from the HealthKit framework.
        let healthStore = HKHealthStore()
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                return
            }

            let steps = Int(sum.doubleValue(for: HKUnit.count()))
            getAdvice { (id, advice) in
                        let date = Date()
                let entry = SimpleEntry(date: date, stepCount: steps, advice: advice)
                        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 10, to: date)
                        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate!))
                        completion(timeline)
                    }
        }
        healthStore.execute(query)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let stepCount: Int
    let advice: String
}


struct HealthHabitWidgetEntryView : View {
    var entry: SimpleEntry
    
    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(.purple.gradient)
            VStack{
                Text("Step count: \(entry.stepCount)")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                Text(entry.advice)
                    .foregroundColor(.yellow)
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

func getAdvice(completion: @escaping (Int, String)->()) {
    let url = "https://api.adviceslip.com/advice"
    
    let session  = URLSession(configuration: .default)
    
    session.dataTask(with: URL(string: url)!) { (data, _, err) in
        if err != nil {
            print(err!)
            return
        }
        do {
            let jsonData = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
            let advice = jsonData["slip"] as! [String: Any]
            let id = advice["id"] as! Int
            let adviceText = advice["advice"] as! String
            completion (id, adviceText)
        } catch {
            print (err!)
        }
    }.resume ()
}

struct HealthHabitWidget_Previews: PreviewProvider {
    static var previews: some View {
        HealthHabitWidgetEntryView(entry: SimpleEntry(date: Date(), stepCount: 0, advice: "Loading..."))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
