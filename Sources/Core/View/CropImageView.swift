//
//  CropImageView.swift
//  CropImage
//
//  Created by 김성준 on 8/19/24.
//

import SwiftUI

@available(iOS 17.0, *)
public struct CropImageView: View {
    @StateObject private var viewModel: CropViewModel = CropViewModel()
    @Binding public var croppedImage: UIImage
    @State private var originImage: UIImage
    @State private var selectedAspectRatio: AspectRatio = .free
    @State private var maxSize: CGSize = .zero
    @State private var offset: CGSize = .zero
    @State private var initialOffset: CGSize = .zero
    @State private var rectangleSize: CGSize = CGSize(width: 150, height: 150)
    @State private var rectangleinitialSize: CGSize = CGSize(width: 150, height: 150)
    
    public init(originImage: UIImage, croppedImage: Binding<UIImage>) {
        self.originImage = originImage
        self._croppedImage = croppedImage
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                cropImageLayer(geometry: geometry)
                cropMaskLayer(geometry: geometry)
                draggableRectangleLayer
                controlsLayer(geometry: geometry)
            }
            .alert("Alert", isPresented: $viewModel.isCompleteTask) {
                Button("Confirm", action: {})
            } message: {
                Text(viewModel.errorMessage.localizedDescription)
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
            rectangleinitialSize: $rectangleinitialSize,
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
            NavigationCheckButton(color: .accentColor) {
                Task {
                    if let image = await viewModel.captureAndCrop(image: originImage, geometry: geometry, offset: offset, rectangleSize: rectangleSize) {
                        DispatchQueue.main.async {
                            croppedImage = image
                        }
                    }
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
        Color.black.opacity(0.5)
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
        rectangleSize = CGSize(width: 150, height: 150)
        rectangleinitialSize = CGSize(width: 150, height: 150)
    }
    
    private func updateRectangleSize(imageSize: CGSize) {
        rectangleSize = calculateNewSize(for: selectedAspectRatio, imageSize: imageSize)
        rectangleinitialSize = rectangleSize
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
