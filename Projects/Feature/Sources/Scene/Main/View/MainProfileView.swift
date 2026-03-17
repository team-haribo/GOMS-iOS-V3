//
//  MainProfileView.swift
//  Feature
//
//  Created by 김준표 on 2/25/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit

import SnapKit
import Then

public final class MainProfileView: UIView {
    
    var isClockOn: Bool = UserDefaults.standard.bool(forKey: "isClockOn") {
            didSet {
                setLayout()
            }
        }
    
    // MARK: - Properties
    let profileImageView = UIImageView().then {
        $0.image = .image.gomsBasicProfile.image
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
    }
    
    let lateCountLabel = UILabel().then {
        $0.textColor = .color.sub1.color
        $0.font = UIFont.suit(size: 15, weight: .medium)
    }
    
    let nameLabel = UILabel().then {
        $0.textColor = .color.mainText.color
        $0.font = UIFont.suit(size: 18, weight: .semibold)
    }
    
    let studentInformationLabel = UILabel().then {
        $0.textColor = .color.sub2.color
        $0.font = UIFont.suit(size: 14, weight: .medium)
    }

    let profileStatus = UILabel().then {
        $0.text = ""
        $0.textColor = .color.sub1.color
        $0.font = UIFont.suit(size: 16, weight: .semibold)
    }
    
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        addView()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure UI
    private func configureUI() {
        self.clipsToBounds = true
        self.layer.cornerRadius = 12
        self.backgroundColor = .color.surface.color
    }
    
    // MARK: - Add View
    private func addView() {
        [profileImageView, nameLabel, studentInformationLabel, lateCountLabel, profileStatus].forEach { self.addSubview($0) }
    }
    
    // MARK: - Layout
    private func setLayout() {
        profileImageView.snp.makeConstraints {
            $0.width.height.equalTo(52)
            $0.leading.equalToSuperview().inset(16)
            $0.top.equalToSuperview().inset(20)
        }

        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(profileImageView.snp.trailing).offset(20)
            $0.top.equalToSuperview().inset(20)
        }

        studentInformationLabel.snp.makeConstraints {
            $0.leading.equalTo(nameLabel.snp.trailing).offset(8)
            $0.centerY.equalTo(nameLabel)
        }

        lateCountLabel.snp.makeConstraints {
            $0.leading.equalTo(nameLabel)
            $0.top.equalTo(nameLabel.snp.bottom).offset(6)
            $0.bottom.lessThanOrEqualToSuperview().inset(20)
        }

        profileStatus.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(16)
        }
    }
}
