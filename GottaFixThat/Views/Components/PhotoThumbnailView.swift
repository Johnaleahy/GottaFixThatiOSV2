//
//  PhotoThumbnailView.swift
//  GottaFixThat
//
//  Created on 2/1/26.
//

import SwiftUI

struct PhotoThumbnailView: View {
    let image: UIImage?
    var size: CGFloat = 80
    var isCircular: Bool = false
    var showDeleteButton: Bool = false
    var onDelete: (() -> Void)?

    private var clipShape: AnyShape {
        isCircular ? AnyShape(Circle()) : AnyShape(RoundedRectangle(cornerRadius: 8))
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Group {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Color.greenLight
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundStyle(Color.greenAccent)
                        }
                }
            }
            .frame(width: size, height: size)
            .clipShape(clipShape)

            // Delete button overlay
            if showDeleteButton {
                Button(action: { onDelete?() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(.white, .red)
                        .shadow(radius: 2)
                }
                .offset(x: 6, y: -6)
            }
        }
    }
}

#Preview("With Image") {
    PhotoThumbnailView(
        image: UIImage(systemName: "photo.fill"),
        showDeleteButton: true,
        onDelete: {}
    )
    .padding()
}

#Preview("Placeholder") {
    PhotoThumbnailView(image: nil)
        .padding()
}
