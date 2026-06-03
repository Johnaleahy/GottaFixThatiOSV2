//
//  FixListDetailView.swift
//  GottaFixThat
//
//  Created on 1/29/26.
//

import SwiftUI
import SwiftData

struct FixListDetailView: View {
    let list: FixList
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme

    // Inline editing state
    @State private var editingItemId: UUID?
    @State private var editingTitle: String = ""
    @FocusState private var focusedItemId: UUID?

    // Sheet state
    @State private var itemToEdit: FixItem?

    var sortedItems: [FixItem] {
        list.items.sorted { $0.sortOrder < $1.sortOrder }
    }

    var body: some View {
        AppHeaderContainer(showToolbarLogo: true) {
            List {
                // List header with icon and progress
                Section {
                    listHeader
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)

                // Items section
                Section("Items") {
                    ForEach(sortedItems) { item in
                        itemRow(for: item)
                            .listRowBackground(Color.dynamicCardBackground)
                    }
                    .onDelete(perform: deleteItems)
                }

                // Add item button
                Section {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus.circle.fill")
                            .foregroundColor(.greenAccent)
                    }
                    .listRowBackground(Color.dynamicCardBackground)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.dynamicPageBackground)
        }
        .sheet(item: $itemToEdit) { item in
            FixItemEditSheet(item: item)
        }
        .onChange(of: focusedItemId) { oldValue, newValue in
            // Save when focus leaves the editing field
            if oldValue != nil && newValue == nil {
                saveEditingTitle()
            }
        }
    }

    @ViewBuilder
    private var listHeader: some View {
        let primaryTextColor = colorScheme == .dark ? Color.white : Color.primary
        let secondaryTextColor = colorScheme == .dark ? Color.white.opacity(0.78) : Color.secondary

        VStack(alignment: .leading, spacing: 12) {
            // List name
            Text(list.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(primaryTextColor)

            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.greenAccent.opacity(0.15))
                        .frame(width: 60, height: 60)

                    Image(systemName: list.iconName)
                        .font(.title)
                        .foregroundColor(.greenAccent)
                }

                // Progress info
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(list.completedCount) of \(list.itemCount) completed")
                        .font(.subheadline)
                        .foregroundStyle(secondaryTextColor)

                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 8)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.greenAccent)
                                .frame(width: geometry.size.width * list.progressPercentage, height: 8)
                        }
                    }
                    .frame(height: 8)
                }

                Spacer()

                // Percentage
                Text("\(Int(list.progressPercentage * 100))%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.greenAccent)
            }
        }
        .padding()
        .background(Color.dynamicCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .padding(.vertical, 8)
    }

    private func itemRow(for item: FixItem) -> some View {
        HStack(alignment: .center, spacing: 12) {
            // Photo thumbnail (leftmost)
            let firstPhoto = item.photos.sorted(by: { $0.sortOrder < $1.sortOrder }).first
            PhotoThumbnailView(image: firstPhoto?.thumbnailImage, size: 48, isCircular: true)

            // Checkbox (right of image)
            Button(action: { toggleItem(item) }) {
                SquareCheckboxView(isChecked: item.isCompleted)
            }
            .buttonStyle(PlainButtonStyle())

            // Item details - tappable for editing
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    // Title - inline editable
                    if editingItemId == item.id {
                        TextField("Task title", text: $editingTitle)
                            .focused($focusedItemId, equals: item.id)
                            .onSubmit {
                                saveEditingTitle()
                            }
                            .strikethrough(item.isCompleted)
                            .foregroundColor(item.isCompleted ? .secondary : .primary)
                    } else {
                        Text(item.title)
                            .strikethrough(item.isCompleted)
                            .foregroundColor(item.isCompleted ? .secondary : .primary)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                startEditingTitle(for: item)
                            }
                    }

                    HStack(spacing: 8) {
                        PriorityBadge(priority: item.priority)

                        if let dueDate = item.dueDate {
                            HStack(spacing: 2) {
                                Image(systemName: "calendar")
                                Text(dueDate, style: .date)
                            }
                            .font(.caption2)
                            .foregroundColor(item.isOverdue ? .red : .secondary)
                        }

                        if let hours = item.estimatedTimeHours {
                            HStack(spacing: 2) {
                                Image(systemName: "clock")
                                Text("\(hours, specifier: "%.1f")h")
                            }
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        }

                        if !item.photos.isEmpty {
                            HStack(spacing: 2) {
                                Image(systemName: "camera.fill")
                                Text("\(item.photos.count)")
                            }
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                itemToEdit = item
            }

            Spacer()

            // Edit button to open sheet
            Button(action: { itemToEdit = item }) {
                Image(systemName: "chevron.right")
                    .font(.title3.weight(.bold))
                    .foregroundColor(.greenAccent)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 4)
    }

    private func startEditingTitle(for item: FixItem) {
        editingItemId = item.id
        editingTitle = item.title
        focusedItemId = item.id
    }

    private func saveEditingTitle() {
        guard let editingId = editingItemId else { return }

        let trimmedTitle = editingTitle.trimmingCharacters(in: .whitespaces)
        if !trimmedTitle.isEmpty {
            if let item = sortedItems.first(where: { $0.id == editingId }) {
                item.title = trimmedTitle
                item.updatedAt = Date()
                try? modelContext.save()
            }
        }

        editingItemId = nil
        editingTitle = ""
    }

    private func toggleItem(_ item: FixItem) {
        withAnimation {
            item.toggleCompletion()
            try? modelContext.save()
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = FixItem(
                title: "New Task",
                priority: .medium,
                list: list,
                sortOrder: list.items.count
            )
            modelContext.insert(newItem)
            try? modelContext.save()
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            let itemsToDelete = offsets.map { sortedItems[$0] }
            for item in itemsToDelete {
                modelContext.delete(item)
            }
            try? modelContext.save()
        }
    }
}

#Preview {
    NavigationStack {
        FixListDetailView(list: FixList(name: "Sample List", iconName: "hammer"))
    }
    .modelContainer(for: [User.self, Property.self, FixList.self, FixItem.self, FixPhoto.self], inMemory: true)
}
