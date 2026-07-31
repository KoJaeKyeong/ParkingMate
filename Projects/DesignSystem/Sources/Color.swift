//
//  Color.swift
//  ParkingMate
//
//  Created by 고재경 on 7/31/26.
//

import SwiftUI

// 에셋이 DesignSystem 번들에 있으므로 Xcode 생성 심볼(internal) 대신
// bundle: .module 을 명시한 public 확장을 직접 제공한다.
extension Color {
    public static let backgroundEnd = Color("BackgroundEnd", bundle: .module)
    public static let backgroundStart = Color("BackgroundStart", bundle: .module)
    public static let brandDanger = Color("BrandDanger", bundle: .module)
    public static let brandPrimary = Color("BrandPrimary", bundle: .module)
    public static let brandSuccess = Color("BrandSuccess", bundle: .module)
    public static let cardBackground = Color("CardBackground", bundle: .module)
    public static let divider = Color("Divider", bundle: .module)
    public static let nestedBackground = Color("NestedBackground", bundle: .module)
    public static let textPrimary = Color("TextPrimary", bundle: .module)
    public static let textSecondary = Color("TextSecondary", bundle: .module)
}
