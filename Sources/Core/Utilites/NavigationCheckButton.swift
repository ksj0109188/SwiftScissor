//
//  NavigationCheckButton.swift
//  PIXO
//
//  Created by 김성준 on 8/10/24.
//

import SwiftUI

struct NavigationCheckButton: View {
    let color: Color?
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "checkmark")
                .font(.subheadline)
                .foregroundStyle(color ?? .primary)
                .bold()
        }
    }
}

#Preview {
    NavigationCheckButton(color: .black, action: {})
}
