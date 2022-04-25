//
//  ContentView.swift
//  Apod
//
//  Created by SchwiftyUI on 12/7/20.
//

import SwiftUI
import SwiftUICharts
import WidgetKit

func weekOfData(res: Response = Response(co2: [], tvoc: [])) -> LineChartData {
    let dateFormatter = DateFormatter()

    let mappedData = res.co2.map { LineChartDataPoint(value: Double($0.value)!, description: dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval($0.ts / 1000)))) }

    let data = LineDataSet(dataPoints: mappedData,
                           pointStyle: PointStyle(),
                           style: LineStyle(lineColour: ColourStyle(colours: [Color.red.opacity(0.50),
                                                                              Color.red.opacity(0.00)],
                                                                    startPoint: .top,
                                                                    endPoint: .bottom),
                                            lineType: .curvedLine))

    return LineChartData(dataSets: data,
                         metadata: ChartMetadata(title: "CO2", subtitle: "last week"),
                         chartStyle: LineChartStyle(infoBoxPlacement: .floating,
                                                    markerType: .full(attachment: .point),

                                                    xAxisLabelPosition: .bottom,
                                                    xAxisLabelColour: Color.primary,
                                                    xAxisLabelsFrom: .dataPoint(rotation: .degrees(0)),

                                                    baseline: .minimumWithMaximum(of: 100), topLine: .maximum(of: 2000)))
}

struct ContentView: View {
    @State var data: Response = .init(co2: [], tvoc: [])
    @State var chartData: LineChartData = weekOfData()
    var body: some View {
        NavigationView {
            VStack {
                FilledLineChart(chartData: chartData)
                    .filledTopLine(chartData: chartData,
                                   lineColour: ColourStyle(colour: .red),
                                   strokeStyle: StrokeStyle(lineWidth: 3))
                    .touchOverlay(chartData: chartData, unit: .suffix(of: "ppm"))
                    .floatingInfoBox(chartData: chartData)
                    .yAxisPOI(chartData: chartData,
                              markerName: "Ideal level",
                              markerValue: 500,
                              lineColour: Color(red: 0.5, green: 1.0, blue: 0.5),
                              strokeStyle: StrokeStyle(lineWidth: 3))
//                    .xAxisLabels(chartData: chartData)
//                    .xAxisGrid(chartData: chartData)
                    .yAxisLabels(chartData: chartData)
                    .headerBox(chartData: chartData)
                    .id(chartData.id)
                    .frame(minWidth: 150, maxWidth: 900, minHeight: 150, idealHeight: 300, maxHeight: 400, alignment: .center)
                    .padding(.horizontal)
                Button("Refresh") {
                    try? LuftioAirQualityProvider.getTimeSeriesFromApi(from: Calendar.current.date(byAdding: .day, value: -30, to: Date.now)!, to: Date.now) { res in
                        switch res {
                        case .Success(let timeseries):
                            data = timeseries
                            chartData = weekOfData(res: data)
                        case .Failure:
                            print("fail")
                        }
                    }
                }
            }.refreshable {
                try! LuftioAirQualityProvider.getTimeSeriesFromApi(from: Calendar.current.date(byAdding: .day, value: -30, to: Date.now)!, to: Date.now) { res in
                    switch res {
                    case .Success(let timeseries):
                        data = timeseries
                        chartData = weekOfData(res: data)
                    case .Failure:
                        print("fail")
                    }
                }
            }
            .navigationTitle("Luftio").refreshable {
                WidgetCenter.shared.reloadAllTimelines()
            }.toolbar {
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gear")
                }
            }.onAppear {
                try? LuftioAirQualityProvider.getTimeSeriesFromApi(from: Calendar.current.date(byAdding: .day, value: -3, to: Date.now)!, to: Date.now) { res in
                    switch res {
                    case .Success(let timeseries):
                        data = timeseries
                        chartData = weekOfData(res: data)
                    case .Failure:
                        print("fail")
                    }
                }
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SettingsView: View {
    @State var token = UserDefaults(suiteName: "group.vacekj")!.string(forKey: "web_token") ?? ""
    var body: some View {
        Form {
            Section(header: Text("API Token")) {
                HStack {
                    SecureField(text: $token, prompt: Text("eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJ2YWNla")) {
                        Text("API Token")
                    }
                    Button("Save token") {
                        UserDefaults(suiteName: "group.vacekj")!.set(token, forKey: "web_token")
                        WidgetCenter.shared.reloadAllTimelines()
                    }.buttonStyle(.bordered)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(data: .init(co2: [], tvoc: []), chartData: weekOfData())
    }
}
