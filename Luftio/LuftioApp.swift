//
//  ApodApp.swift
//  Apod
//
//  Created by SchwiftyUI on 12/7/20.
//

import SwiftUI

@main
struct LuftioApp: App {
    @StateObject var launchViewModel = UserViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(launchViewModel)
        }
    }
}
