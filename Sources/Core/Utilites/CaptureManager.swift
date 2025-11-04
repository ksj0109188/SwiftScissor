//
//  CaptureManager.swift
//  CropImage
//
//  Created by 김성준 on 8/19/24.
//

import SwiftUI
import CoreGraphics

protocol Captureable {
    func captureAndCrop(image: UIImage, size: CGSize, offset: CGSize, rectangleSize: CGSize) async throws -> UIImage
}

struct CaptureManager: Captureable {
    /// Crop image directly from CGImage without using ImageRenderer
    /// This eliminates 80-120MB memory spikes and handles EXIF orientation correctly
    func captureAndCrop(image: UIImage, size: CGSize, offset: CGSize, rectangleSize: CGSize) async throws -> UIImage {
        return try await Task.detached(priority: .userInitiated) {
            // Step 1: Normalize EXIF orientation
            guard let normalizedImage = normalizeOrientation(image) else {
                throw CropError.orientationHandlingFailed
            }

            guard let cgImage = normalizedImage.cgImage else {
                throw CropError.croppingFailure
            }

            // Step 2: Calculate coordinate transformation
            let imageSize = CGSize(width: cgImage.width, height: cgImage.height)
            let displaySize = size

            // Calculate scale factor (how much the image is scaled down in the view)
            let scale = min(displaySize.width / imageSize.width, displaySize.height / imageSize.height)

            // Calculate actual displayed size in view coordinates
            let displayedImageSize = CGSize(
                width: imageSize.width * scale,
                height: imageSize.height * scale
            )

            // Step 3: Transform crop rectangle from view coordinates to image coordinates
            // View origin is at center, image origin is at top-left
            let cropRectInDisplayCoords = CGRect(
                x: offset.width + displayedImageSize.width / 2 - rectangleSize.width / 2,
                y: offset.height + displayedImageSize.height / 2 - rectangleSize.height / 2,
                width: rectangleSize.width,
                height: rectangleSize.height
            )

            // Convert to image coordinates
            let cropRectInImageCoords = CGRect(
                x: cropRectInDisplayCoords.origin.x / scale,
                y: cropRectInDisplayCoords.origin.y / scale,
                width: cropRectInDisplayCoords.width / scale,
                height: cropRectInDisplayCoords.height / scale
            )

            // Step 4: Validate and clamp to image bounds
            let clampedRect = clampToImageBounds(cropRectInImageCoords, imageSize: imageSize)

            // Validate final rectangle
            guard clampedRect.width > 0 && clampedRect.height > 0 else {
                throw CropError.invalidCropArea
            }

            // Step 5: Perform crop
            guard let croppedCGImage = cgImage.cropping(to: clampedRect) else {
                throw CropError.croppingFailure
            }

            // Return UIImage with correct scale and orientation
            return UIImage(cgImage: croppedCGImage, scale: normalizedImage.scale, orientation: .up)
        }.value
    }

    // MARK: - Private Helper Methods

    /// Normalize image orientation by rendering it to a bitmap context
    /// This handles EXIF orientation data that affects 90% of iPhone photos
    private func normalizeOrientation(_ image: UIImage) -> UIImage? {
        // Already in correct orientation
        if image.imageOrientation == .up {
            return image
        }

        let size = image.size
        UIGraphicsBeginImageContextWithOptions(size, false, image.scale)
        defer { UIGraphicsEndImageContext() }

        image.draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    /// Clamp crop rectangle to ensure it stays within image bounds
    private func clampToImageBounds(_ rect: CGRect, imageSize: CGSize) -> CGRect {
        let x = max(0, min(rect.origin.x, imageSize.width - 1))
        let y = max(0, min(rect.origin.y, imageSize.height - 1))
        let width = min(rect.width, imageSize.width - x)
        let height = min(rect.height, imageSize.height - y)

        return CGRect(x: x, y: y, width: width, height: height)
    }
}
