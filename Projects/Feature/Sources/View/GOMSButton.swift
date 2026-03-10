//
//  GOMSButton.swift
//  Feature
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit

public class GOMSButton: UIButton {
    init(frame: CGRect, title: String) {
        super.init(frame: frame)
        setButton(withTitle: title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setButton(withTitle title: String) {
        backgroundColor = .color.gomsPrimary.color
        setTitle(title, for: .normal)
        setTitleColor(UIColor.white, for: .normal)
        titleLabel?.font = UIFont.suit(size: 16, weight: .semibold)
        layer.masksToBounds = true
        layer.cornerRadius = 12
    }
}
