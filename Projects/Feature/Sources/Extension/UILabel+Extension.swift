//
//  UILabel+Extension.swift
//  Feature
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit

extension UILabel {

    func setDynamicTextColor(darkModeColor: UIColor, lightModeColor: UIColor) {
        textColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? darkModeColor : lightModeColor
        }
    }

    func setTextColor(_ color: UIColor, range: NSRange) {

        guard let attributedString = mutableAttributedString() else { return }

        attributedString.addAttribute(
            .foregroundColor,
            value: color,
            range: range
        )

        attributedText = attributedString
    }

    private func mutableAttributedString() -> NSMutableAttributedString? {

        guard let labelText = text,
              let labelFont = font else { return nil }

        if let attributedText = attributedText {
            return attributedText.mutableCopy() as? NSMutableAttributedString
        }

        return NSMutableAttributedString(
            string: labelText,
            attributes: [.font: labelFont]
        )
    }

    func setLineSpacing(spacing: CGFloat) {

        guard let text else { return }

        let attributedString = NSMutableAttributedString(string: text)

        let style = NSMutableParagraphStyle()
        style.lineSpacing = spacing

        attributedString.addAttribute(
            .paragraphStyle,
            value: style,
            range: NSRange(location: 0, length: attributedString.length)
        )

        attributedText = attributedString
    }
}
