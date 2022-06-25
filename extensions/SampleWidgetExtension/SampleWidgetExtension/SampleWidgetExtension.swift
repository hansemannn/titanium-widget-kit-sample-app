//
//  SampleWidgetExtension.swift
//  SampleWidgetExtension
//
//  Created by Hans Knöchel on 24.06.22.
//

import WidgetKit
import SwiftUI
import Intents

// Change to your data - this struct is just a type definition that should
// have the same structure as your saved object in your Ti.App.iOS.UserDefaults
struct MyData: Codable {
  let title: String
  let count: Int
}

private func fetchData() -> MyData? {
  // Change to your group that is assigned in your app and extension (via "Signing and Capabilities" > "App Groups"
  // NOTE: Your app has to have the same app group and on device, your provisioning profile should include it as well
  let GROUP_IDENTIFIER = "group.io.tidev.sample-widgetkit"
  let USER_DEFAULTS_IDENTIFIER = "kSampleAppMyData"

  let defaults = UserDefaults(suiteName: GROUP_IDENTIFIER)
  
  if let archivedData = defaults?.object(forKey: USER_DEFAULTS_IDENTIFIER) as? Data, let rawData = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(archivedData) as? [String: Any],
    let rawDataJSON = try? JSONSerialization.data(withJSONObject: rawData, options: .fragmentsAllowed),
    let data = try? JSONDecoder().decode(MyData.self, from: rawDataJSON) {
    return data
  }

  return nil
}

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        let data = fetchData()
        return SimpleEntry(date: Date(), title: data?.title ?? "Default", configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let data = fetchData()
        let entry = SimpleEntry(date: Date(), title: data?.title ?? "Default", configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let data = fetchData()
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, title: data?.title ?? "Default", configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let title: String
    let configuration: ConfigurationIntent
}

struct SampleWidgetExtensionEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        Text(entry.title).fontWeight(.bold)
        Text(entry.date, style: .time)
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
        SampleWidgetExtensionEntryView(entry: SimpleEntry(date: Date(), title: data?.title ?? "Default", configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
