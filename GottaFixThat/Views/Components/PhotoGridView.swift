//
//  PhotoGridView.swift
//  GottaFixThat
//
//  Created on 2/1/26.
//

import SwiftUI

struct PhotoGridView: View {
    let photos: [FixPhoto]
    var thumbnailSize: CGFloat = 80
    var showDeleteButtons: Bool = true
    var onDelete: ((FixPhoto) -> Void)?
    var onTap: ((FixPhoto) -> Void)?

    private let columns = [
        GridItem(.adaptive(minimum: 80, maximum: 100), spacing: 8)
    ]

    private var sortedPhotos: [FixPhoto] {
        photos.sorted { $0.sortOrder < $1.sortOrder }
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(sortedPhotos, id: \.id) { photo in
                PhotoThumbnailView(
                    image: photo.thumbnailImage,
                    size: thumbnailSize,
                    showDeleteButton: showDeleteButtons,
                    onDelete: { onDelete?(photo) }
                )
                .onTapGesture {
                    onTap?(photo)
                }
            }
        }
    }
}

/// Grid view for displaying pending UIImages (not yet saved as FixPhoto)
struct PendingPhotoGridView: View {
    let images: [PendingPhotoDraft]
    var thumbnailSize: CGFloat = 80
    var showDeleteButtons: Bool = true
    var onDelete: ((Int) -> Void)?
    var onTap: ((Int) -> Void)?

    private let columns = [
        GridItem(.adaptive(minimum: 80, maximum: 100), spacing: 8)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(Array(images.enumerated()), id: \.element.id) { index, draft in
                PhotoThumbnailView(
                    image: draft.image,
                    size: thumbnailSize,
                    showDeleteButton: showDeleteButtons,
                    onDelete: { onDelete?(index) }
                )
                .onTapGesture {
                    onTap?(index)
                }
            }
        }
    }
}

#Preview {
    VStack {
        Text("Pending Photos")
            .font(.headline)
        PendingPhotoGridView(
            images: [
                PendingPhotoDraft(image: UIImage(systemName: "photo.fill")!),
                PendingPhotoDraft(image: UIImage(systemName: "camera.fill")!)
            ],
            onDelete: { _ in }
        )
    }
    .padding()
}
