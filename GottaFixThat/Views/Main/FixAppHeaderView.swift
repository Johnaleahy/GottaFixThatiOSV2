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

    var body: some View {
        NavigationStack {
            AppHeaderContainer {
                // Property cards
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(properties) { property in
                            NavigationLink(value: property) {
                                PropertyCardView(property: property)
                            }
                            .buttonStyle(.plain)
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
                            .foregroundStyle(Color.blueDark)
                            .frame(width: 36, height: 36)
                            .background(Color.grayLight)
                            .clipShape(Circle())
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddProperty = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.blueDark)
                            .frame(width: 36, height: 36)
                            .background(Color.grayLight)
                            .clipShape(Circle())
                    }
                }
            }
            .sheet(isPresented: $showingAddProperty) {
                AddPropertySheet()
            }
            .navigationDestination(for: Property.self) { property in
                PropertyListsView(property: property)
            }
        }
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
