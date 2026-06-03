//
//  FixList.swift
//  GottaFixThat
//
//  Created on 1/20/26.
//

import SwiftData
import Foundation

@Model
final class FixList: Hashable {
    // MARK: - Properties
    var id: UUID
    var name: String
    var iconName: String // SF Symbol name
    var createdAt: Date
    var updatedAt: Date
    var sortOrder: Int

    // MARK: - Relationships
    @Relationship(deleteRule: .cascade, inverse: \FixItem.list)
    var items: [FixItem]

    var property: Property?

    @Relationship(inverse: \User.sharedLists)
    var sharedWith: [User]

    // MARK: - Computed Properties
    var itemCount: Int {
        items.count
    }

    var completedCount: Int {
        items.filter { $0.isCompleted }.count
    }

    var progressPercentage: Double {
        guard itemCount > 0 else { return 0 }
        return Double(completedCount) / Double(itemCount)
    }

    // MARK: - Initialization
    init(name: String, iconName: String = "list.bullet", property: Property? = nil, sortOrder: Int = 0) {
        self.id = UUID()
        self.name = name
        self.iconName = iconName
        self.createdAt = Date()
        self.updatedAt = Date()
        self.sortOrder = sortOrder
        self.items = []
        self.property = property
        self.sharedWith = []
    }
}