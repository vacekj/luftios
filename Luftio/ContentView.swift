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
        Button("Refresh") {
            WidgetCenter.shared.reloadAllTimelines()
        }.buttonStyle(.bordered)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
