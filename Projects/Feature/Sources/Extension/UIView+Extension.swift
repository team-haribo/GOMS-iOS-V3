//
//  UIView+Extension.swift
//  Feature
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit

// MARK: - Dynamic Background

extension UIView {

    
    func setDynamicBackgroundColor(darkModeColor: UIColor, lightModeColor: UIColor) {
        backgroundColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? darkModeColor : lightModeColor
        }
    }
}
