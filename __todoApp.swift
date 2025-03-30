//
//  __todoApp.swift
//  7_todo
//
//  Created by alchain on 2025/3/17.
//

import SwiftUI
import SwiftData

@main
struct __todoApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Task.self,
            SubTask.self,
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(sharedModelContainer)
    }
}
