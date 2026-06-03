//
//  ContentView.swift
//  GottaFixThat
//
//  Created by John Leahy on 2026-01-18.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Property.name) private var properties: [Property]
    @Query private var users: [User]

    @State private var selectedProperty: Property?

    var currentUser: User? {
        users.first
    }

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedProperty) {
                Section("Properties") {
                    ForEach(properties) { property in
                        NavigationLink(value: property) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(property.name)
                                        .font(.headline)
                                    Text("\(property.itemCount) items")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                if property.isFavorite {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .onDelete(perform: deleteProperties)
                }
            }
            .navigationTitle("GottaFixThat")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addProperty) {
                        Label("Add Property", systemImage: "plus")
                    }
                }
            }
        } detail: {
            if let property = selectedProperty {
                PropertyDetailView(property: property)
            } else {
                Text("Select a property")
                    .font(.largeTitle)
                    .foregroundColor(.secondary)
            }
        }
    }

    private func addProperty() {
        withAnimation {
            let user = users.first ?? AppUser.fetchOrCreate(in: modelContext)
            let newProperty = Property(
                name: "New Property",
                isFavorite: false,
                owner: user
            )
            modelContext.insert(newProperty)

            // Save immediately
            try? modelContext.save()
        }
    }

    private func deleteProperties(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(properties[index])
            }
            try? modelContext.save()
        }
    }
}

// MARK: - Property Detail View
struct PropertyDetailView: View {
    let property: Property
    @Environment(\.modelContext) private var modelContext
    @State private var selectedList: FixList?

    var body: some View {
        NavigationStack {
            List {
                Section("Lists") {
                    ForEach(property.lists.sorted(by: { $0.sortOrder < $1.sortOrder })) { list in
                        NavigationLink(destination: ListDetailView(list: list)) {
                            HStack {
                                Image(systemName: list.iconName)
                                    .foregroundColor(.greenAccent)
                                    .frame(width: 30)

                                VStack(alignment: .leading) {
                                    Text(list.name)
                                        .font(.headline)
                                    Text("\(list.itemCount) items • \(list.completedCount) completed")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                if list.itemCount > 0 {
                                    ProgressCircle(progress: list.progressPercentage)
                                        .frame(width: 40, height: 40)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .onDelete(perform: deleteLists)
                }

                Section {
                    Button(action: addList) {
                        Label("Add List", systemImage: "plus.circle.fill")
                            .foregroundColor(.greenAccent)
                    }
                }
            }
            .navigationTitle(property.name)
            .navigationBarTitleDisplayMode(.large)
        }
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
            try? modelContext.save()
        }
    }

    private func deleteLists(offsets: IndexSet) {
        withAnimation {
            let listsToDelete = offsets.map { property.lists.sorted(by: { $0.sortOrder < $1.sortOrder })[$0] }
            for list in listsToDelete {
                modelContext.delete(list)
            }
            try? modelContext.save()
        }
    }
}

// MARK: - List Detail View
struct ListDetailView: View {
    let list: FixList
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        List {
            ForEach(list.items.sorted(by: { $0.sortOrder < $1.sortOrder })) { item in
                HStack {
                    Button(action: { toggleItem(item) }) {
                        Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(item.isCompleted ? .greenAccent : .gray)
                            .font(.title2)
                    }
                    .buttonStyle(PlainButtonStyle())

                    VStack(alignment: .leading) {
                        Text(item.title)
                            .strikethrough(item.isCompleted)
                            .foregroundColor(item.isCompleted ? .secondary : .primary)

                        if !item.notes.isEmpty {
                            Text(item.notes)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }

                        HStack {
                            PriorityBadge(priority: item.priority)

                            if let dueDate = item.dueDate {
                                Text(dueDate, style: .date)
                                    .font(.caption2)
                                    .foregroundColor(item.isOverdue ? .red : .secondary)
                            }
                        }
                    }

                    Spacer()
                }
                .padding(.vertical, 4)
            }
            .onDelete(perform: deleteItems)

            Button(action: addItem) {
                Label("Add Item", systemImage: "plus.circle.fill")
                    .foregroundColor(.greenAccent)
            }
        }
        .navigationTitle(list.name)
        .navigationBarTitleDisplayMode(.large)
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
            let itemsToDelete = offsets.map { list.items.sorted(by: { $0.sortOrder < $1.sortOrder })[$0] }
            for item in itemsToDelete {
                modelContext.delete(item)
            }
            try? modelContext.save()
        }
    }
}

// MARK: - Helper Views
struct ProgressCircle: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 3)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.greenAccent, lineWidth: 3)
                .rotationEffect(Angle(degrees: -90))

            Text("\(Int(progress * 100))%")
                .font(.caption2)
        }
    }
}

struct PriorityBadge: View {
    let priority: FixPriority

    var body: some View {
        Text(priority.displayName.uppercased())
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(backgroundColorForPriority)
            .foregroundColor(.white)
            .cornerRadius(4)
    }

    var backgroundColorForPriority: Color {
        switch priority {
        case .high:
            return .red
        case .medium:
            return .orange
        case .low:
            return .blue
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [User.self, Property.self, FixList.self, FixItem.self, FixPhoto.self], inMemory: true)
}
