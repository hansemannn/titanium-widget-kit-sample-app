//
//  SampleWidgetExtension.swift
//  SampleWidgetExtension
//
//  Created by Hans Knöchel on 24.06.22.
//

import WidgetKit
import SwiftUI
import Intents
import AppIntents

// Change to your data - this struct is just a type definition that should
// have the same structure as your saved object in your Ti.App.iOS.UserDefaults
struct MyData: Codable {
  let title: String
  let count: Int
}

// Change to your group that is assigned in your app and extension (via "Signing and Capabilities" > "App Groups"
// NOTE: Your app has to have the same app group and on device, your provisioning profile should include it as well
let GROUP_IDENTIFIER = "group.io.tidev.sample-widgetkit"
let USER_DEFAULTS_IDENTIFIER = "kSampleAppMyData"

private func fetchData() -> MyData? {
  let defaults = UserDefaults(suiteName: GROUP_IDENTIFIER)
  
  if let rawData = defaults?.object(forKey: USER_DEFAULTS_IDENTIFIER) as? [String: Any],
    let rawDataJSON = try? JSONSerialization.data(withJSONObject: rawData, options: .fragmentsAllowed),
    let data = try? JSONDecoder().decode(MyData.self, from: rawDataJSON) {
    return data
  }

  return nil
}

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        let data = fetchData()
        return SimpleEntry(date: Date(),
                           count: data?.count ?? 0,
                           title: data?.title ?? "Counter",
                           configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let data = fetchData()
        let entry = SimpleEntry(date: Date(),
                                count: data?.count ?? 0,
                                title: data?.title ?? "Counter",
                                configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let data = fetchData()
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate,
                                    count: data?.count ?? 0,
                                    title: data?.title ?? "Counter",
                                    configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let count: Int
    let title: String
    let configuration: ConfigurationIntent
}

struct SampleWidgetExtensionEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        Text(entry.title).fontWeight(.bold)
        Text(entry.date, style: .time)
        Text("\(entry.count)")
        if #available(iOS 17.0, *) {
          Button(intent: ButtonCounter()) {
              Image(systemName: "bolt.fill")
          }
        }
    }
}

@main
struct SampleWidgetExtension: Widget {
    let kind: String = "SampleWidgetExtension"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            SampleWidgetExtensionEntryView(entry: entry)
        }
        .configurationDisplayName("Ti Sample Widget")
        .supportedFamilies(supportedWidgetFamilies())
        .description("Titanium rocks!")
    }
}

func supportedWidgetFamilies() -> [WidgetFamily] {
  var familes: [WidgetFamily] = [.systemSmall, .systemMedium, .systemLarge]
  
  if #available(iOS 15.0, *) {
    familes.append(.systemExtraLarge)
  }
  
  if #available(iOS 16.0, *) {
    familes.append(.accessoryInline)
    familes.append(.accessoryCircular)
    familes.append(.accessoryRectangular)
  }
  
  return familes
}

struct SampleWidgetExtension_Previews: PreviewProvider {
    static var previews: some View {
        let data = fetchData()
        SampleWidgetExtensionEntryView(entry: SimpleEntry(date: Date(),
                                                          count: data?.count ?? 0,
                                                          title: data?.title ?? "Counter",
                                                          configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct ButtonCounter: AppIntent {
    
    static var title: LocalizedStringResource = "Count Incrementer"
    static var description = IntentDescription("Increments the given count!")
    
    func perform() async throws -> some IntentResult {
        let lastData = fetchData()

        let defaults = UserDefaults(suiteName: GROUP_IDENTIFIER)
        defaults?.set(["title": "Counter", "count": (lastData?.count ?? 0) + 1], forKey: USER_DEFAULTS_IDENTIFIER)
        
        return .result()
    }
}
