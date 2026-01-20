//
//  CropViewModel.swift
//  CropImage
//
//  Created by 김성준 on 8/19/24.
//

import SwiftUI
import CoreImage
import Combine

@available(iOS 17.0, macOS 14.0, *)
final class CropViewModel: ObservableObject, ErrorHandling {
    @Published var isCompleteTask: Bool = false
    @Published var errorMessage: CropError?
    
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
            errorMessage = nil
        } catch let error as CropError {
            newImage = nil
            errorMessage = error
        } catch {
            newImage = nil
            errorMessage = .croppingFailure
        }

        isCompleteTask = true

        return newImage
    }
}

