//
//  ResetButton.swift
//  Feature
//
//  Created by 김민선 on 3/25/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import Then

public final class ResetButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton() {
        self.backgroundColor = .color.gomsNegative.color.withAlphaComponent(0.25)

        self.setTitle("필터 초기화", for: .normal)
        
        self.setTitleColor(.color.gomsNegative.color, for: .normal)
        
        self.titleLabel?.font = .suit(size: 16, weight: .medium)
        
        self.layer.cornerRadius = 12
        self.clipsToBounds = true
    }
}
