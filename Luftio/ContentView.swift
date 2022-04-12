//
//  ContentView.swift
//  Apod
//
//  Created by SchwiftyUI on 12/7/20.
//

import SwiftUI
import WidgetKit

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {}.navigationTitle("Luftio").refreshable {
                WidgetCenter.shared.reloadAllTimelines()
            }.toolbar {
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gear")
                }
            }
        }
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
        ContentView()
    }
}
