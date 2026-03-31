//
//  BottomSheetButton.swift
//  Feature
//
//  Created by 김민선 on 3/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import Then

public final class BottomSheetButton: UIButton {
    
    init(frame: CGRect, title: String) {
        super.init(frame: frame)
        setupButton(title: title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton(title: String) {
        self.setTitle(title, for: .normal)
        self.titleLabel?.font = .suit(size: 16, weight: .semibold)
        self.layer.cornerRadius = 12
        self.clipsToBounds = true
        self.layer.borderWidth = 0
        
        updateAppearance()
    }
    
    public override var isSelected: Bool {
        didSet {
            updateAppearance()
        }
    }
    
    private func updateAppearance() {
        if isSelected {
            self.backgroundColor = .color.admin.color.withAlphaComponent(0.25)
            self.setTitleColor(.color.admin.color, for: .normal)
        } else {
            self.backgroundColor = .color.button.color
            self.setTitleColor(.color.sub2.color, for: .normal)
        }
    }
}
