//
//  CaptureManager.swift
//  CropImage
//
//  Created by 김성준 on 8/19/24.
//

import SwiftUI

protocol Captureable {
    func captureAndCrop(image: UIImage, size: CGSize, offset: CGSize, rectangleSize: CGSize) async throws -> UIImage
}

struct CaptureManager: Captureable {
    @MainActor
    func captureAndCrop(image: UIImage, size: CGSize, offset: CGSize, rectangleSize: CGSize) async throws -> UIImage {
        let renderer = ImageRenderer(
            content: Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: size.width, height: size.height)
        )
        
        guard let uiImage = renderer.uiImage else {
            throw CaptureError.rendererFailure
        }
        
        return try await Task.detached(priority: .userInitiated) {
            let scale = uiImage.scale
            let cropRect = CGRect(
                x: (size.width / 2 + offset.width - rectangleSize.width / 2) * scale,
                y: (size.height / 2 + offset.height - rectangleSize.height / 2) * scale,
                width: rectangleSize.width * scale,
                height: rectangleSize.height * scale
            )
            
            guard let croppedCGImage = uiImage.cgImage?.cropping(to: cropRect) else {
                throw CaptureError.croppingFailure
            }
            
            return UIImage(cgImage: croppedCGImage, scale: scale, orientation: .up)
        }.value
    }
    
    enum CaptureError: Error {
        case rendererFailure
        case croppingFailure
        
        var localizedDescription: String {
            switch self {
                case .rendererFailure:
                    return NSLocalizedString("Failed to render the image", comment: "")
                case .croppingFailure:
                    return NSLocalizedString("Failed to crop the image", comment: "")
            }
        }
    }
}
