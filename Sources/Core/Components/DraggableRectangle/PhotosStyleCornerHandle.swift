//
//  PhotosStyleCornerHandle.swift
//  SwiftScissor
//
//  iOS Photos app style L-shaped corner handle
//

import SwiftUI

/// iOS Photos app style L-shaped corner handle
/// Features:
/// - L-shaped design with two perpendicular arms
/// - 28pt total size for easy touch interaction
/// - 3pt thickness for visibility
/// - 20pt arm length
/// - White color for high contrast
@available(iOS 17.0, macOS 14.0, *)
public struct PhotosStyleCornerHandle: View {
    let corner: Corner

    // Constants from iOS Photos app design
    let size: CGFloat = CropConstants.photosCornerHandleSize
    let thickness: CGFloat = CropConstants.photosCornerHandleThickness
    let length: CGFloat = CropConstants.photosCornerHandleLength

    public init(corner: Corner) {
        self.corner = corner
    }

    public var body: some View {
        ZStack {
            // Vertical arm of the L
            Rectangle()
                .fill(Color.white)
                .frame(width: thickness, height: length)
                .offset(verticalOffset)

            // Horizontal arm of the L
            Rectangle()
                .fill(Color.white)
                .frame(width: length, height: thickness)
                .offset(horizontalOffset)
        }
        .frame(width: size, height: size)
    }

    /// Calculate vertical arm offset based on corner position
    /// Arms extend outward from corner: upward for top corners, downward for bottom corners
    private var verticalOffset: CGSize {
        let y = corner.isTop ? length/2 : -length/2
        return CGSize(width: 0, height: y)
    }

    /// Calculate horizontal arm offset based on corner position
    /// Arms extend outward from corner: leftward for left corners, rightward for right corners
    private var horizontalOffset: CGSize {
        let x = corner.isLeft ? length/2 : -length/2
        return CGSize(width: x, height: 0)
    }
}

/// Corner position enum for L-shaped handle orientation
@available(iOS 17.0, macOS 14.0, *)
extension PhotosStyleCornerHandle {
    public enum Corner: CaseIterable {
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight

        public var isTop: Bool {
            self == .topLeft || self == .topRight
        }

        public var isLeft: Bool {
            self == .topLeft || self == .bottomLeft
        }

        /// Convert to CGPoint for positioning calculations
        public var point: CGPoint {
            switch self {
            case .topLeft:
                return CGPoint(x: 0, y: 0)
            case .topRight:
                return CGPoint(x: 1, y: 0)
            case .bottomLeft:
                return CGPoint(x: 0, y: 1)
            case .bottomRight:
                return CGPoint(x: 1, y: 1)
            }
        }
    }
}

// MARK: - Previews
@available(iOS 17.0, macOS 14.0, *)
#Preview("All Corner Handles") {
    ZStack {
        Color.gray.opacity(0.3)

        VStack(spacing: 100) {
            HStack(spacing: 100) {
                PhotosStyleCornerHandle(corner: .topLeft)
                PhotosStyleCornerHandle(corner: .topRight)
            }
            HStack(spacing: 100) {
                PhotosStyleCornerHandle(corner: .bottomLeft)
                PhotosStyleCornerHandle(corner: .bottomRight)
            }
        }
    }
    .frame(width: 300, height: 300)
}

@available(iOS 17.0, macOS 14.0, *)
#Preview("Single Handle - Top Left") {
    ZStack {
        Color.gray.opacity(0.3)
        PhotosStyleCornerHandle(corner: .topLeft)
    }
    .frame(width: 100, height: 100)
}
