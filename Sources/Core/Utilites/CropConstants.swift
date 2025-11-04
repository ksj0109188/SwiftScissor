//
//  CropConstants.swift
//  SwiftScissor
//
//  Created by Claude on 10/30/25.
//

import CoreGraphics

/// Constants used throughout the SwiftScissor crop interface.
/// Centralizes all magic numbers for better maintainability.
enum CropConstants {
    // MARK: - Crop Area

    /// Default size for the initial crop rectangle
    static let defaultRectangleSize: CGFloat = 150

    /// Minimum allowed size for the crop rectangle
    static let minimumRectangleSize: CGFloat = 50

    // MARK: - UI Elements

    /// Size of the corner resize handles
    static let cornerHandleSize: CGFloat = 12

    /// Width of the grid lines shown during dragging
    static let gridLineWidth: CGFloat = 1

    /// Opacity of the grid lines
    static let gridLineOpacity: CGFloat = 0.7

    /// Width of the crop area border
    static let cropBorderWidth: CGFloat = 1

    /// Dash pattern for the crop border [dash length, gap length]
    static let cropBorderDash: [CGFloat] = [5]

    // MARK: - iOS Photos Style

    /// Border width for iOS Photos app style (solid white border)
    static let photosBorderWidth: CGFloat = 1.5

    /// Size of the L-shaped corner handle (28pt for easy touch)
    static let photosCornerHandleSize: CGFloat = 28

    /// Thickness of the L-shaped handle arms
    static let photosCornerHandleThickness: CGFloat = 3

    /// Length of each arm of the L-shaped handle
    static let photosCornerHandleLength: CGFloat = 20

    // MARK: - Mask

    /// Opacity of the dark mask overlay outside crop area
    static let maskOpacity: CGFloat = 0.5

    // MARK: - Animation

    /// Spring animation response time (how quickly animation reaches target)
    static let springResponse: CGFloat = 0.3

    /// Spring animation damping fraction (controls bounce)
    static let springDampingFraction: CGFloat = 0.7

    /// Scale effect when button is pressed
    static let buttonScaleEffect: CGFloat = 0.95

    /// General animation duration for non-spring animations
    static let animationDuration: CGFloat = 0.2

    // MARK: - Button Group Styling

    /// Spacing between buttons in classic style
    static let buttonGroupSpacing: CGFloat = 10

    /// Spacing between buttons in liquid glass style
    static let liquidGlassButtonGroupSpacing: CGFloat = 12

    /// Corner radius for individual buttons (classic)
    static let buttonCornerRadius: CGFloat = 20

    /// Corner radius for individual buttons (liquid glass)
    static let liquidGlassButtonCornerRadius: CGFloat = 16

    /// Corner radius for button group container (classic)
    static let containerCornerRadius: CGFloat = 10

    /// Corner radius for button group container (liquid glass)
    static let liquidGlassContainerCornerRadius: CGFloat = 20

    /// Horizontal padding for button text
    static let buttonHorizontalPadding: CGFloat = 12

    /// Vertical padding for button text
    static let buttonVerticalPadding: CGFloat = 8

    /// Horizontal padding for liquid glass button text
    static let liquidGlassButtonHorizontalPadding: CGFloat = 16

    /// Vertical padding for liquid glass button text
    static let liquidGlassButtonVerticalPadding: CGFloat = 10
}
