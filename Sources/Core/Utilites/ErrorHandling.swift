//
//  ErrorHandling.swift
//  CropImage
//
//  Created by 김성준 on 8/19/24.
//

import Foundation

@MainActor
protocol ErrorHandling {
    var isError: Bool { get set}
    var errorMessage: LocalizedError { get set }
}
