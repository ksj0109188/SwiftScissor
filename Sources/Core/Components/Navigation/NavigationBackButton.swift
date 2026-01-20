//
//  NavigationBackButton.swift
//  PIXO
//
//  Created by 김성준 on 8/10/24.
//

import SwiftUI

struct NavigationBackButton: View {
    @Environment(\.dismiss) var dismiss
    
    var buttonType: BackButtonType = .chevron
    let color: Color?
    let action: () -> Void
    
    var body: some View {
        Button {
            if buttonType == .chevron {
                action()
            } else {
                action()
                dismiss()
            }
        } label: {
            Image(systemName: "\(buttonType.symbolName)")
                .font(.subheadline)
                .foregroundStyle(color ?? .primary)
                .bold()
        }
    }
    
    enum BackButtonType {
        case chevronDismiss
        case chevron
        case xmark
        
        var symbolName: String {
            switch self {
                case .chevronDismiss:
                    "chevron.left"
                case .chevron:
                    "chevron.left"
                case .xmark:
                    "xmark"
            }
        }
    }
}

#Preview {
    NavigationBackButton(color: .black, action: {})
}
