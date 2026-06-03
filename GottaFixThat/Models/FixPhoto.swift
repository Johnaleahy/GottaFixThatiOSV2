//
//  FixPhoto.swift
//  GottaFixThat
//
//  Created on 1/20/26.
//

import SwiftData
import Foundation
import UIKit
import os

@Model
final class FixPhoto {
    private static let logger = Logger(subsystem: "com.immediac.GottaFixThat", category: "FixPhoto")

    private static func debugLog(_ message: String) {
#if DEBUG
        logger.info("\(message, privacy: .public)")
#endif
    }

    // MARK: - Properties
    var id: UUID
    var imageData: Data
    var thumbnailData: Data?
    var caption: String
    var annotationData: Data? // For storing drawing annotations as JSON
    var createdAt: Date
    var sortOrder: Int

    // MARK: - Relationships
    var item: FixItem?

    // MARK: - Initialization
    init(
        imageData: Data,
        thumbnailData: Data? = nil,
        caption: String = "",
        sortOrder: Int = 0,
        item: FixItem? = nil
    ) {
        self.id = UUID()
        self.imageData = imageData
        self.thumbnailData = thumbnailData
        self.caption = caption
        self.annotationData = nil
        self.createdAt = Date()
        self.sortOrder = sortOrder
        self.item = item
    }

    // MARK: - Computed Properties

    /// Returns the full-size image from imageData
    var image: UIImage? {
        UIImage(data: imageData)
    }

    /// Returns the thumbnail image, or generates one from the main image if not available
    var thumbnailImage: UIImage? {
        if let thumbnailData = thumbnailData {
            return UIImage(data: thumbnailData)
        }
        return image?.thumbnail(maxSize: 200)
    }

    // MARK: - Convenience Initializer

    /// Creates a FixPhoto from a UIImage, automatically generating thumbnail
    /// - Parameters:
    ///   - image: The source UIImage
    ///   - caption: Optional caption for the photo
    ///   - sortOrder: Display order within the item
    ///   - item: The FixItem this photo belongs to
    convenience init?(
        image: UIImage,
        caption: String = "",
        sortOrder: Int = 0,
        item: FixItem? = nil
    ) {
        let normalizedImage = image.normalizedForStorage()

        Self.debugLog(
            "Creating FixPhoto. sourcePixels=\(Int(image.pixelSize.width))x\(Int(image.pixelSize.height)) normalizedPixels=\(Int(normalizedImage.pixelSize.width))x\(Int(normalizedImage.pixelSize.height))"
        )

        guard let imageData = normalizedImage.compressed(quality: UIImage.storageJPEGQuality) else {
            return nil
        }

        let thumbnailData = normalizedImage.thumbnailData(
            maxSize: UIImage.thumbnailMaxDimension,
            quality: UIImage.thumbnailJPEGQuality
        )

        self.init(
            imageData: imageData,
            thumbnailData: thumbnailData,
            caption: caption,
            sortOrder: sortOrder,
            item: item
        )
    }

    // MARK: - Methods

    /// Regenerates the thumbnail from the main image data
    func generateThumbnail() {
        guard let image = UIImage(data: imageData) else { return }
        thumbnailData = image.thumbnailData(
            maxSize: UIImage.thumbnailMaxDimension,
            quality: UIImage.thumbnailJPEGQuality
        )
    }
}
