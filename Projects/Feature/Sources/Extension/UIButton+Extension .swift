//
//  UIButton+Extension .swift
//  Feature
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit

extension UIButton {

    func setTitleColorForMode(darkModeColor: UIColor, lightModeColor: UIColor) {
        let traitCollection = UITraitCollection(userInterfaceStyle: .dark)
        let titleColor = darkModeColor.resolvedColor(with: traitCollection)
        setTitleColor(titleColor, for: .normal)
    }

    func setButtonBackgroundColor(lightModeColor: UIColor, darkModeColor: UIColor) {
        backgroundColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? darkModeColor : lightModeColor
        }
    }

    func setButtonBorderColor(lightModeColor: UIColor, darkModeColor: UIColor) {
        let borderColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? darkModeColor : lightModeColor
        }
        layer.borderColor = borderColor.cgColor
    }

    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {

        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))

        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.setFillColor(color.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))

        let image = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        setBackgroundImage(image, for: state)
    }

    convenience init(filterButton title: String) {
        self.init()

        setTitle(title, for: .normal)
        setTitleColor(.color.gomsSecondary.color, for: .normal)
        titleLabel?.font = UIFont.suit(size: 16, weight: .semibold)

        frame = CGRect(x: 0, y: 0, width: 101, height: 56)

        backgroundColor = .clear
        layer.borderColor = UIColor.black.withAlphaComponent(0.05).cgColor
        layer.borderWidth = 1
        layer.masksToBounds = true
        layer.cornerRadius = 12
    }
}
