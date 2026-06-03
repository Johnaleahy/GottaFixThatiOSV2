//
//  AppUser.swift
//  GottaFixThat
//
//  Created on 4/3/26.
//

import SwiftData

enum AppUser {
    static let defaultName = "Rebecca"

    @MainActor
    static func fetchOrCreate(in modelContext: ModelContext) -> User {
        let descriptor = FetchDescriptor<User>()

        if let user = try? modelContext.fetch(descriptor).first {
            return user
        }

        let user = User(name: defaultName)
        modelContext.insert(user)
        return user
    }
}
