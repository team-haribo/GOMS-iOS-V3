//
//  BottomSheetButton.swift
//  Feature
//
//  Created by 김준표 on 2/25/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit

class BottomSheetButton: UIButton {
    
    init(frame: CGRect, title: String) {
        super.init(frame: frame)
        setButton(withTitle: title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setButton(withTitle title: String) {
        setTitle(title, for: .normal)
        setTitleColor(.color.gomsSecondary.color, for: .normal)
        setTitleColor(.color.admin.color, for: .selected)
        titleLabel?.font = UIFont.suit(size: 16, weight: .semibold)
        layer.masksToBounds = true
        layer.borderWidth = 1
        setButtonBorderColor(lightModeColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0.05), darkModeColor: UIColor(red: 1, green: 1, blue: 1, alpha: 0.15))
        layer.cornerRadius = 12
        setBackgroundColor(.clear, for: .normal)
        setBackgroundColor(UIColor(red: 0.71, green: 0.53, blue: 0.98, alpha: 0.25), for: .selected)
    }
}
