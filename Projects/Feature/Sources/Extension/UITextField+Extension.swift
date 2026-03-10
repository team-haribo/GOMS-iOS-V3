//
//  UITextField+Extension.swift
//  Feature
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit

public extension UITextField {

    func addPadding(paddingFrame: CGRect) {

        let paddingView = UIView(frame: paddingFrame)

        leftView = paddingView
        leftViewMode = .always

        rightView = paddingView
        rightViewMode = .always
    }

    func setPlaceholderColor(_ placeholderColor: UIColor) {

        attributedPlaceholder = NSAttributedString(
            string: placeholder ?? "",
            attributes: [
                .foregroundColor: placeholderColor,
                .font: font as Any
            ]
        )
    }

    func setTextFieldBackgroundColor(lightModeColor: UIColor, darkModeColor: UIColor) {

        backgroundColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? darkModeColor : lightModeColor
        }
    }

    func setBorderColorMode(lightModeColor: UIColor, darkModeColor: UIColor) {

        let borderColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? darkModeColor : lightModeColor
        }

        layer.borderColor = borderColor.cgColor
    }
}
