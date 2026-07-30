//
//  FixAppHeaderView.swift
//  GottaFixThat
//
//  Created on 1/29/26.
//

import SwiftUI
import SwiftData

struct FixAppHeaderView: View {
    @Query(sort: \Property.name) private var properties: [Property]
    @Environment(\.dismiss) private var dismiss
    var onMenuTap: (() -> Void)? = nil

    @State private var showingAddProperty = false
    @State private var propertyToEdit: Property?

    private var activeProperties: [Property] {
        properties.filter { !$0.isArchived }
    }

    var body: some View {
        NavigationStack {
            AppHeaderContainer {
                // Property cards
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(activeProperties) { property in
                            NavigationLink(value: property) {
                                PropertyCardView(property: property)
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button("Edit Property") {
                                    propertyToEdit = property
                                }

                                Button("Archive Property", role: .destructive) {
                                    archive(property)
                                }

                                Button("Delete Property", role: .destructive) {
                                    delete(property)
                                }
                            }
                        }
                    }
                    .padding()
                }
                .background(Color.dynamicPageBackground)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.dynamicPrimaryText)
                            .frame(width: 36, height: 36)
                            .background(Color.dynamicHeaderCardBackground)
                            .clipShape(Circle())
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddProperty = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.dynamicPrimaryText)
                            .frame(width: 36, height: 36)
                            .background(Color.dynamicHeaderCardBackground)
                            .clipShape(Circle())
                    }
                }
            }
            .sheet(isPresented: $showingAddProperty) {
                AddPropertySheet()
            }
            .sheet(item: $propertyToEdit) { property in
                AddPropertySheet(property: property)
            }
            .navigationDestination(for: Property.self) { property in
                PropertyListsView(property: property)
            }
        }
    }

    private func archive(_ property: Property) {
        property.isArchived = true
        property.updatedAt = Date()
        try? property.modelContext?.save()
    }

    private func delete(_ property: Property) {
        guard let context = property.modelContext else { return }
        context.delete(property)
        try? context.save()
    }
}

#Preview {
    FixAppHeaderView()
        .modelContainer(PreviewSampleData.container)
}

@MainActor
enum PreviewSampleData {
    static var container: ModelContainer = {
        let schema = Schema([
            User.self,
            Property.self,
            FixList.self,
            FixItem.self,
            FixPhoto.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])

        // Load sample data into preview container
        SampleData.createSampleData(in: container.mainContext)

        return container
    }()
}
