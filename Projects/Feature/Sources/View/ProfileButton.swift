//
//  ProfileButton.swift
//  Feature
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit

import SnapKit
import Then

public class ProfileButton: UIButton {
    
    let iconImage = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    public let buttonTitle = UILabel().then {
        $0.textColor = .color.sub1.color
        $0.font = .suit(size: 16, weight: .medium)
    }
    
    let arrowIcon = UIImageView().then {
        $0.image = .image.rightArrowGray.image
    }
    
    init(icon: UIImage, title: String) {
        super.init(frame: .zero)
        setButton(title: title, icon: icon)
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setLayout() {
        [iconImage, buttonTitle, arrowIcon].forEach { self.addSubview($0) }
        
        iconImage.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
            $0.leading.equalToSuperview().inset(16)
        }
        
        buttonTitle.snp.makeConstraints {
            $0.leading.equalTo(iconImage.snp.trailing).offset(12)
            $0.centerY.equalToSuperview()
        }
        
        arrowIcon.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(16)
        }
    }
    
    private func setButton(title: String, icon: UIImage) {
        buttonTitle.text = title
        iconImage.image = icon
        
        
        if title == "회원탈퇴" {
            iconImage.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            iconImage.tintColor = .color.gomsNegative.color
            buttonTitle.textColor = .color.gomsNegative.color
        }
        else if title == "로그아웃" {
            iconImage.tintColor = .color.gomsNegative.color
            buttonTitle.textColor = .color.gomsNegative.color
        }
        else {
            iconImage.transform = .identity
            iconImage.tintColor = .color.mainText.color
            buttonTitle.textColor = .color.mainText.color
        }
    }
}
