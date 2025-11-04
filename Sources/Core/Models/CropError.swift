//
//  CropError.swift
//  SwiftScissor
//
//  Created by Claude on 10/30/25.
//

import Foundation

/// Errors that can occur during image cropping
enum CropError: LocalizedError {
    case rendererFailure
    case croppingFailure
    case invalidCropArea
    case orientationHandlingFailed

    var errorDescription: String? {
        switch self {
        case .rendererFailure:
            return NSLocalizedString(
                "crop.error.renderer",
                value: "Failed to render the image",
                comment: "Error when ImageRenderer fails"
            )
        case .croppingFailure:
            return NSLocalizedString(
                "crop.error.cropping",
                value: "Failed to crop the image",
                comment: "Error when CGImage cropping fails"
            )
        case .invalidCropArea:
            return NSLocalizedString(
                "crop.error.invalidArea",
                value: "Invalid crop area selected",
                comment: "Error when crop area is invalid"
            )
        case .orientationHandlingFailed:
            return NSLocalizedString(
                "crop.error.orientation",
                value: "Failed to normalize image orientation",
                comment: "Error when EXIF orientation handling fails"
            )
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .rendererFailure:
            return "Try with a different image or restart the app"
        case .croppingFailure:
            return "Adjust the crop area and try again"
        case .invalidCropArea:
            return "Please select a valid crop area within the image bounds"
        case .orientationHandlingFailed:
            return "The image orientation could not be processed. Try with a different image"
        }
    }
}
