//
//  CropViewModel.swift
//  CropImage
//
//  Created by 김성준 on 8/19/24.
//

import SwiftUI
import CoreImage
import Combine

@MainActor
final class CropViewModel: ObservableObject, ErrorHandling {
    @Published var isError: Bool = false
    @Published var cropBoardImage: UIImage?
    @Published var errorMessage: LocalizedError = ErrorMessage.none
    
    let captureManager: Captureable

    init(captureManager: Captureable = CaptureManager()) {
        self.captureManager = captureManager
    }
    
    func captureAndCrop(image: UIImage, geometry: GeometryProxy, offset: CGSize, rectangleSize: CGSize) async {
        do {
            let newImage = try await captureManager.captureAndCrop(
                image: image,
                size: geometry.size,
                offset: offset,
                rectangleSize: rectangleSize
            )
            isError = false
            errorMessage = ErrorMessage.none
        } catch {
            isError = true
            errorMessage = ErrorMessage.captureFailed
        }
    }
    
    enum ErrorMessage: LocalizedError {
        case none
        case captureFailed
        
        var errorDescription: String? {
            switch self {
                case .none:
                    return nil
                case .captureFailed:
                    return NSLocalizedString("Capture fail", comment: "")
            }
        }
    }
}

