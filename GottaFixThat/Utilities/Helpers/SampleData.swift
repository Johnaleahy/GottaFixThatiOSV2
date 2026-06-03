//
//  SampleData.swift
//  GottaFixThat
//
//  Created on 1/20/26.
//

import SwiftData
import Foundation

@MainActor
class SampleData {
    static func createSampleData(in modelContext: ModelContext) {
        // Clear existing data
        clearAllData(in: modelContext)

        // Create user
        let rebecca = User(name: "Rebecca")
        modelContext.insert(rebecca)

        // Create properties
        let home = Property(name: "Home", assetImageName: "WelcomePic", isFavorite: true, owner: rebecca)
        let cottage = Property(name: "Cottage", assetImageName: "cottage", owner: rebecca)
        modelContext.insert(home)
        modelContext.insert(cottage)

        // Create lists for Home
        let kimsBedroom = FixList(
            name: "Kim's Bedroom",
            iconName: "bed.double",
            property: home,
            sortOrder: 0
        )
        let kitchen = FixList(
            name: "Kitchen",
            iconName: "fork.knife",
            property: home,
            sortOrder: 1
        )
        let exterior = FixList(
            name: "Exterior",
            iconName: "house",
            property: home,
            sortOrder: 2
        )
        modelContext.insert(kimsBedroom)
        modelContext.insert(kitchen)
        modelContext.insert(exterior)

        // Create items for Kim's Bedroom
        let item1 = FixItem(
            title: "Re-caulk window",
            notes: "",
            isCompleted: false,
            priority: .medium,
            tags: ["KIM'S BEDROOM"],
            list: kimsBedroom,
            sortOrder: 0
        )

        let item2 = FixItem(
            title: "Patch crack in ceiling",
            notes: "",
            isCompleted: true,
            priority: .high,
            tags: ["KIM'S BEDROOM"],
            list: kimsBedroom,
            sortOrder: 1
        )
        item2.completedAt = Date().addingTimeInterval(-86400) // Completed yesterday

        let item3 = FixItem(
            title: "Paint baseboards",
            notes: "",
            isCompleted: false,
            priority: .medium,
            estimatedTimeHours: 2.5,
            tags: ["KIM'S BEDROOM"],
            list: kimsBedroom,
            sortOrder: 2
        )

        let item4 = FixItem(
            title: "Repair drywall",
            notes: "Us repudant, seque viorep erorum quia coria ipsa nos digent quo tem quiduci antotat uribus volorit quiArum a sed molore cus, etur aut earum que eumet eicipsape non endit r",
            isCompleted: false,
            priority: .high,
            tags: ["KIM'S BEDROOM"],
            list: kimsBedroom,
            sortOrder: 3
        )

        modelContext.insert(item1)
        modelContext.insert(item2)
        modelContext.insert(item3)
        modelContext.insert(item4)

        // Create items for Kitchen
        let item5 = FixItem(
            title: "Touch up cabinets",
            notes: "Sand lightly before painting",
            isCompleted: false,
            priority: .medium,
            estimatedTimeHours: 1.5,
            tags: ["KITCHEN"],
            list: kitchen,
            sortOrder: 0
        )

        let item6 = FixItem(
            title: "Fix leaky faucet",
            notes: "Check washers and O-rings",
            isCompleted: false,
            priority: .high,
            dueDate: Date().addingTimeInterval(604800), // Due in 1 week
            tags: ["KITCHEN", "PLUMBING"],
            list: kitchen,
            sortOrder: 1
        )

        modelContext.insert(item5)
        modelContext.insert(item6)

        // Create items for Exterior
        let item7 = FixItem(
            title: "Clean gutters",
            notes: "Check for blockages and damage",
            isCompleted: false,
            priority: .high,
            estimatedTimeHours: 3.0,
            tags: ["EXTERIOR", "SEASONAL"],
            list: exterior,
            sortOrder: 0
        )

        let item8 = FixItem(
            title: "Power wash deck",
            notes: "",
            isCompleted: false,
            priority: .low,
            estimatedTimeHours: 2.0,
            tags: ["EXTERIOR", "DECK"],
            list: exterior,
            sortOrder: 1
        )

        let item9 = FixItem(
            title: "Reseal driveway",
            notes: "Wait for dry weather",
            isCompleted: false,
            priority: .medium,
            dueDate: Date().addingTimeInterval(2592000), // Due in 30 days
            estimatedTimeHours: 4.0,
            tags: ["EXTERIOR", "DRIVEWAY"],
            list: exterior,
            sortOrder: 2
        )

        let item10 = FixItem(
            title: "Replace outdoor light",
            notes: "Front porch light fixture",
            isCompleted: false,
            priority: .medium,
            tags: ["EXTERIOR", "ELECTRICAL"],
            list: exterior,
            sortOrder: 3
        )

        let item11 = FixItem(
            title: "Trim bushes",
            notes: "",
            isCompleted: true,
            priority: .low,
            tags: ["EXTERIOR", "LANDSCAPING"],
            list: exterior,
            sortOrder: 4
        )
        item11.completedAt = Date().addingTimeInterval(-172800) // Completed 2 days ago

        modelContext.insert(item7)
        modelContext.insert(item8)
        modelContext.insert(item9)
        modelContext.insert(item10)
        modelContext.insert(item11)

        // Create Back Deck Refurb list for Home
        let backDeck = FixList(
            name: "Back Deck Refurb",
            iconName: "hammer",
            property: home,
            sortOrder: 3
        )
        modelContext.insert(backDeck)

        let deckItem1 = FixItem(
            title: "Replace deck boards",
            notes: "Check for rot and replace damaged boards",
            isCompleted: false,
            priority: .high,
            estimatedTimeHours: 8.0,
            tags: ["DECK", "REPAIR"],
            list: backDeck,
            sortOrder: 0
        )

        let deckItem2 = FixItem(
            title: "Pressure wash deck",
            notes: "Wait for dry weather",
            isCompleted: false,
            priority: .medium,
            estimatedTimeHours: 3.0,
            tags: ["DECK", "CLEANING"],
            list: backDeck,
            sortOrder: 1
        )

        let deckItem3 = FixItem(
            title: "Paint railings",
            notes: "Sand and prime before painting",
            isCompleted: false,
            priority: .low,
            estimatedTimeHours: 4.0,
            tags: ["DECK", "PAINTING"],
            list: backDeck,
            sortOrder: 2
        )

        modelContext.insert(deckItem1)
        modelContext.insert(deckItem2)
        modelContext.insert(deckItem3)

        // Create Shed Cleanup list for Home
        let shedCleanup = FixList(
            name: "Shed Cleanup",
            iconName: "broom",
            property: home,
            sortOrder: 4
        )
        modelContext.insert(shedCleanup)

        let shedItem1 = FixItem(
            title: "Scrape paint",
            notes: "Remove loose and peeling paint",
            isCompleted: false,
            priority: .medium,
            estimatedTimeHours: 2.0,
            tags: ["SHED", "PREP"],
            list: shedCleanup,
            sortOrder: 0
        )

        let shedItem2 = FixItem(
            title: "Replace hinges",
            notes: "Door hinges are rusty",
            isCompleted: false,
            priority: .high,
            tags: ["SHED", "HARDWARE"],
            list: shedCleanup,
            sortOrder: 1
        )

        let shedItem3 = FixItem(
            title: "Fix door closure",
            notes: "Door doesn't close properly",
            isCompleted: false,
            priority: .medium,
            tags: ["SHED", "DOOR"],
            list: shedCleanup,
            sortOrder: 2
        )

        modelContext.insert(shedItem1)
        modelContext.insert(shedItem2)
        modelContext.insert(shedItem3)

        // Create a list for Cottage
        let cottageExterior = FixList(
            name: "Exterior",
            iconName: "house",
            property: cottage,
            sortOrder: 0
        )
        modelContext.insert(cottageExterior)

        let cottageItem1 = FixItem(
            title: "Check roof for damage",
            notes: "After winter storms",
            isCompleted: false,
            priority: .high,
            tags: ["COTTAGE", "ROOF"],
            list: cottageExterior,
            sortOrder: 0
        )

        let cottageItem2 = FixItem(
            title: "Open for season",
            notes: "Turn on water, check for leaks, air out",
            isCompleted: false,
            priority: .high,
            dueDate: Date().addingTimeInterval(5184000), // Due in 60 days
            estimatedTimeHours: 5.0,
            tags: ["COTTAGE", "SEASONAL"],
            list: cottageExterior,
            sortOrder: 1
        )

        modelContext.insert(cottageItem1)
        modelContext.insert(cottageItem2)

        // Save all changes
        do {
            try modelContext.save()
            print("Sample data created successfully")
        } catch {
            print("Error saving sample data: \(error)")
        }
    }

    static func clearAllData(in modelContext: ModelContext) {
        // Delete all existing data
        do {
            try modelContext.delete(model: User.self)
            try modelContext.delete(model: Property.self)
            try modelContext.delete(model: FixList.self)
            try modelContext.delete(model: FixItem.self)
            try modelContext.delete(model: FixPhoto.self)
            try modelContext.save()
        } catch {
            print("Error clearing data: \(error)")
        }
    }
}
