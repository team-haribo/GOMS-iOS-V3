//
//  QRButton.swift
//  Feature
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit

class QRButton: UIButton {
    
    private let QRIcon = UIImageView()
    
    init(frame: CGRect, backgroundColor: UIColor) {
        super.init(frame: frame)
        setupButton(backgroundColor: backgroundColor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.addSubview(QRIcon)
        
        QRIcon.snp.makeConstraints {
            $0.height.width.equalTo(36)
            $0.centerX.centerY.equalToSuperview()
        }
    }
    
    private func setupButton(backgroundColor: UIColor) {
        self.backgroundColor = backgroundColor
        QRIcon.image = .image.gomsqrIcon.image
    }
}
