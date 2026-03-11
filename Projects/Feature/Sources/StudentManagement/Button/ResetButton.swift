//
//  ResetButton.swift
//  Feature
//
//  Created by 김준표 on 2/25/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit

class ResetButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setButton() {
        backgroundColor = UIColor(red: 0.895, green: 0.213, blue: 0.125, alpha: 0.25)
        setTitle("필터 초기화", for: .normal)
        setTitleColor(UIColor(red: 0.895, green: 0.213, blue: 0.125, alpha: 1), for: .normal)
        titleLabel?.font = UIFont.suit(size: 16, weight: .semibold)
        layer.masksToBounds = true
        layer.cornerRadius = 12
    }
}
