//
//  ProfileCardView.swift
//  Feature
//
//  Created by 김준표 on 2/25/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit
import Then
import Service

final class ProfileCardView: UIView {
    
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
    
    let nameLabel = UILabel().then {
        $0.text = ""
        $0.textColor = .color.mainText.color
        $0.font = UIFont.suit(size: 18, weight: .semibold)
    }
    
    let studentInformationLabel = UILabel().then {
        $0.text = ""
        $0.textColor = .color.sub2.color
        $0.font = UIFont.suit(size: 14, weight: .medium)
    }

    let lateCountLabel = UILabel().then {
        $0.text = ""
        $0.textColor = .color.sub1.color
        $0.font = UIFont.suit(size: 15, weight: .medium)
    }

    let myOutingStatusLabel = UILabel().then {
        $0.text = ""
        $0.textColor = .color.sub1.color
        $0.font = UIFont.suit(size: 16, weight: .semibold)
    }
    
    func configure(name: String,
                   studentInfo: String,
                   lateCount: Int,
                   outingStatus: String,
                   isAdmin: Bool) {
        
        nameLabel.text = name
        studentInformationLabel.text = studentInfo
        
        if isAdmin {
          
            lateCountLabel.isHidden = true
            
            myOutingStatusLabel.text = "관리자"
            myOutingStatusLabel.textColor = .color.admin.color
        
            myOutingStatusLabel.snp.remakeConstraints {
                $0.leading.equalTo(profileImageView.snp.trailing).offset(20)
                $0.top.equalTo(studentInformationLabel.snp.bottom).offset(6)
            }
            
        } else {
         
            lateCountLabel.isHidden = false
            lateCountLabel.text = "지각 횟수: \(lateCount)회"
            
            myOutingStatusLabel.text = outingStatus
            myOutingStatusLabel.textColor = .color.sub1.color
            
       
            myOutingStatusLabel.snp.remakeConstraints {
                $0.centerY.equalToSuperview()
                $0.trailing.equalToSuperview().inset(16)
            }
        }
    }
    
    private func configureUI() {
        self.clipsToBounds = true
        self.layer.cornerRadius = 12
        self.backgroundColor = .color.surface.color
    }

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        addView()
        setLayout()
        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Add View
    private func addView() {
        [profileImageView, nameLabel, studentInformationLabel, lateCountLabel, myOutingStatusLabel].forEach { self.addSubview($0) }
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
            $0.leading.equalTo(nameLabel)
            $0.top.equalTo(nameLabel.snp.bottom).offset(4)
        }
        
        lateCountLabel.snp.makeConstraints {
            $0.leading.equalTo(nameLabel)
            $0.top.equalTo(nameLabel.snp.bottom).offset(6)
            $0.bottom.lessThanOrEqualToSuperview().inset(20)
        }
        
        myOutingStatusLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(16)
        }
 
    }
}
