//
//  UIImage+Thumbnail.swift
//  GottaFixThat
//
//  Created on 2/1/26.
//

import UIKit

extension UIImage {
    static let storageMaxDimension: CGFloat = 2_048
    static let thumbnailMaxDimension: CGFloat = 200
    static let storageJPEGQuality: CGFloat = 0.8
    static let thumbnailJPEGQuality: CGFloat = 0.7

    var pixelSize: CGSize {
        if let cgImage {
            return CGSize(width: cgImage.width, height: cgImage.height)
        }

        return CGSize(width: size.width * scale, height: size.height * scale)
    }

    var approximateMemoryBytes: Int {
        let pixels = pixelSize
        return Int(pixels.width * pixels.height * 4)
    }

    func scaledToFit(maxDimension: CGFloat) -> UIImage {
        let pixels = pixelSize
        let currentMaxDimension = max(pixels.width, pixels.height)

        guard currentMaxDimension > maxDimension, currentMaxDimension > 0 else {
            return self
        }

        let scaleFactor = maxDimension / currentMaxDimension
        let targetSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1

        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }

    func normalizedForStorage(maxDimension: CGFloat = UIImage.storageMaxDimension) -> UIImage {
        scaledToFit(maxDimension: maxDimension)
    }

    /// Creates a thumbnail image with the specified maximum dimension
    /// - Parameter maxSize: The maximum width or height for the thumbnail
    /// - Returns: A resized UIImage maintaining aspect ratio
    func thumbnail(maxSize: CGFloat) -> UIImage {
        let aspectRatio = size.width / size.height

        var newSize: CGSize
        if size.width > size.height {
            newSize = CGSize(width: maxSize, height: maxSize / aspectRatio)
        } else {
            newSize = CGSize(width: maxSize * aspectRatio, height: maxSize)
        }

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    /// Compresses the image to JPEG data with the specified quality
    /// - Parameter quality: Compression quality from 0.0 (max compression) to 1.0 (no compression)
    /// - Returns: Compressed JPEG data, or nil if compression fails
    func compressed(quality: CGFloat) -> Data? {
        return jpegData(compressionQuality: quality)
    }

    /// Creates thumbnail data suitable for storage
    /// - Parameters:
    ///   - maxSize: Maximum dimension for the thumbnail
    ///   - quality: JPEG compression quality
    /// - Returns: Compressed thumbnail data
    func thumbnailData(maxSize: CGFloat = 200, quality: CGFloat = 0.7) -> Data? {
        return thumbnail(maxSize: maxSize).compressed(quality: quality)
    }
}
