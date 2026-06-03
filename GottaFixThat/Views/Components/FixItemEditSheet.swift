//
//  FixItemEditSheet.swift
//  GottaFixThat
//
//  Created on 2/1/26.
//

import SwiftUI
import os

struct FixItemEditSheet: View {
    @Bindable var item: FixItem
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var title: String
    @State private var notes: String
    @State private var priority: FixPriority
    @State private var hasDueDate: Bool
    @State private var dueDate: Date
    @State private var hasEstimatedTime: Bool
    @State private var estimatedTimeHours: Double
    @State private var tags: [String]
    @State private var saveErrorMessage: String?

    // Photo state
    @State private var newPhotos: [PendingPhotoDraft] = []
    @State private var photosToDelete: Set<UUID> = []
    @State private var photoToMarkup: FixPhoto?
    @State private var pendingPhotoIndexToMarkup: Int?

    private static let logger = Logger(subsystem: "com.immediac.GottaFixThat", category: "FixItemEdit")

    private static func debugLog(_ message: String) {
#if DEBUG
        logger.info("\(message, privacy: .public)")
#endif
    }

    init(item: FixItem) {
        self.item = item
        _title = State(initialValue: item.title)
        _notes = State(initialValue: item.notes)
        _priority = State(initialValue: item.priority)
        _hasDueDate = State(initialValue: item.dueDate != nil)
        _dueDate = State(initialValue: item.dueDate ?? Date())
        _hasEstimatedTime = State(initialValue: item.estimatedTimeHours != nil)
        _estimatedTimeHours = State(initialValue: item.estimatedTimeHours ?? 1.0)
        _tags = State(initialValue: item.tags)
    }

    var body: some View {
        NavigationStack {
            Form {
                // Title section
                Section("Title") {
                    TextField("Task title", text: $title)
                }

                // Notes section
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }

                // Priority section
                Section("Priority") {
                    Picker("Priority", selection: $priority) {
                        ForEach(FixPriority.allCases, id: \.self) { priority in
                            Text(priority.displayName).tag(priority)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // Due Date section
                Section("Due Date") {
                    Toggle("Set Due Date", isOn: $hasDueDate.animation())

                    if hasDueDate {
                        DatePicker(
                            "Due Date",
                            selection: $dueDate,
                            displayedComponents: [.date]
                        )
                    }
                }

                // Estimated Time section
                Section("Estimated Time") {
                    Toggle("Set Estimated Time", isOn: $hasEstimatedTime.animation())

                    if hasEstimatedTime {
                        HStack {
                            Text("Hours:")
                            Spacer()
                            TextField("Hours", value: $estimatedTimeHours, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                            Stepper("", value: $estimatedTimeHours, in: 0.25...100, step: 0.25)
                                .labelsHidden()
                        }
                    }
                }

                // Tags section
                Section("Tags") {
                    TagEditorView(tags: $tags)
                }

                // Photos section
                Section("Photos") {
                    if !item.photos.isEmpty || !newPhotos.isEmpty {
                        Text("Tap a photo to add or edit markup.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    // Existing photos (not marked for deletion)
                    let existingPhotos = item.photos.filter { !photosToDelete.contains($0.id) }
                    if !existingPhotos.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Current Photos")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            PhotoGridView(
                                photos: existingPhotos,
                                showDeleteButtons: true,
                                onDelete: { photo in
                                    photosToDelete.insert(photo.id)
                                },
                                onTap: { photo in
                                    photoToMarkup = photo
                                }
                            )
                        }
                    }

                    // Pending new photos
                    if !newPhotos.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("New Photos")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            PendingPhotoGridView(
                                images: newPhotos,
                                showDeleteButtons: true,
                                onDelete: { index in
                                    newPhotos.remove(at: index)
                                },
                                onTap: { index in
                                    pendingPhotoIndexToMarkup = index
                                }
                            )
                        }
                    }

                    // Add photos button
                    PhotoPickerButton(selectedImages: $newPhotos)
                }
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        if saveChanges() {
                            dismiss()
                        }
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .sheet(item: $photoToMarkup) { photo in
            if let image = photo.image {
                PhotoMarkupEditor(
                    sourceImage: image,
                    initialDrawingData: photo.annotationData,
                    onSave: { annotatedImage, drawingData in
                        saveMarkup(for: photo, annotatedImage: annotatedImage, drawingData: drawingData)
                    }
                )
            } else {
                Text("Unable to load photo")
            }
        }
        .sheet(isPresented: pendingPhotoMarkupPresented) {
            if let index = pendingPhotoIndexToMarkup,
               newPhotos.indices.contains(index) {
                PhotoMarkupEditor(
                    sourceImage: newPhotos[index].image,
                    initialDrawingData: newPhotos[index].annotationData,
                    onSave: { annotatedImage, drawingData in
                        newPhotos[index].image = annotatedImage
                        newPhotos[index].annotationData = drawingData
                        pendingPhotoIndexToMarkup = nil
                        return true
                    }
                )
            } else {
                Text("Unable to load photo")
            }
        }
        .alert("Save Failed", isPresented: saveErrorPresented) {
            Button("OK", role: .cancel) {
                saveErrorMessage = nil
            }
        } message: {
            Text(saveErrorMessage ?? "Please try again.")
        }
    }

    private func saveChanges() -> Bool {
        item.title = title.trimmingCharacters(in: .whitespaces)
        item.notes = notes
        item.priority = priority
        item.dueDate = hasDueDate ? dueDate : nil
        item.estimatedTimeHours = hasEstimatedTime ? estimatedTimeHours : nil
        item.tags = tags
        item.updatedAt = Date()

        // Delete photos marked for removal
        for photoId in photosToDelete {
            if let photo = item.photos.first(where: { $0.id == photoId }) {
                modelContext.delete(photo)
            }
        }

        // Add new photos
        let currentMaxSortOrder = item.photos.map(\.sortOrder).max() ?? -1
        for (index, draft) in newPhotos.enumerated() {
            if let newPhoto = FixPhoto(
                image: draft.image,
                sortOrder: currentMaxSortOrder + 1 + index,
                item: item
            ) {
                newPhoto.annotationData = draft.annotationData
                modelContext.insert(newPhoto)
            }
        }

        do {
            try modelContext.save()
            Self.debugLog(
                "Saved task changes. itemID=\(item.id.uuidString, privacy: .public) existingPhotoCount=\(item.photos.count) pendingNewPhotoCount=\(newPhotos.count) deletedPhotoCount=\(photosToDelete.count)"
            )
            return true
        } catch {
            Self.logger.error("Failed to save task changes. error=\(String(describing: error), privacy: .public)")
            saveErrorMessage = "The task could not be saved. Your changes are still on screen."
            return false
        }
    }

    private func saveMarkup(for photo: FixPhoto, annotatedImage: UIImage, drawingData: Data?) -> Bool {
        let normalizedImage = annotatedImage.normalizedForStorage()

        Self.debugLog(
            "Starting markup save. photoID=\(photo.id.uuidString, privacy: .public) annotatedPixels=\(Int(annotatedImage.pixelSize.width))x\(Int(annotatedImage.pixelSize.height)) normalizedPixels=\(Int(normalizedImage.pixelSize.width))x\(Int(normalizedImage.pixelSize.height)) approxAnnotatedMemoryMB=\(annotatedImage.approximateMemoryBytes / 1_048_576) drawingBytes=\(drawingData?.count ?? 0)"
        )

        guard let imageData = autoreleasepool(invoking: {
            normalizedImage.compressed(quality: UIImage.storageJPEGQuality)
        }) else {
            Self.logger.error("Failed to compress annotated image for photoID=\(photo.id.uuidString, privacy: .public)")
            saveErrorMessage = "The annotated image could not be prepared for saving."
            return false
        }

        photo.imageData = imageData
        photo.thumbnailData = autoreleasepool(invoking: {
            normalizedImage.thumbnailData(
                maxSize: UIImage.thumbnailMaxDimension,
                quality: UIImage.thumbnailJPEGQuality
            )
        })
        photo.annotationData = drawingData

        do {
            try modelContext.save()
            Self.debugLog(
                "Completed markup save. photoID=\(photo.id.uuidString, privacy: .public) imageBytes=\(imageData.count) thumbnailBytes=\(photo.thumbnailData?.count ?? 0)"
            )
            return true
        } catch {
            Self.logger.error("Failed to persist markup. photoID=\(photo.id.uuidString, privacy: .public) error=\(String(describing: error), privacy: .public)")
            saveErrorMessage = "The markup could not be saved. Please try again."
            return false
        }
    }

    private var pendingPhotoMarkupPresented: Binding<Bool> {
        Binding(
            get: { pendingPhotoIndexToMarkup != nil },
            set: { isPresented in
                if !isPresented {
                    pendingPhotoIndexToMarkup = nil
                }
            }
        )
    }

    private var saveErrorPresented: Binding<Bool> {
        Binding(
            get: { saveErrorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    saveErrorMessage = nil
                }
            }
        )
    }
}

#Preview {
    FixItemEditSheet(item: FixItem(title: "Sample Task", notes: "Some notes here", priority: .medium))
        .modelContainer(for: [FixItem.self, FixPhoto.self], inMemory: true)
}
