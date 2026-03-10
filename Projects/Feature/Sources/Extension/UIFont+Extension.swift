//
//  UIFont+Extension.swift
//  Feature
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit

extension UIFont {

    static func suit(size fontSize: CGFloat, weight: UIFont.Weight) -> UIFont {
        switch weight {
        case .bold:
            return FeatureFontFamily.Suit.bold.font(size: fontSize)
        case .semibold:
            return FeatureFontFamily.Suit.semiBold.font(size: fontSize)
        case .medium:
            return FeatureFontFamily.Suit.medium.font(size: fontSize)
        case .light:
            return FeatureFontFamily.Suit.light.font(size: fontSize)
        case .thin:
            return FeatureFontFamily.Suit.thin.font(size: fontSize)
        case .heavy:
            return FeatureFontFamily.Suit.heavy.font(size: fontSize)
        case .regular:
            return FeatureFontFamily.Suit.regular.font(size: fontSize)
        default:
            return FeatureFontFamily.Suit.regular.font(size: fontSize)
        }
    }
}
