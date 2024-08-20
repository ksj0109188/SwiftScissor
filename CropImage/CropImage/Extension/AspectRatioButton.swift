//
//  AspectRatioButton.swift
//  CropImage
//
//  Created by 김성준 on 8/19/24.
//

import SwiftUI

struct AspectRatioButtonGroup: View {
    @Binding var selectedRatio: AspectRatio
    var onRatioSelected: () -> Void
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(AspectRatio.allCases, id: \.self) { ratio in
                ratioButton(for: ratio)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
    
    private func ratioButton(for ratio: AspectRatio) -> some View {
        Button(action: {
            selectedRatio = ratio
            onRatioSelected()
        }) {
            Text(ratio.rawValue)
                .font(.title2)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(backgroundFor(ratio))
                .foregroundColor(foregroundColorFor(ratio))
                .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func backgroundFor(_ ratio: AspectRatio) -> Color {
        selectedRatio == ratio ? Color.blue : Color.gray.opacity(0.3)
    }
    
    private func foregroundColorFor(_ ratio: AspectRatio) -> Color {
        selectedRatio == ratio ? .white : .black
    }
    
}


#Preview {
    AspectRatioButtonGroup(selectedRatio: .constant(.free)) {
        
    }
}
