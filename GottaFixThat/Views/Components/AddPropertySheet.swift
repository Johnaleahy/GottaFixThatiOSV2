//
//  AddPropertySheet.swift
//  GottaFixThat
//
//  Created on 2/2/26.
//

import SwiftUI
import SwiftData

struct AddPropertySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var propertyName: String = ""
    @State private var selectedImages: [PendingPhotoDraft] = []

    var body: some View {
        NavigationStack {
            Form {
                Section("Property Name") {
                    TextField("Enter property name", text: $propertyName)
                }

                Section("Photo") {
                    if let draft = selectedImages.first {
                        HStack {
                            Image(uiImage: draft.image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 8))

                            Spacer()

                            Button(role: .destructive) {
                                selectedImages.removeAll()
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                    }

                    PhotoPickerButton(selectedImages: $selectedImages)
                }
            }
            .navigationTitle("Add Property")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveProperty()
                        dismiss()
                    }
                    .disabled(propertyName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func saveProperty() {
        let trimmedName = propertyName.trimmingCharacters(in: .whitespaces)

        // Convert image to data if one was selected
        var imageData: Data? = nil
        if let image = selectedImages.first?.image {
            imageData = image.jpegData(compressionQuality: 0.8)
        }

        let owner = AppUser.fetchOrCreate(in: modelContext)
        let property = Property(name: trimmedName, imageData: imageData, owner: owner)
        modelContext.insert(property)

        try? modelContext.save()
    }
}

#Preview {
    AddPropertySheet()
        .modelContainer(for: [Property.self], inMemory: true)
}
