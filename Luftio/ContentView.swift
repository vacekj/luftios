//
//  ContentView.swift
//  Apod
//
//  Created by SchwiftyUI on 12/7/20.
//

import SwiftUI
import Charts
import WidgetKit

struct ContentView: View {
    @State var data: Response = .init(co2: [], tvoc: [])
    @State var chartData: [Double] = [1.0, 2.0, 0.5]
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    HStack(alignment: .lastTextBaseline, spacing: 1) {
                        Text("CO2")
                        Spacer()
                        Text(data.co2.first?.value ?? "0")
                        Text("ppm").font(.footnote)
                    }
                    Button("Refresh") {
                        Network.shared.apollo.fetch(query: AccountQueryQuery()) { result in
                          switch result {
                          case .success(let graphQLResult):
                            print("Success! Result: \(graphQLResult)")
                          case .failure(let error):
                            print("Failure! Error: \(error)")
                          }
                        }
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
        ContentView(data: .init(co2: [], tvoc: []), chartData: [1.0, 2.0, 0.5])
    }
}
