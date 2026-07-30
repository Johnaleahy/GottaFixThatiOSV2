//
//  SmartPlanningService.swift
//  GottaFixThat
//
//  Created on 2026-06-03.
//

import Foundation

struct SmartJobPlan {
    let headline: String
    let summary: String
    let focusLabel: String
    let suggestedItems: [FixItem]
    let totalEstimatedHours: Double
}

enum SmartPlanningService {
    static func buildPlan(from items: [FixItem], now: Date = Date()) -> SmartJobPlan? {
        let openItems = items.filter { !$0.isCompleted }
        guard !openItems.isEmpty else { return nil }

        let rankedItems = openItems.sorted { lhs, rhs in
            score(for: lhs, now: now) > score(for: rhs, now: now)
        }

        let suggestedItems = Array(rankedItems.prefix(3))
        let totalHours = suggestedItems.reduce(0) { $0 + ($1.estimatedTimeHours ?? defaultEstimatedHours(for: $1)) }
        let focusLabel = focusLabel(for: suggestedItems)

        return SmartJobPlan(
            headline: headline(for: suggestedItems, now: now),
            summary: summary(for: suggestedItems, focusLabel: focusLabel),
            focusLabel: focusLabel,
            suggestedItems: suggestedItems,
            totalEstimatedHours: totalHours
        )
    }

    private static func score(for item: FixItem, now: Date) -> Int {
        var total = 0

        switch item.priority {
        case .high:
            total += 60
        case .medium:
            total += 35
        case .low:
            total += 10
        }

        if let dueDate = item.dueDate {
            let days = Calendar.current.dateComponents([.day], from: now, to: dueDate).day ?? 0
            if days < 0 {
                total += 70
            } else if days == 0 {
                total += 40
            } else if days <= 3 {
                total += 25
            } else if days <= 7 {
                total += 12
            }
        }

        if let estimatedHours = item.estimatedTimeHours, estimatedHours <= 2 {
            total += 8
        }

        if !item.photos.isEmpty {
            total += 4
        }

        return total
    }

    private static func headline(for items: [FixItem], now: Date) -> String {
        if items.contains(where: \.isOverdue) {
            return "Start with overdue fixes"
        }
        if items.contains(where: { item in
            guard let dueDate = item.dueDate else { return false }
            return Calendar.current.isDateInToday(dueDate)
        }) {
            return "Best jobs to finish today"
        }
        if items.contains(where: { $0.priority == .high }) {
            return "High-priority plan"
        }
        return "Recommended next jobs"
    }

    private static func summary(for items: [FixItem], focusLabel: String) -> String {
        let titles = items.prefix(2).map(\.title)
        let joinedTitles = ListFormatter.localizedString(byJoining: titles)
        if items.count == 1 {
            return "Focus on \(joinedTitles) first. It has the strongest priority and timing signal right now."
        }
        return "Focus on \(focusLabel.lowercased()) by starting with \(joinedTitles). This keeps the highest-value work moving first."
    }

    private static func focusLabel(for items: [FixItem]) -> String {
        let tags = items.flatMap(\.tags)
        if let firstTag = tags.first, tags.filter({ $0 == firstTag }).count >= 2 {
            return firstTag.capitalized
        }
        if items.contains(where: \.isOverdue) {
            return "Catch-up"
        }
        if items.contains(where: { $0.priority == .high }) {
            return "Priority"
        }
        return "Balanced"
    }

    private static func defaultEstimatedHours(for item: FixItem) -> Double {
        switch item.priority {
        case .high:
            return 2
        case .medium:
            return 1.5
        case .low:
            return 1
        }
    }
}
