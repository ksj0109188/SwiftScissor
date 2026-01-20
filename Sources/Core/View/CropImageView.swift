//
//  CropImageView.swift
//  CropImage
//
//  Created by 김성준 on 8/19/24.
//

import SwiftUI

/// CropImageView is the core view of SwiftScissor.
/// It provides image cropping functionality in a SwiftUI-compatible format.
///
/// - Available as a SwiftUI view
/// - Allows users to interactively crop images
/// - Supports custom aspect ratios and free-form cropping
/// - Returns the cropped image through a completion handler
@available(iOS 17.0, *)
public struct CropImageView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceTransparency) var reduceTransparency
    @StateObject private var viewModel: CropViewModel = CropViewModel()
    @State private var originImage: UIImage
    @State private var selectedAspectRatio: AspectRatio = .free
    @State private var maxSize: CGSize = .zero
    @State private var offset: CGSize = .zero
    @State private var initialOffset: CGSize = .zero
    @State private var rectangleSize: CGSize = CGSize(
        width: CropConstants.defaultRectangleSize,
        height: CropConstants.defaultRectangleSize
    )
    @State private var rectangleInitialSize: CGSize = CGSize(
        width: CropConstants.defaultRectangleSize,
        height: CropConstants.defaultRectangleSize
    )
    
    private let onCrop: (UIImage?) -> Void
    
    /// - Parameters:
    ///   - originImage: The UIImage to be used in the crop view for cropping.
    ///   - onCrop: A closure that will be executed when the cropping is completed (i.e., when the check button is tapped).
    ///             This closure takes an optional UIImage as its parameter, which will be the cropped image if successful, or nil if cropping fails.
    ///
    /// - Note: The `onCrop` closure is called with the cropped image when the user confirms the crop by tapping the check button.
    ///         If cropping fails for any reason, the closure will be called with `nil`.
    public init(originImage: UIImage, onCrop: @escaping (UIImage?) -> Void) {
        self.originImage = originImage
        self.onCrop = onCrop
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                cropImageLayer(geometry: geometry)
                cropMaskLayer(geometry: geometry)
                draggableRectangleLayer
                controlsLayer(geometry: geometry)
            }
            .alert("Crop Result", isPresented: $viewModel.isCompleteTask) {
                Button("OK", action: { dismiss() })
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error.localizedDescription)
                } else {
                    Text("Image cropped successfully")
                }
            }
            .onAppear { updateMaxSize(geometrySize: geometry.size) }
            .onChange(of: geometry.size) { _, newValue in
                resetCropView()
                updateMaxSize(geometrySize: newValue)
            }
        }
        .padding()
    }
    
    private var draggableRectangleLayer: some View {
        DraggableRectangleView(
            offset: $offset,
            initialOffset: $initialOffset,
            rectangleSize: $rectangleSize,
            rectangleInitialSize: $rectangleInitialSize,
            maxSize: $maxSize
        )
    }
    
    private func controlsLayer(geometry: GeometryProxy) -> some View {
        VStack {
            Spacer()
            aspectRatioControls
            cropControls(geometry: geometry)
        }
    }
    
    private var aspectRatioControls: some View {
        AspectRatioButtonGroup(selectedRatio: $selectedAspectRatio) {
            updateRectangleSize(imageSize: maxSize)
        }
        .padding()
    }
    
    private func cropControls(geometry: GeometryProxy) -> some View {
        HStack {
            NavigationBackButton(buttonType: .xmark, color: .accentColor, action: {})
            Spacer()
            Text("Crop").font(.subheadline)
            Spacer()
            NavigationCheckButton(color: .accentColor) { [weak viewModel, onCrop] in
                guard let viewModel = viewModel else { return }
                Task { @MainActor in
                    let image = await viewModel.captureAndCrop(
                        image: originImage,
                        geometry: geometry,
                        offset: offset,
                        rectangleSize: rectangleSize
                    )
                    onCrop(image)
                }
            }
        }
        .padding(.bottom)
    }
    
    private func cropImageLayer(geometry: GeometryProxy) -> some View {
        Group {
            Image(uiImage: originImage)
                .resizable()
                .scaledToFit()
                .frame(width: geometry.size.width, height: geometry.size.height)
                .ignoresSafeArea(.all)
        }
    }
    
    private func cropMaskLayer(geometry: GeometryProxy) -> some View {
        Color.black.opacity(CropConstants.maskOpacity)
            .frame(width: maxSize.width, height: maxSize.height)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            .mask(
                Rectangle()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .overlay(
                        Rectangle()
                            .frame(width: rectangleSize.width, height: rectangleSize.height)
                            .offset(x: offset.width, y: offset.height)
                            .blendMode(.destinationOut)
                    )
            )
    }
    
    private func updateMaxSize(geometrySize: CGSize) {
        let imageSize = originImage.size
        let scale = min(geometrySize.width / imageSize.width, geometrySize.height / imageSize.height)
        maxSize = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
    }
    
    private func resetCropView() {
        offset = .zero
        initialOffset = .zero
        rectangleSize = CGSize(
            width: CropConstants.defaultRectangleSize,
            height: CropConstants.defaultRectangleSize
        )
        rectangleInitialSize = CGSize(
            width: CropConstants.defaultRectangleSize,
            height: CropConstants.defaultRectangleSize
        )
    }
    
    private func updateRectangleSize(imageSize: CGSize) {
        rectangleSize = calculateNewSize(for: selectedAspectRatio, imageSize: imageSize)
        rectangleInitialSize = rectangleSize
        centerRectangle()
    }
    
    private func calculateNewSize(for aspectRatio: AspectRatio, imageSize: CGSize) -> CGSize {
        guard let ratio = aspectRatio.ratio else { return rectangleSize }
        
        var newWidth = imageSize.width
        var newHeight = newWidth / ratio
        
        if newHeight > imageSize.height {
            newHeight = imageSize.height
            newWidth = newHeight * ratio
        }
        
        return CGSize(width: newWidth, height: newHeight)
    }
    
    private func centerRectangle() {
        offset = .zero
        initialOffset = .zero
    }
}

// MARK: - Previews
@available(iOS 17.0, *)
#Preview("Light Mode") {
    CropImageView(
        originImage: PreviewHelper.createSampleImage(
            width: 800,
            height: 600,
            colors: [.blue, .purple, .pink]
        )
    ) { croppedImage in
        print("Cropped image: \(croppedImage?.size.debugDescription ?? "nil")")
    }
}

@available(iOS 17.0, *)
#Preview("Portrait Image") {
    CropImageView(
        originImage: PreviewHelper.createSampleImage(
            width: 600,
            height: 900,
            colors: [.orange, .red, .yellow]
        )
    ) { croppedImage in
        print("Cropped image: \(croppedImage?.size.debugDescription ?? "nil")")
    }
}

@available(iOS 17.0, *)
#Preview("Square Image") {
    CropImageView(
        originImage: PreviewHelper.createSampleImage(
            width: 800,
            height: 800,
            colors: [.green, .teal, .cyan]
        )
    ) { croppedImage in
        print("Cropped image: \(croppedImage?.size.debugDescription ?? "nil")")
    }
    .preferredColorScheme(.dark)
}

// MARK: - Preview Helper
@available(iOS 17.0, *)
private enum PreviewHelper {
    static func createSampleImage(width: CGFloat, height: CGFloat, colors: [Color]) -> UIImage {
        let size = CGSize(width: width, height: height)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            // Create gradient background
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors.map { UIColor($0).cgColor } as CFArray,
                locations: nil
            )!

            context.cgContext.drawLinearGradient(
                gradient,
                start: .zero,
                end: CGPoint(x: width, y: height),
                options: []
            )

            // Add some geometric shapes for visual interest
            UIColor.white.withAlphaComponent(0.3).setFill()

            let circlePath = UIBezierPath(
                arcCenter: CGPoint(x: width * 0.3, y: height * 0.3),
                radius: min(width, height) * 0.15,
                startAngle: 0,
                endAngle: .pi * 2,
                clockwise: true
            )
            circlePath.fill()

            let rectPath = UIBezierPath(
                rect: CGRect(
                    x: width * 0.6,
                    y: height * 0.6,
                    width: width * 0.25,
                    height: height * 0.25
                )
            )
            rectPath.fill()

            // Add text
            let text = "SAMPLE"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: min(width, height) * 0.1, weight: .bold),
                .foregroundColor: UIColor.white.withAlphaComponent(0.5)
            ]

            let textSize = text.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (width - textSize.width) / 2,
                y: (height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            text.draw(in: textRect, withAttributes: attributes)
        }
    }
}

