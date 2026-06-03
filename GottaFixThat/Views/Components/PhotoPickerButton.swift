//
//  PhotoPickerButton.swift
//  GottaFixThat
//
//  Created on 2/1/26.
//

import SwiftUI
import PhotosUI
import os

struct PendingPhotoDraft: Identifiable {
    let id: UUID
    var image: UIImage
    var annotationData: Data?

    init(id: UUID = UUID(), image: UIImage, annotationData: Data? = nil) {
        self.id = id
        self.image = image
        self.annotationData = annotationData
    }
}

struct PhotoPickerButton: View {
    @Binding var selectedImages: [PendingPhotoDraft]

    @State private var showingPhotoPicker = false
    @State private var showingCamera = false
    @State private var photoPickerItems: [PhotosPickerItem] = []

    private static let logger = Logger(subsystem: "com.immediac.GottaFixThat", category: "PhotoImport")

    private static func debugLog(_ message: String) {
#if DEBUG
        logger.info("\(message, privacy: .public)")
#endif
    }

    var body: some View {
        Menu {
            Button(action: { showingCamera = true }) {
                Label("Take Photo", systemImage: "camera")
            }

            Button(action: { showingPhotoPicker = true }) {
                Label("Choose from Library", systemImage: "photo.on.rectangle")
            }
        } label: {
            Label("Add Photos", systemImage: "plus.circle.fill")
        }
        .photosPicker(
            isPresented: $showingPhotoPicker,
            selection: $photoPickerItems,
            maxSelectionCount: 10,
            matching: .images
        )
        .onChange(of: photoPickerItems) { _, newItems in
            Task {
                await loadSelectedPhotos(from: newItems)
                photoPickerItems = []
            }
        }
        .fullScreenCover(isPresented: $showingCamera) {
            CameraView { image in
                if let image = image {
                    let normalizedImage = image.normalizedForStorage()
                    Self.debugLog(
                        "Imported camera photo. sourcePixels=\(Int(image.pixelSize.width))x\(Int(image.pixelSize.height)) normalizedPixels=\(Int(normalizedImage.pixelSize.width))x\(Int(normalizedImage.pixelSize.height))"
                    )
                    selectedImages.append(PendingPhotoDraft(image: normalizedImage))
                }
            }
        }
    }

    private func loadSelectedPhotos(from items: [PhotosPickerItem]) async {
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                let normalizedImage = image.normalizedForStorage()
                Self.debugLog(
                    "Imported library photo. sourcePixels=\(Int(image.pixelSize.width))x\(Int(image.pixelSize.height)) normalizedPixels=\(Int(normalizedImage.pixelSize.width))x\(Int(normalizedImage.pixelSize.height))"
                )
                await MainActor.run {
                    selectedImages.append(PendingPhotoDraft(image: normalizedImage))
                }
            }
        }
    }
}

/// UIImagePickerController wrapper for camera access
struct CameraView: UIViewControllerRepresentable {
    let onImageCaptured: (UIImage?) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onImageCaptured: onImageCaptured)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onImageCaptured: (UIImage?) -> Void

        init(onImageCaptured: @escaping (UIImage?) -> Void) {
            self.onImageCaptured = onImageCaptured
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            let image = info[.originalImage] as? UIImage
            onImageCaptured(image)
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            onImageCaptured(nil)
            picker.dismiss(animated: true)
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var images: [PendingPhotoDraft] = []

        var body: some View {
            VStack {
                PhotoPickerButton(selectedImages: $images)
                Text("Selected: \(images.count) photos")
            }
        }
    }

    return PreviewWrapper()
}
