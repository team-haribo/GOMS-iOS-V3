//
//  AdminQRButton.swift
//  Feature
//
//  Created by 김준표 on 2/25/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit

class AdminQRButton: UIButton {
    
    private let QRIcon = UIImageView()
    
    init(frame: CGRect, backgroundColor: UIColor, icon: UIImage) {
        super.init(frame: frame)
        self.addSubview(QRIcon)
        
        QRIcon.snp.makeConstraints {
            $0.height.width.equalTo(24)
            $0.centerX.centerY.equalToSuperview()
        }
        setupButton(backgroundColor: backgroundColor, icon: icon)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func setupButton(backgroundColor: UIColor, icon: UIImage) {
        self.backgroundColor = backgroundColor
        QRIcon.image = icon.withRenderingMode(.alwaysTemplate)
        QRIcon.tintColor = .white
    }
}
