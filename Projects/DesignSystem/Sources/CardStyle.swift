//
//  CardStyle.swift
//  ParkingMate
//
//  Created by 고재경 on 5/7/26.
//

import SwiftUI

// 다크모드에서 그림자가 거의 안 보이므로 카드 외곽에 옅은 보더로 입체감을 보강한다.
struct CardStyle: ViewModifier {
    var cornerRadius: CGFloat = 20

    func body(content: Content) -> some View {
        content
            .background(Color.cardBackground)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.divider, lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
    }
}

extension View {
    public func cardStyle(cornerRadius: CGFloat = 20) -> some View {
        modifier(CardStyle(cornerRadius: cornerRadius))
    }
}
