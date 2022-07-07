//
//  ContentView.swift
//  Apod
//
//  Created by SchwiftyUI on 12/7/20.
//

import Charts
import LuftioWidgetExtension
import Model3DView
import SwiftUI
import WidgetKit

struct ApodTimelineEntry {
    let date: Date
    let value: Int
}

struct Card: View {
    var value: Int
    var name: String
    var unit: String
    var date: Date
    var body: some View {
        ZStack {
            Color(.white.toColor(.red, percentage: Double((value - 500) / 10)))
            VStack {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(value)").font(.title)
                    Text(unit).font(.footnote)
                }
                Text(date.formatted()).font(.footnote)
            }.foregroundColor(value > 1000 ? .white : .black)
        }
    }
}

struct ContentView: View {
    @State var data: Response = .init(co2: [], tvoc: [])
    @State var chartData: [Double] = [1.0, 2.0, 0.5]
    var body: some View {
        NavigationView {
            Grid {
                Card(value: 521, name: "CO2", unit: "ppm", date: Date.now)
            }
            .navigationTitle("Luftio").refreshable {
                WidgetCenter.shared.reloadAllTimelines()
            }.toolbar {
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gear")
                }
            }.task {
                Network.shared.apollo.fetch(query: AccountQueryQuery()) { result in
                    switch result {
                    case .success(let graphQLResult):
                        print("Success! Result: \(graphQLResult)")
                    case .failure(let error):
                        print("Failure! Error: \(error)")
                    }
                }
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SettingsView: View {
    @State var devices: DevicesQuery.Data?
    @State var camera = PerspectiveCamera()
    @State var token = UserDefaults(suiteName: "group.vacekj")!.string(forKey: "web_token") ?? ""
    @State var rotation = 0.0
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
            Section(header: Text("Devices")) {
                HStack {
                    VStack {
                        Text("Luftio Next 7").font(.largeTitle)
                        Model3DView(file: Bundle.main.url(forResource: "scene", withExtension: "gltf")!)
                            .transform(
                                rotate: Euler(x: .degrees(rotation)),
                                scale: 1.0
                            )
                            .cameraControls(OrbitControls(
                                camera: $camera,
                                sensitivity: 0.2,
                                friction: 0.05
                            )).frame(width: .infinity, height: 200, alignment: .leading)
                            .onAppear {
                                let baseAnimation = Animation.easeInOut(duration: 5.0)
                                withAnimation(baseAnimation) {
                                    rotation = -30
                                }
                            }.padding([.top], -30)
                        Label("Connected", systemImage: "dot.circle.fill").font(.footnote).foregroundColor(.green).bold().frame(alignment: .topLeading).padding([.vertical], 10)
                    }.padding([.top], 30)
                }
            }
        }.task {
            Network.shared.apollo.fetch(query: DevicesQuery()) { result in
                switch result {
                case .success(let graphQLResult):
                    devices = graphQLResult.data
                case .failure(let error):
                    print("Failure! Error: \(error)")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(data: .init(co2: [], tvoc: []), chartData: [1.0, 2.0, 0.5])
        SettingsView()
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
