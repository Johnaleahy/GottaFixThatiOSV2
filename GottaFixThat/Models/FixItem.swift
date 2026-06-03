//
//  FixItem.swift
//  GottaFixThat
//
//  Created on 1/20/26.
//

import SwiftData
import Foundation

// MARK: - Priority Enum
enum FixPriority: String, Codable, CaseIterable {
    case low = "LOW"
    case medium = "MEDIUM"
    case high = "HIGH"

    var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }

    var sortOrder: Int {
        switch self {
        case .high: return 0
        case .medium: return 1
        case .low: return 2
        }
    }
}

@Model
final class FixItem {
    // MARK: - Properties
    var id: UUID
    var title: String
    var notes: String
    var isCompleted: Bool
    var priority: FixPriority
    var dueDate: Date?
    var estimatedTimeHours: Double?
    var createdAt: Date
    var updatedAt: Date
    var completedAt: Date?
    var sortOrder: Int

    // Tags for categorization (e.g., "KITCHEN", "BEDROOM")
    var tags: [String]

    // MARK: - Relationships
    @Relationship(deleteRule: .cascade, inverse: \FixPhoto.item)
    var photos: [FixPhoto]

    var list: FixList?

    // MARK: - Computed Properties
    var isOverdue: Bool {
        guard let dueDate = dueDate, !isCompleted else { return false }
        return dueDate < Date()
    }

    var daysUntilDue: Int? {
        guard let dueDate = dueDate else { return nil }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: dueDate)
        return components.day
    }

    // MARK: - Initialization
    init(
        title: String,
        notes: String = "",
        isCompleted: Bool = false,
        priority: FixPriority = .medium,
        dueDate: Date? = nil,
        estimatedTimeHours: Double? = nil,
        tags: [String] = [],
        list: FixList? = nil,
        sortOrder: Int = 0
    ) {
        self.id = UUID()
        self.title = title
        self.notes = notes
        self.isCompleted = isCompleted
        self.priority = priority
        self.dueDate = dueDate
        self.estimatedTimeHours = estimatedTimeHours
        self.tags = tags
        self.createdAt = Date()
        self.updatedAt = Date()
        self.completedAt = nil
        self.sortOrder = sortOrder
        self.photos = []
        self.list = list
    }

    // MARK: - Methods
    func toggleCompletion() {
        isCompleted.toggle()
        completedAt = isCompleted ? Date() : nil
        updatedAt = Date()
    }
}