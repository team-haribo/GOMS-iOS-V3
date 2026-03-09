//
//  UIFont+Extension.swift
//  Feature
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit

extension UIFont {

    static func pretendard(size fontSize: CGFloat, weight: UIFont.Weight) -> UIFont {
        let familyName = "Pretendard"
        let weightString = pretendardWeightString(for: weight)

        return UIFont(name: "\(familyName)-\(weightString)", size: fontSize)
            ?? .systemFont(ofSize: fontSize, weight: weight)
    }

    private static func pretendardWeightString(for weight: UIFont.Weight) -> String {
        switch weight {
        case .bold:
            return "Bold"
        case .regular:
            return "Regular"
        case .semibold:
            return "SemiBold"
        default:
            return "Regular"
        }
    }
}

