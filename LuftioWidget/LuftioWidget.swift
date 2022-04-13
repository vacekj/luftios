//
//  ApodWidget.swift
//  ApodWidget
//
//  Created by SchwiftyUI on 12/7/20.
//

import Intents
import SwiftUI
import WidgetKit

struct LuftioTimelineProvider: IntentTimelineProvider {
    func placeholder(in context: Context) -> ApodTimelineEntry {
        ApodTimelineEntry(date: Date(), value: 500)
    }

    func getSnapshot(for configuration: ApodWidgetConfigurationIntent, in context: Context, completion: @escaping (ApodTimelineEntry) -> ()) {
        let entry = ApodTimelineEntry(date: Date(), value: 500)
        completion(entry)
    }

    func getTimeline(for configuration: ApodWidgetConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        LuftioAirQualityProvider.getValueFromApi { apodImageResponse in
            var entries: [ApodTimelineEntry] = []
            var policy: TimelineReloadPolicy
            var entry: ApodTimelineEntry

            switch apodImageResponse {
            case .Failure:
                entry = ApodTimelineEntry(date: Date(), value: 0)
                policy = .after(Calendar.current.date(byAdding: .minute, value: 1, to: Date())!)
            case .Success(let value, let timestamp):
                entry = ApodTimelineEntry(date: timestamp, value: value)
                let nextRefresh = Calendar.current.date(byAdding: .second, value: 30, to: Date())!
                policy = .after(nextRefresh)
            }

            entries.append(entry)
            let timeline = Timeline(entries: entries, policy: policy)
            completion(timeline)
        }
    }
}

struct ApodTimelineEntry: TimelineEntry {
    let date: Date
    let value: Int
}

struct ApodWidgetEntryView: View {
    var entry: LuftioTimelineProvider.Entry
    var body: some View {
        ZStack {
            Color(.white.toColor(.red, percentage: Double((entry.value - 500) / 10)))
            VStack {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(entry.value)").font(.title)
                    Text("ppm").font(.footnote)
                }
                Text(entry.date.timeAgoDisplay()).font(.footnote)
            }.foregroundColor(entry.value > 1000 ? .white : .black)
        }
    }
}

@main
struct ApodWidget: Widget {
    let kind: String = "LuftioWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ApodWidgetConfigurationIntent.self, provider: LuftioTimelineProvider()) { entry in
            ApodWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Luftio Air Quality")
        .description("Monitor your Air Quality on your home screen.")
    }
}

struct ApodWidget_Previews: PreviewProvider {
    static var previews: some View {
        ApodWidgetEntryView(entry: ApodTimelineEntry(date: Calendar.current.date(byAdding: .minute, value: -5, to: Date())!, value: 500))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        ApodWidgetEntryView(entry: ApodTimelineEntry(date: Calendar.current.date(byAdding: .minute, value: -2, to: Date())!, value: 800))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        ApodWidgetEntryView(entry: ApodTimelineEntry(date: Calendar.current.date(byAdding: .minute, value: -1, to: Date())!, value: 1500))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

extension UIColor {
    func toColor(_ color: UIColor, percentage: Double) -> UIColor {
        let percentage = max(min(percentage, 100), 0) / 100
        switch percentage {
        case 0: return self
        case 1: return color
        default:
            var (r1, g1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
            var (r2, g2, b2, a2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
            guard self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1) else { return self }
            guard color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2) else { return self }

            return UIColor(red: CGFloat(r1 + (r2 - r1) * percentage),
                           green: CGFloat(g1 + (g2 - g1) * percentage),
                           blue: CGFloat(b1 + (b2 - b1) * percentage),
                           alpha: CGFloat(a1 + (a2 - a1) * percentage))
        }
    }
}

extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
