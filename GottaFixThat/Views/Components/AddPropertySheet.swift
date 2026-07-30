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

    private let propertyToEdit: Property?

    @State private var propertyName: String = ""
    @State private var selectedImages: [PendingPhotoDraft] = []
    @State private var saveErrorMessage: String?
    @State private var showDeleteConfirmation = false
    @State private var showArchiveConfirmation = false

    init(property: Property? = nil) {
        self.propertyToEdit = property
        _propertyName = State(initialValue: property?.name ?? "")

        if let imageData = property?.imageData,
           let image = UIImage(data: imageData) {
            _selectedImages = State(initialValue: [PendingPhotoDraft(image: image)])
        } else {
            _selectedImages = State(initialValue: [])
        }
    }

    private var isEditing: Bool {
        propertyToEdit != nil
    }

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

                    Text("Each property currently supports one photo.")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    PhotoPickerButton(
                        selectedImages: $selectedImages,
                        maxSelectionCount: 1,
                        replaceSelection: true,
                        buttonLabel: selectedImages.isEmpty ? "Choose Photo" : "Replace Photo"
                    )
                }

                if isEditing {
                    Section("Manage Property") {
                        Button("Archive Property") {
                            showArchiveConfirmation = true
                        }
                        .foregroundStyle(.orange)

                        Button("Delete Property", role: .destructive) {
                            showDeleteConfirmation = true
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Property" : "Add Property")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if saveProperty() {
                            dismiss()
                        }
                    }
                    .disabled(propertyName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .confirmationDialog("Archive this property?", isPresented: $showArchiveConfirmation, titleVisibility: .visible) {
            Button("Archive Property", role: .destructive) {
                archiveProperty()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Archived properties will be hidden from the main property list.")
        }
        .confirmationDialog("Delete this property?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete Property", role: .destructive) {
                deleteProperty()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Deleting a property also deletes its lists and tasks.")
        }
        .alert("Save Failed", isPresented: Binding(
            get: { saveErrorMessage != nil },
            set: { if !$0 { saveErrorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {
                saveErrorMessage = nil
            }
        } message: {
            Text(saveErrorMessage ?? "Please try again.")
        }
    }

    private func saveProperty() -> Bool {
        let trimmedName = propertyName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            saveErrorMessage = "Property name cannot be empty."
            return false
        }

        // Convert image to data if one was selected
        var imageData: Data? = nil
        if let image = selectedImages.first?.image {
            imageData = image.jpegData(compressionQuality: 0.8)
        }

        if let propertyToEdit {
            propertyToEdit.name = trimmedName
            propertyToEdit.imageData = imageData
            if imageData != nil {
                propertyToEdit.assetImageName = nil
            }
            propertyToEdit.updatedAt = Date()
        } else {
            let owner = AppUser.fetchOrCreate(in: modelContext)
            let property = Property(name: trimmedName, imageData: imageData, owner: owner)
            modelContext.insert(property)
        }

        do {
            try modelContext.save()
            return true
        } catch {
            saveErrorMessage = "The property could not be saved."
            return false
        }
    }

    private func archiveProperty() {
        guard let propertyToEdit else { return }
        propertyToEdit.isArchived = true
        propertyToEdit.updatedAt = Date()

        do {
            try modelContext.save()
            dismiss()
        } catch {
            saveErrorMessage = "The property could not be archived."
        }
    }

    private func deleteProperty() {
        guard let propertyToEdit else { return }
        modelContext.delete(propertyToEdit)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            saveErrorMessage = "The property could not be deleted."
        }
    }
}

#Preview {
    AddPropertySheet()
        .modelContainer(for: [Property.self], inMemory: true)
}
