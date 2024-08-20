//
//  AspectRatio.swift
//  CropImage
//
//  Created by 김성준 on 8/19/24.
//

import Foundation

public enum AspectRatio: String, CaseIterable {
    case free = "Free"
    case square = "1:1"
    case portrait = "1:3"
    
    var ratio: CGFloat? {
        switch self {
            case .free: return nil
            case .square: return 1
            case .portrait: return 1/3
        }
    }
}
