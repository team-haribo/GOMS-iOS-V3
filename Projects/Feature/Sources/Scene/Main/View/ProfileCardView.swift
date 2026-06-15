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
import Kingfisher

final class ProfileCardView: UIView {
    
    var isClockOn: Bool = UserDefaults.standard.bool(forKey: "isClockOn") {
        didSet {
            updateStudentInfoLayout()
        }
    }
    
    // MARK: - Properties
    let profileImageView: UIImageView = UIImageView().then {
        $0.image = .image.gomsBasicProfile.image
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 26
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

    let subInfoLabel = UILabel().then {
        $0.text = ""
        $0.textColor = .color.sub1.color
        $0.font = UIFont.suit(size: 15, weight: .medium)
        $0.isHidden = true
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
                   isAdmin: Bool,
                   profileImageUrl: String?) {
        print("profileImageUrl:", profileImageUrl ?? "nil")
        if let urlString = profileImageUrl,
           let url = URL(string: urlString) {
            profileImageView.kf.setImage(
                with: url,
                placeholder: UIImage.image.gomsBasicProfile.image,
                options: [.keepCurrentImageWhileLoading, .transition(.fade(0.2))]
            )
        } else {
            profileImageView.image = .image.gomsBasicProfile.image
        }

        nameLabel.text = name
        studentInformationLabel.text = studentInfo
      
        studentInformationLabel.isHidden = false

        if isAdmin {
           
            studentInformationLabel.isHidden = true
            lateCountLabel.isHidden = true
            subInfoLabel.isHidden = false
            subInfoLabel.text = studentInfo

            myOutingStatusLabel.text = "관리자"
            myOutingStatusLabel.textColor = .color.admin.color
        } else {
        
            studentInformationLabel.isHidden = false
            studentInformationLabel.text = studentInfo
            lateCountLabel.isHidden = false
            subInfoLabel.isHidden = true
            lateCountLabel.text = "지각 횟수: \(lateCount)회"

            myOutingStatusLabel.text = outingStatus
            myOutingStatusLabel.textColor = .color.sub1.color
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
        updateStudentInfoLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Add View
    private func addView() {
        [profileImageView, nameLabel, studentInformationLabel, lateCountLabel, subInfoLabel, myOutingStatusLabel].forEach { self.addSubview($0) }
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

        lateCountLabel.snp.makeConstraints {
            $0.leading.equalTo(nameLabel)
            $0.top.equalTo(nameLabel.snp.bottom).offset(6)
            $0.trailing.lessThanOrEqualToSuperview().inset(16)
            $0.bottom.lessThanOrEqualToSuperview().inset(20)
        }

        subInfoLabel.snp.makeConstraints {
            $0.leading.equalTo(nameLabel)
            $0.top.equalTo(nameLabel.snp.bottom).offset(6)
        }

        myOutingStatusLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(16)
        }
    }

    private func updateStudentInfoLayout() {
        studentInformationLabel.snp.remakeConstraints {
            $0.leading.equalTo(nameLabel.snp.trailing).offset(8)
            $0.centerY.equalTo(nameLabel)
            $0.trailing.lessThanOrEqualTo(myOutingStatusLabel.snp.leading).offset(-8)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
    }
}
