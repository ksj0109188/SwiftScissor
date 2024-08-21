//
//  CropViewModel.swift
//  CropImage
//
//  Created by 김성준 on 8/19/24.
//

import SwiftUI
import CoreImage
import Combine

final class CropViewModel: ObservableObject, ErrorHandling {
    @Published var isCompleteTask: Bool = false
    @Published var errorMessage: LocalizedError = ErrorMessage.none
    
    let captureManager: Captureable
    
    init(captureManager: Captureable = CaptureManager()) {
        self.captureManager = captureManager
    }
    
    func captureAndCrop(image: UIImage, geometry: GeometryProxy, offset: CGSize, rectangleSize: CGSize) async -> UIImage? {
        let newImage: UIImage?
        isCompleteTask = false
        
        do {
            newImage = try await captureManager.captureAndCrop(
                image: image,
                size: geometry.size,
                offset: offset,
                rectangleSize: rectangleSize
            )
            errorMessage = ErrorMessage.none
        } catch {
            newImage = nil
            errorMessage = ErrorMessage.captureFailed
        }
        
        isCompleteTask = true
        
        return newImage
    }
    
    enum ErrorMessage: LocalizedError {
        case none
        case captureFailed
        
        var errorDescription: String? {
            switch self {
                case .none:
                    return NSLocalizedString("Capture success", comment: "")
                case .captureFailed:
                    return NSLocalizedString("Capture fail", comment: "")
            }
        }
    }
}

