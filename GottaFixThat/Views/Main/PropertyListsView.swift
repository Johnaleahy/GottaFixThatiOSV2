//
//  PropertyListsView.swift
//  GottaFixThat
//
//  Created on 1/29/26.
//

import SwiftUI
import SwiftData

struct PropertyListsView: View {
    let property: Property
    @Environment(\.modelContext) private var modelContext

    // Inline editing state
    @State private var isEditingPropertyName = false
    @State private var editingPropertyName: String = ""
    @FocusState private var isPropertyNameFocused: Bool
    @State private var editingListId: UUID?
    @State private var editingName: String = ""
    @FocusState private var focusedListId: UUID?

    // Navigation state
    @State private var selectedList: FixList?

    var sortedLists: [FixList] {
        property.lists.sorted { $0.sortOrder < $1.sortOrder }
    }

    var body: some View {
        AppHeaderContainer(showToolbarLogo: true) {
            List {
                // Property stats section
                Section {
                    propertyStatsBar
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)

                // Lists section
                Section("Lists") {
                    ForEach(sortedLists) { list in
                        listRowWithEditing(for: list)
                            .listRowBackground(Color.dynamicCardBackground)
                    }
                    .onDelete(perform: deleteLists)
                }

                // Add list button
                Section {
                    Button(action: addList) {
                        Label("Add List", systemImage: "plus.circle.fill")
                            .foregroundColor(.greenAccent)
                    }
                    .listRowBackground(Color.dynamicCardBackground)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.dynamicPageBackground)
        }
        .navigationDestination(for: FixList.self) { list in
            FixListDetailView(list: list)
        }
        .navigationDestination(item: $selectedList) { list in
            FixListDetailView(list: list)
        }
        .onAppear {
            editingPropertyName = property.name
        }
        .onChange(of: focusedListId) { oldValue, newValue in
            // Save when focus leaves the editing field
            if oldValue != nil && newValue == nil {
                saveEditingName()
            }
        }
        .onChange(of: isPropertyNameFocused) { oldValue, newValue in
            if oldValue && !newValue {
                savePropertyName()
            }
        }
        .onChange(of: selectedList) { _, newValue in
            if newValue != nil {
                saveEditingName()
                savePropertyName()
            }
        }
        .onDisappear {
            saveEditingName()
            savePropertyName()
        }
    }

    @ViewBuilder
    private var propertyStatsBar: some View {
        VStack(spacing: 8) {
            // Property name
            Group {
                if isEditingPropertyName {
                    TextField("Property name", text: $editingPropertyName)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Color.dynamicPrimaryText)
                        .focused($isPropertyNameFocused)
                        .submitLabel(.done)
                        .onSubmit {
                            savePropertyName()
                        }
                } else {
                    Text(property.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.dynamicPrimaryText)
                        .onTapGesture {
                            startEditingPropertyName()
                        }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.top, 8)

            // Stats bar
            HStack {
                VStack {
                    Text("\(property.lists.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.dynamicPrimaryText)
                    Text("Lists")
                        .font(.caption)
                        .foregroundStyle(Color.dynamicSecondaryText)
                }
                .frame(maxWidth: .infinity)

                Divider()
                    .frame(height: 40)
                    .overlay(Color.dynamicDivider)

                VStack {
                    Text("\(property.itemCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.dynamicPrimaryText)
                    Text("Items")
                        .font(.caption)
                        .foregroundStyle(Color.dynamicSecondaryText)
                }
                .frame(maxWidth: .infinity)

                Divider()
                    .frame(height: 40)
                    .overlay(Color.dynamicDivider)

                VStack {
                    Text("\(property.completedItemCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.dynamicPrimaryText)
                    Text("Done")
                        .font(.caption)
                        .foregroundStyle(Color.dynamicSecondaryText)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 12)
        }
        .background(Color.dynamicHeaderCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .dynamicShadow, radius: 4, x: 0, y: 2)
        .padding(.vertical, 8)
    }

    private func listRowWithEditing(for list: FixList) -> some View {
        HStack {
            Image(systemName: list.iconName)
                .foregroundColor(.greenAccent)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                // Name - inline editable
                if editingListId == list.id {
                    TextField("List name", text: $editingName)
                        .font(.headline)
                        .focused($focusedListId, equals: list.id)
                        .onSubmit {
                            saveEditingName()
                        }
                } else {
                    Text(list.name)
                        .font(.headline)
                        .foregroundStyle(Color.dynamicPrimaryText)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            startEditingName(for: list)
                        }
                }
                Text("\(list.itemCount) items • \(list.completedCount) completed")
                    .font(.caption)
                    .foregroundColor(.dynamicSecondaryText)
            }

            Spacer()

            if list.itemCount > 0 {
                ProgressCircle(progress: list.progressPercentage)
                    .frame(width: 40, height: 40)
            }

            // Navigate button
            Button(action: { selectedList = list }) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.greenAccent)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 4)
    }

    private func startEditingName(for list: FixList) {
        savePropertyName()
        editingListId = list.id
        editingName = list.name
        focusedListId = list.id
    }

    private func saveEditingName() {
        guard let editingId = editingListId else { return }

        let trimmedName = editingName.trimmingCharacters(in: .whitespaces)
        if !trimmedName.isEmpty {
            if let list = sortedLists.first(where: { $0.id == editingId }) {
                list.name = trimmedName
                list.updatedAt = Date()
                try? modelContext.save()
            }
        }

        editingListId = nil
        editingName = ""
    }

    private func startEditingPropertyName() {
        saveEditingName()
        editingPropertyName = property.name
        isEditingPropertyName = true
        isPropertyNameFocused = true
    }

    private func savePropertyName() {
        guard isEditingPropertyName else { return }

        let trimmedName = editingPropertyName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedName.isEmpty, trimmedName != property.name {
            property.name = trimmedName
            property.updatedAt = Date()
            try? modelContext.save()
        }

        editingPropertyName = property.name
        isEditingPropertyName = false
        isPropertyNameFocused = false
    }

    private func addList() {
        withAnimation {
            let newList = FixList(
                name: "New List",
                iconName: "list.bullet",
                property: property,
                sortOrder: property.lists.count
            )
            modelContext.insert(newList)
            do {
                try modelContext.save()
            } catch {
                assertionFailure("Failed to save new list: \(error)")
            }
        }
    }

    private func deleteLists(offsets: IndexSet) {
        withAnimation {
            let listsToDelete = offsets.map { sortedLists[$0] }
            for list in listsToDelete {
                modelContext.delete(list)
            }
            try? modelContext.save()
        }
    }
}

#Preview {
    NavigationStack {
        PropertyListsView(property: Property.sampleProperties[0])
    }
    .modelContainer(for: [User.self, Property.self, FixList.self, FixItem.self, FixPhoto.self], inMemory: true)
}
