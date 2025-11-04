//
//  DraggableRectangleView.swift
//  CropImage
//
//  Created by 김성준 on 8/19/24.
//

import SwiftUI

@available(iOS 17.0, macOS 14.0, *)
struct DraggableRectangleView: View {
    @Binding var offset: CGSize
    @Binding var initialOffset: CGSize
    @Binding var rectangleSize: CGSize
    @Binding var rectangleInitialSize: CGSize
    @Binding var maxSize: CGSize
    @State private var isDragging = false
    
    var body: some View {
        ZStack {
            draggableArea
            rectangleBorder
            cornerHandles
        }
    }
    
    private var draggableArea: some View {
        Rectangle()
            .fill(Color.clear)
            .contentShape(Rectangle())
            .frame(width: rectangleSize.width, height: rectangleSize.height)
            .offset(x: offset.width, y: offset.height)
            .gesture(dragGesture)
            .overlay {
                if isDragging {
                    gridLines
                }
            }
    }
    
    private var rectangleBorder: some View {
        Rectangle()
            .strokeBorder(lineWidth: CropConstants.photosBorderWidth)
            .foregroundColor(.white)
            .frame(width: rectangleSize.width, height: rectangleSize.height)
            .offset(x: offset.width, y: offset.height)
    }
    
    private var cornerHandles: some View {
        ForEach(Corner.allCases, id: \.self) { corner in
            PhotosStyleCornerHandle(corner: mapToPhotosCorner(corner))
                .offset(cornerPosition(for: corner.point, offset: offset))
                .gesture(resizeGesture(for: corner.point))
        }
    }
    
    private var gridLines: some View {
        Path { path in
            for i in 1...2 {
                let x = rectangleSize.width / 3 * CGFloat(i)
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: rectangleSize.height))
            }
            
            for i in 1...2 {
                let y = rectangleSize.height / 3 * CGFloat(i)
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: rectangleSize.width, y: y))
            }
        }
        .offset(x: offset.width, y: offset.height)
        .stroke(Color.white.opacity(CropConstants.gridLineOpacity), lineWidth: CropConstants.gridLineWidth)
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                var newOffset = initialOffset + value.translation
                newOffset = limitOffset(newOffset)
                offset = newOffset
                isDragging = true
            }
            .onEnded { _ in
                initialOffset = offset
                isDragging = false
            }
    }
    
    private func resizeGesture(for point: CGPoint) -> some Gesture {
        DragGesture()
            .onChanged { value in
                let delta = calculateDelta(for: point, translation: value.translation)
                let (newSize, newOffset) = calculateNewSizeAndOffset(delta: delta, point: point)
                rectangleSize = newSize
                offset = newOffset
                isDragging = true
            }
            .onEnded { _ in
                rectangleInitialSize = rectangleSize
                isDragging = false
            }
    }
    
    private func cornerPosition(for point: CGPoint, offset: CGSize) -> CGSize {
        CGSize(
            width: (point.x * rectangleSize.width) - (rectangleSize.width / 2) + offset.width,
            height: (point.y * rectangleSize.height) - (rectangleSize.height / 2) + offset.height)
    }
    
    private func limitOffset(_ newOffset: CGSize) -> CGSize {
        let maxX = (maxSize.width - rectangleSize.width) / 2
        let maxY = (maxSize.height - rectangleSize.height) / 2
        return CGSize(
            width: max(-maxX, min(maxX, newOffset.width)),
            height: max(-maxY, min(maxY, newOffset.height))
        )
    }
    
    private func calculateDelta(for point: CGPoint, translation: CGSize) -> CGSize {
        CGSize(
            width: translation.width * (point.x == 0 ? -1 : 1),
            height: translation.height * (point.y == 0 ? -1 : 1)
        )
    }
    
    private func calculateNewSizeAndOffset(delta: CGSize, point: CGPoint) -> (CGSize, CGSize) {
        let newWidth = min(max(CropConstants.minimumRectangleSize, rectangleInitialSize.width + delta.width), maxSize.width)
        let newHeight = min(max(CropConstants.minimumRectangleSize, rectangleInitialSize.height + delta.height), maxSize.height)
        
        var newOffset = offset
        if point.x == 0 { newOffset.width += (rectangleSize.width - newWidth) / 2 }
        if point.y == 0 { newOffset.height += (rectangleSize.height - newHeight) / 2 }
        
        newOffset = limitOffset(newOffset)
        
        return (CGSize(width: newWidth, height: newHeight), newOffset)
    }

    private func mapToPhotosCorner(_ corner: Corner) -> PhotosStyleCornerHandle.Corner {
        switch corner {
        case .topLeft: return .topLeft
        case .topRight: return .topRight
        case .bottomLeft: return .bottomLeft
        case .bottomRight: return .bottomRight
        }
    }

    private enum Corner: CaseIterable {
        case topLeft, topRight, bottomLeft, bottomRight

        var point: CGPoint {
            switch self {
                case .topLeft: return CGPoint(x: 0, y: 0)
                case .topRight: return CGPoint(x: 1, y: 0)
                case .bottomLeft: return CGPoint(x: 0, y: 1)
                case .bottomRight: return CGPoint(x: 1, y: 1)
            }
        }
    }
}

// MARK: - Previews
// Note: Previews temporarily commented out due to Preview macro limitations with struct declarations
/*
@available(iOS 17.0, macOS 14.0, *)
#Preview("Default State") {
    struct PreviewWrapper: View {
        @State private var offset: CGSize = .zero
        @State private var initialOffset: CGSize = .zero
        @State private var rectangleSize: CGSize = CGSize(width: 200, height: 200)
        @State private var rectangleInitialSize: CGSize = CGSize(width: 200, height: 200)
        @State private var maxSize: CGSize = CGSize(width: 300, height: 400)

        var body: some View {
            ZStack {
                Color.gray.opacity(0.3)
                    .ignoresSafeArea()

                DraggableRectangleView(
                    offset: $offset,
                    initialOffset: $initialOffset,
                    rectangleSize: $rectangleSize,
                    rectangleInitialSize: $rectangleInitialSize,
                    maxSize: $maxSize
                )
            }
        }
    }

    PreviewWrapper()
}

@available(iOS 17.0, macOS 14.0, *)
#Preview("Square Crop") {
    struct PreviewWrapper: View {
        @State private var offset: CGSize = .zero
        @State private var initialOffset: CGSize = .zero
        @State private var rectangleSize: CGSize = CGSize(width: 250, height: 250)
        @State private var rectangleInitialSize: CGSize = CGSize(width: 250, height: 250)
        @State private var maxSize: CGSize = CGSize(width: 350, height: 350)

        var body: some View {
            ZStack {
                LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                DraggableRectangleView(
                    offset: $offset,
                    initialOffset: $initialOffset,
                    rectangleSize: $rectangleSize,
                    rectangleInitialSize: $rectangleInitialSize,
                    maxSize: $maxSize
                )
            }
        }
    }

    PreviewWrapper()
}

@available(iOS 17.0, macOS 14.0, *)
#Preview("Portrait Crop") {
    struct PreviewWrapper: View {
        @State private var offset: CGSize = CGSize(width: 0, height: 50)
        @State private var initialOffset: CGSize = CGSize(width: 0, height: 50)
        @State private var rectangleSize: CGSize = CGSize(width: 150, height: 450)
        @State private var rectangleInitialSize: CGSize = CGSize(width: 150, height: 450)
        @State private var maxSize: CGSize = CGSize(width: 350, height: 500)

        var body: some View {
            ZStack {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray.opacity(0.3))
                    .frame(width: 350, height: 500)

                DraggableRectangleView(
                    offset: $offset,
                    initialOffset: $initialOffset,
                    rectangleSize: $rectangleSize,
                    rectangleInitialSize: $rectangleInitialSize,
                    maxSize: $maxSize
                )
            }
        }
    }

    PreviewWrapper()
}
*/
