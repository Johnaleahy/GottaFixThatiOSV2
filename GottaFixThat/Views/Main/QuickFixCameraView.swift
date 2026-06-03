//
//  QuickFixCameraView.swift
//  GottaFixThat
//
//  Created on 2026-04-29.
//

import SwiftUI
import SwiftData
import UIKit
import os

struct QuickFixCameraView: View {
    private static let logger = Logger(subsystem: "com.immediac.GottaFixThat", category: "QuickFixCamera")

    private static func debugLog(_ message: String) {
#if DEBUG
        logger.info("\(message, privacy: .public)")
#endif
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FixList.name) private var allLists: [FixList]

    @State private var capturedImage: UIImage?
    @State private var showingCamera = true
    @State private var taskTitle = ""
    @State private var selectedList: FixList?

    private var trimmedTitle: String {
        taskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canSave: Bool {
        !trimmedTitle.isEmpty && selectedList != nil && capturedImage != nil
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.grayLight.ignoresSafeArea()

                if capturedImage != nil {
                    formView
                } else {
                    emptyState
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Quick Fix")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.blueDark)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.blueDark)
                }
            }
        }
        .fullScreenCover(isPresented: $showingCamera) {
            CameraView { image in
                if let image {
                    let normalizedImage = image.normalizedForStorage()
                    Self.debugLog(
                        "Captured quick-fix photo. sourcePixels=\(Int(image.pixelSize.width))x\(Int(image.pixelSize.height)) normalizedPixels=\(Int(normalizedImage.pixelSize.width))x\(Int(normalizedImage.pixelSize.height))"
                    )
                    capturedImage = normalizedImage
                } else {
                    capturedImage = nil
                }

                if image == nil {
                    dismiss()
                }
            }
            .ignoresSafeArea()
        }
    }

    // MARK: - Form

    private var formView: some View {
        ScrollView {
            VStack(spacing: 20) {
                photoCard
                titleCard
                listCard
                saveButton
            }
            .padding()
        }
    }

    private var photoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            cardLabel("PHOTO")

            ZStack(alignment: .topTrailing) {
                if let image = capturedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 220)
                        .clipped()
                        .cornerRadius(12)
                }

                Button(action: { showingCamera = true }) {
                    Image(systemName: "arrow.triangle.2.circlepath.camera.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.blueDark)
                        .padding(10)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
                .padding(10)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.15), radius: 4, x: 0, y: 2)
    }

    private var titleCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            cardLabel("TASK NAME")

            TextField("What needs fixing?", text: $taskTitle)
                .font(.system(size: 17))
                .foregroundColor(.grayDark)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color.grayLight)
                .cornerRadius(10)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.15), radius: 4, x: 0, y: 2)
    }

    private var listCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            cardLabel("ADD TO LIST")

            if allLists.isEmpty {
                Text("No lists yet. Create a property and list before adding a quick fix.")
                    .font(.system(size: 14))
                    .foregroundColor(.grayDark)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 0) {
                    ForEach(allLists) { list in
                        Button(action: { selectedList = list }) {
                            listRow(for: list)
                        }
                        .buttonStyle(PlainButtonStyle())

                        if list != allLists.last {
                            Divider().padding(.leading, 44)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.15), radius: 4, x: 0, y: 2)
    }

    private func listRow(for list: FixList) -> some View {
        let isSelected = selectedList == list
        return HStack(spacing: 12) {
            Image(systemName: list.iconName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isSelected ? .greenAccent : .blueMedium)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(list.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.grayDark)

                if let propertyName = list.property?.name {
                    Text(propertyName)
                        .font(.system(size: 12))
                        .foregroundColor(.grayMedium)
                }
            }

            Spacer()

            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 20))
                .foregroundColor(isSelected ? .greenAccent : .grayMedium)
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }

    private var saveButton: some View {
        Button(action: save) {
            Text("ADD FIX")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(canSave ? Color.greenAccent : Color.grayMedium)
                .cornerRadius(12)
        }
        .disabled(!canSave)
        .padding(.top, 4)
    }

    private func cardLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.grayMedium)
            .tracking(1)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.fill")
                .font(.system(size: 48))
                .foregroundColor(.grayMedium)
            Text("Opening camera…")
                .font(.system(size: 16))
                .foregroundColor(.grayDark)
        }
    }

    // MARK: - Save

    private func save() {
        guard let image = capturedImage,
              let list = selectedList,
              !trimmedTitle.isEmpty else { return }

        let newItem = FixItem(
            title: trimmedTitle,
            priority: .medium,
            list: list,
            sortOrder: list.items.count
        )
        modelContext.insert(newItem)

        if let photo = FixPhoto(image: image, sortOrder: 0, item: newItem) {
            modelContext.insert(photo)
        }

        do {
            try modelContext.save()
            Self.debugLog("Saved quick-fix item. itemID=\(newItem.id.uuidString, privacy: .public)")
        } catch {
            Self.logger.error("Failed to save quick-fix item. error=\(String(describing: error), privacy: .public)")
        }
        dismiss()
    }
}

#Preview {
    QuickFixCameraView()
        .modelContainer(for: [User.self, Property.self, FixList.self, FixItem.self, FixPhoto.self], inMemory: true)
}
