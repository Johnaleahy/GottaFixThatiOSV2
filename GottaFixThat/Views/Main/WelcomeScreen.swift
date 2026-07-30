//
//  WelcomeScreen.swift
//  GottaFixThat
//
//  Created on 1/21/26.
//

import SwiftUI
import SwiftData

struct WelcomeScreen: View {
    @Query private var users: [User]
    @Query private var fixItems: [FixItem]
    @State private var selectedItems: Set<FixItem> = []
    @State private var showingMenu = false

    var currentUser: User? {
        users.first
    }

    var userName: String {
        currentUser?.name ?? "there"
    }

    var fallbackSuggestedItems: [FixItem] {
        fixItems
            .filter { !$0.isCompleted }
            .sorted { item1, item2 in
                // Sort by priority first, then by due date
                if item1.priority.sortOrder != item2.priority.sortOrder {
                    return item1.priority.sortOrder < item2.priority.sortOrder
                }
                if let date1 = item1.dueDate, let date2 = item2.dueDate {
                    return date1 < date2
                }
                return false
            }
            .prefix(2)
            .map { $0 }
    }

    var smartPlan: SmartJobPlan? {
        SmartPlanningService.buildPlan(from: fixItems)
    }

    var suggestedItems: [FixItem] {
        smartPlan?.suggestedItems ?? fallbackSuggestedItems
    }

    var totalEstimatedTime: Double {
        selectedItems.reduce(0) { total, item in
            total + (item.estimatedTimeHours ?? 0)
        }
    }

    var currentDate: Date {
        Date()
    }

    var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: currentDate).uppercased()
    }

    var dayOfMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: currentDate)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.dynamicPageBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header with logo
                    headerView

                    ScrollView {
                        VStack(spacing: 20) {
                            if smartPlan != nil {
                                headerSuggestionCard
                            }

                            // Task list
                            if !suggestedItems.isEmpty {
                                taskListSection
                            }

                            // Estimated time
                            if !selectedItems.isEmpty {
                                estimatedTimeSection
                            }

                            // Motivational message
                            motivationalSection

                            // Next Steps button
                            nextStepsButton
                        }
                        .padding()
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: - Header View
    private var headerView: some View {
        ZStack(alignment: .top) {
            // Header background with FixAppHeader image - extended to include suggestion card
            GeometryReader { geometry in
                Image("FixAppHeader")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
            .frame(height: 120)
            VStack(spacing: 16) {
        
                
                // Logo row
                HStack(alignment: .center) {
                    
                    // Checkmark and title
                    HStack{
                        //logo
                        Image("Fix Logo with Outline")
                        // White checkbox with blueDark checkmark
                    }
                    .padding(.leading, 16)

                    Spacer()

                    // Menu button - white color
                    Button(action: { showingMenu.toggle() }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .padding(.trailing, 16)
                }
                .padding(.top, 50)
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Header Suggestion Card (inside green area)
    private var headerSuggestionCard: some View {
        HStack(alignment: .top, spacing: 15) {
            // Calendar widget with weather icons
            VStack(spacing: 0) {
                // Weather icons row
                HStack(spacing: 4) {
                    Image(systemName: "cloud.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.8))
                    Image(systemName: "cloud.rain.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.top, 6)

                Text(dayOfWeek)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)

                Text(dayOfMonth)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.bottom, 6)
            }
            .frame(width: 70, height: 80)
            .background(Color.blueMedium)
            .cornerRadius(12)

            VStack(alignment: .leading, spacing: 6) {
                Text(smartPlan?.headline ?? "Suggested plan")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.greenAccent)

                Text(planMessage)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.dynamicPrimaryText)
                    .fixedSize(horizontal: false, vertical: true)

                if let smartPlan {
                    Text("\(smartPlan.focusLabel.uppercased()) FOCUS • \(smartPlan.suggestedItems.count) JOBS")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.dynamicTertiaryText)
                        .tracking(1)
                }
            }

            Spacer()
        }
        .padding()
        .background(Color.dynamicHeaderCardBackground)
        .cornerRadius(15)
        .shadow(color: .dynamicShadow, radius: 5, x: 0, y: 2)
    }

    // MARK: - Task List Section
    private var taskListSection: some View {
        VStack(spacing: 0) {
            ForEach(suggestedItems) { item in
                HStack {
                    // Checkbox
                    Button(action: { toggleSelection(item) }) {
                        SquareCheckboxView(isChecked: selectedItems.contains(item))
                    }
                    .buttonStyle(PlainButtonStyle())

                    // Task title
                    Text(item.title)
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(.dynamicPrimaryText)

                    Spacer()

                    // Tag
                    if let tag = item.tags.first {
                        Text(tag)
                            .font(.system(size: 11, weight: .semibold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(tagColor(for: tag))
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }

                    // Chevron
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.dynamicTertiaryText)
                        .padding(.leading, 8)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)

                if item != suggestedItems.last {
                    Divider()
                        .padding(.leading, 20)
                        .overlay(Color.dynamicDivider)
                }
            }
        }
        .background(Color.dynamicCardBackground)
        .cornerRadius(12)
        .shadow(color: .dynamicShadow, radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }

    // MARK: - Estimated Time Section
    private var estimatedTimeSection: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("ESTIMATED TIME")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.dynamicTertiaryText)
                .tracking(1)

            HStack(spacing: 8) {
                Image(systemName: "clock")
                    .font(.system(size: 18))
                    .foregroundColor(.dynamicTertiaryText)

                Text(estimatedTimeText)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.dynamicPrimaryText)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 8)
        .background(Color.dynamicCardBackground)
        .cornerRadius(12)
        .shadow(color: .dynamicShadow, radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }

    // MARK: - Motivational Section
    private var motivationalSection: some View {
        VStack(spacing: 10) {
            // Paint can illustration (using SF Symbol as placeholder)
            Image(systemName: "paintbrush.fill")
                .font(.system(size: 80))
                .foregroundColor(.dynamicTertiaryText.opacity(0.35))
                .padding(.bottom, 10)

            Text("You've got this!")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.dynamicPrimaryText)
        }
        .padding(.vertical, 30)
    }

    // MARK: - Next Steps Button
    private var nextStepsButton: some View {
        Button(action: {
            applySuggestedPlan()
        }) {
            Text("LOAD TODAY'S PLAN")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.greenAccent)
                .cornerRadius(12)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }

    // MARK: - Helper Methods
    private func toggleSelection(_ item: FixItem) {
        if selectedItems.contains(item) {
            selectedItems.remove(item)
        } else {
            selectedItems.insert(item)
        }
    }

    private var estimatedTimeText: String {
        let hours = totalEstimatedTime > 0 ? totalEstimatedTime : (smartPlan?.totalEstimatedHours ?? 0)
        if hours == 0 {
            return "No estimate yet"
        }
        return "\(String(format: "%.1f", hours)) Hours"
    }

    private var planMessage: String {
        if let smartPlan {
            return smartPlan.summary
        }
        return "Hey \(userName), this would be a good time to tackle a few quick wins."
    }

    private func applySuggestedPlan() {
        selectedItems = Set(suggestedItems)
    }

    private func tagColor(for tag: String) -> Color {
        switch tag.lowercased() {
        case "kitchen":
            return .blueMedium
        case "kim's bedroom", "bedroom":
            return .greenAccent
        case "exterior":
            return .blueLight
        default:
            return .blueDark
        }
    }
}

// MARK: - Menu View (Placeholder)
struct MenuView: View {
    @Binding var isPresented: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Button(action: { isPresented = false }) {
                Image(systemName: "xmark")
                    .font(.title2)
            }
            .padding()

            Text("Menu")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.horizontal)

            // Menu items would go here

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.dynamicCardBackground)
    }
}

#Preview {
    WelcomeScreen()
        .modelContainer(for: [User.self, Property.self, FixList.self, FixItem.self, FixPhoto.self], inMemory: true)
}
