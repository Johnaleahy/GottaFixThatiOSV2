//
//  User.swift
//  GottaFixThat
//
//  Created on 1/20/26.
//

import SwiftData
import Foundation

@Model
final class User {
    // MARK: - Properties
    var id: UUID
    var name: String
    var profileImageData: Data?
    var createdAt: Date

    // MARK: - Relationships
    @Relationship(deleteRule: .cascade, inverse: \Property.owner)
    var ownedProperties: [Property]

    @Relationship(deleteRule: .nullify)
    var sharedLists: [FixList]

    // MARK: - Initialization
    init(name: String, profileImageData: Data? = nil) {
        self.id = UUID()
        self.name = name
        self.profileImageData = profileImageData
        self.createdAt = Date()
        self.ownedProperties = []
        self.sharedLists = []
    }
}