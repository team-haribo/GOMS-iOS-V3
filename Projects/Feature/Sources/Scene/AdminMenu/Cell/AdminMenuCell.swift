//
//  AdminMenuCell.swift
//  Feature
//
//  Created by 김준표 on 2/25/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit

import SnapKit
import Then

class AdminMenuCell: UICollectionViewCell {
    
    // MARK: - Properties
    static let identifier = "AdminMenuCell"
    
    let icon = UIImageView()
    
    let title = UILabel().then {
        $0.textColor = .color.gomsSecondary.color
        $0.font = .suit(size: 16, weight: .semibold)
    }
    
    let arrowIcon = UIImageView().then {
        $0.image = .image.rightArrow.image
    }
    
    private let bottomView = UIView().then {
        $0.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.15)
    }

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        addView()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Add View
    private func addView() {
        [icon, title, arrowIcon, bottomView].forEach { self.addSubview($0) }
    }
    
    // MARK: - Layout
    private func setLayout() {
        icon.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(8)
            $0.centerY.equalToSuperview()
        }
        
        title.snp.makeConstraints {
            $0.leading.equalTo(icon.snp.trailing).offset(4)
            $0.height.equalTo(28)
            $0.centerY.equalToSuperview()
        }
        
        arrowIcon.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(8)
            $0.height.width.equalTo(24)
            $0.centerY.equalToSuperview()
        }
        
        bottomView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
            $0.leading.trailing.equalToSuperview()
        }
    }
}
