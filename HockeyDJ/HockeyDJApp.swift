//
//  HockeyDJApp.swift
//  HockeyDJ
//
//  Created on 2026-02-16
//

import SwiftUI

@main
struct HockeyDJApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
