//
//  GottaFixThatTests.swift
//  GottaFixThatTests
//
//  Created by John Leahy on 2026-01-18.
//

import Foundation
import SwiftData
import Testing
import UIKit
@testable import GottaFixThat

@MainActor
struct GottaFixThatTests {

    @Test
    func toggleCompletion_marksItemCompletedAndSetsTimestamps() {
        let originalUpdatedAt = Date(timeIntervalSince1970: 1_000)
        let item = FixItem(title: "Replace deck board")
        item.updatedAt = originalUpdatedAt

        item.toggleCompletion()

        #expect(item.isCompleted)
        #expect(item.completedAt != nil)
        #expect(item.updatedAt > originalUpdatedAt)
    }

    @Test
    func toggleCompletion_clearsCompletedAtWhenMarkingIncomplete() {
        let item = FixItem(title: "Seal windows", isCompleted: true)
        item.completedAt = Date(timeIntervalSince1970: 2_000)
        item.updatedAt = Date(timeIntervalSince1970: 1_000)

        item.toggleCompletion()

        #expect(item.isCompleted == false)
        #expect(item.completedAt == nil)
        #expect(item.updatedAt > Date(timeIntervalSince1970: 1_000))
    }

    @Test
    func isOverdue_isFalseWithoutDueDate() {
        let item = FixItem(title: "Paint shed")

        #expect(item.isOverdue == false)
    }

    @Test
    func isOverdue_isFalseWhenItemIsCompleted() {
        let item = FixItem(
            title: "Paint shed",
            isCompleted: true,
            dueDate: Date(timeIntervalSinceNow: -3_600)
        )

        #expect(item.isOverdue == false)
    }

    @Test
    func isOverdue_isTrueWhenDueDateIsInThePast() {
        let item = FixItem(
            title: "Paint shed",
            dueDate: Date(timeIntervalSinceNow: -3_600)
        )

        #expect(item.isOverdue)
    }

    @Test
    func fixListComputedProperties_reflectItemState() {
        let list = FixList(name: "Exterior")
        list.items = [
            FixItem(title: "Door trim", isCompleted: true),
            FixItem(title: "Back deck", isCompleted: false),
            FixItem(title: "Fence gate", isCompleted: true)
        ]

        #expect(list.itemCount == 3)
        #expect(list.completedCount == 2)
        #expect(list.progressPercentage == (2.0 / 3.0))
    }

    @Test
    func fixListProgressPercentage_isZeroForEmptyList() {
        let list = FixList(name: "Empty")

        #expect(list.itemCount == 0)
        #expect(list.completedCount == 0)
        #expect(list.progressPercentage == 0)
    }

    @Test
    func propertyComputedProperties_rollUpAcrossLists() {
        let property = Property(name: "Cottage")

        let interior = FixList(name: "Interior")
        interior.items = [
            FixItem(title: "Bedroom paint", isCompleted: true),
            FixItem(title: "Closet door", isCompleted: false)
        ]

        let exterior = FixList(name: "Exterior")
        exterior.items = [
            FixItem(title: "Shed cleanup", isCompleted: true)
        ]

        property.lists = [interior, exterior]

        #expect(property.itemCount == 3)
        #expect(property.completedItemCount == 2)
    }

    @Test
    func generateThumbnail_createsThumbnailDataFromValidImageData() throws {
        let image = UIGraphicsImageRenderer(size: CGSize(width: 400, height: 300)).image { context in
            UIColor.systemTeal.setFill()
            context.cgContext.fill(CGRect(x: 0, y: 0, width: 400, height: 300))
        }

        let imageData = try #require(image.jpegData(compressionQuality: 0.9))
        let photo = FixPhoto(imageData: imageData, thumbnailData: nil)

        photo.generateThumbnail()

        let thumbnailData = try #require(photo.thumbnailData)
        let thumbnailImage = try #require(UIImage(data: thumbnailData))

        #expect(thumbnailImage.pixelSize.width <= 200.0)
        #expect(thumbnailImage.pixelSize.height <= 200.0)
    }

    @Test
    func fetchOrCreate_createsDefaultUserWhenStoreIsEmpty() throws {
        let container = try makeInMemoryContainer()
        let modelContext = ModelContext(container)

        let user = AppUser.fetchOrCreate(in: modelContext)
        let users = try modelContext.fetch(FetchDescriptor<User>())

        #expect(user.name == AppUser.defaultName)
        #expect(users.count == 1)
        #expect(users.first?.id == user.id)
    }

    @Test
    func fetchOrCreate_returnsExistingUserWithoutCreatingDuplicate() throws {
        let container = try makeInMemoryContainer()
        let modelContext = ModelContext(container)
        let existingUser = User(name: "Existing User")
        modelContext.insert(existingUser)

        let fetchedUser = AppUser.fetchOrCreate(in: modelContext)
        let users = try modelContext.fetch(FetchDescriptor<User>())

        #expect(fetchedUser.id == existingUser.id)
        #expect(users.count == 1)
        #expect(users.first?.name == "Existing User")
    }

    private func makeInMemoryContainer() throws -> ModelContainer {
        let schema = Schema([
            User.self,
            Property.self,
            FixList.self,
            FixItem.self,
            FixPhoto.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
