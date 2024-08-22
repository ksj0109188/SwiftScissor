//
//  DraggableRectangleView.swift
//  CropImage
//
//  Created by 김성준 on 8/19/24.
//

import SwiftUI

struct DraggableRectangleView: View {
    @Binding var offset: CGSize
    @Binding var initialOffset: CGSize
    @Binding var rectangleSize: CGSize
    @Binding var rectangleinitialSize: CGSize
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
            .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5]))
            .foregroundColor(.black)
            .frame(width: rectangleSize.width, height: rectangleSize.height)
            .offset(x: offset.width, y: offset.height)
    }
    
    private var cornerHandles: some View {
        ForEach(Corner.allCases, id: \.self) { corner in
            Circle()
                .frame(width: 12)
                .foregroundColor(.black)
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
        .stroke(Color.white.opacity(0.7), lineWidth: 1)
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
                rectangleinitialSize = rectangleSize
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
        let newWidth = min(max(50, rectangleinitialSize.width + delta.width), maxSize.width)
        let newHeight = min(max(50, rectangleinitialSize.height + delta.height), maxSize.height)
        
        var newOffset = offset
        if point.x == 0 { newOffset.width += (rectangleSize.width - newWidth) / 2 }
        if point.y == 0 { newOffset.height += (rectangleSize.height - newHeight) / 2 }
        
        newOffset = limitOffset(newOffset)
        
        return (CGSize(width: newWidth, height: newHeight), newOffset)
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
