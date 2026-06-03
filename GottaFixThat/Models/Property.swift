//
//  Property.swift
//  GottaFixThat
//
//  Created on 1/20/26.
//

import SwiftData
import SwiftUI
import Foundation

@Model
final class Property: Hashable {
    // MARK: - Properties
    var id: UUID
    var name: String
    var imageData: Data?
    var assetImageName: String?
    var isFavorite: Bool
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Relationships
    @Relationship(deleteRule: .cascade, inverse: \FixList.property)
    var lists: [FixList]

    var owner: User?

    // MARK: - Computed Properties
    var itemCount: Int {
        lists.reduce(0) { $0 + $1.items.count }
    }

    var completedItemCount: Int {
        lists.reduce(0) { total, list in
            total + list.items.filter { $0.isCompleted }.count
        }
    }

    // MARK: - Initialization
    init(name: String, imageData: Data? = nil, assetImageName: String? = nil, isFavorite: Bool = false, owner: User? = nil) {
        self.id = UUID()
        self.name = name
        self.imageData = imageData
        self.assetImageName = assetImageName
        self.isFavorite = isFavorite
        self.createdAt = Date()
        self.updatedAt = Date()
        self.lists = []
        self.owner = owner
    }
}

// MARK: - Sample Data
extension Property {
    static var sampleProperties: [Property] {
        [
            Property(name: "Cottage", assetImageName: "cottage", isFavorite: true),
            Property(name: "Home", assetImageName: "WelcomePic", isFavorite: false)
        ]
    }
}