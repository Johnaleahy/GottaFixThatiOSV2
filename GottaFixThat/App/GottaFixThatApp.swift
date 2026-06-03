//
//  GottaFixThatApp.swift
//  GottaFixThat
//
//  Created by John Leahy on 2026-01-18.
//

import SwiftUI
import SwiftData

@main
struct GottaFixThatApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            User.self,
            Property.self,
            FixList.self,
            FixItem.self,
            FixPhoto.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])

            // Load sample data on first launch
            let context = container.mainContext
            let descriptor = FetchDescriptor<Property>()
            let existingProperties = try context.fetch(descriptor)
            if existingProperties.isEmpty {
                SampleData.createSampleData(in: context)
            }

            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            IntroView()
        }
        .modelContainer(sharedModelContainer)
    }
}
