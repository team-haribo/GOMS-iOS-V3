//
//  OutingListCollectionViewCell.swift
//  Feature
//
//  Created by 김준표 on 2/25/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit

import SnapKit
import Then
import Kingfisher

final class OutingListCollectionViewCell: UICollectionViewCell {
    
    func configureDummy() {
        nameLabel.text = "김민솔"
        studentInfoLabel.text = "8기 | AI"
        outingTime.text = "10:31에 외출"

        profileImageView.image = .image.profile.image
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true

        // ensure circular image even before layout pass
        layoutIfNeeded()
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
    }
    
    // MARK: - Properties
    static let identifier = "OutingListCell"
    
    let profileImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 48, height: 48))
    
    let nameLabel = UILabel().then {
        $0.textColor = .color.sub1.color
        $0.font = UIFont.suit(size: 16, weight: .semibold)
    }
    
    let studentInfoLabel = UILabel().then {
        $0.textColor = .color.sub2.color
        $0.font = UIFont.suit(size: 13, weight: .regular)
    }
    
    private let divLine = UIView().then {
        $0.backgroundColor = .color.sub2.color
    }
    
    let outingTime = UILabel().then {
        $0.textColor = .color.sub2.color
        $0.font = UIFont.suit(size: 12, weight: .regular)
    }
    
    private let bottomView = UIView().then {
        $0.setDynamicBackgroundColor(darkModeColor: UIColor(red: 1, green: 1, blue: 1, alpha: 0.15), lightModeColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0.05))
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
    
    // MARK: - Configure
    func configureData(with outingData: OutingListData) {
        if let imageURL = outingData.profileImageURL, let url = URL(string: imageURL) {
            profileImageView.kf.setImage(with: url, placeholder: UIImage(systemName: "person.crop.circle.fill"))
            profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        } else {
            profileImageView.image = .image.profile.image
        }
        nameLabel.text = outingData.name
        if outingData.major == Major.sw.rawValue {
            studentInfoLabel.text = "\(outingData.grade)기 | SW개발"
        } else if outingData.major == Major.iot.rawValue {
            studentInfoLabel.text = "\(outingData.grade)기 | IoT"
        } else {
            studentInfoLabel.text = "\(outingData.grade)기 | AI"
        }
        outingTime.text = "\(outingData.outingTime)에 외출"
    }
    
    func configureUI() {
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
    }
    
    // MARK: - Add View
    private func addView() {
        [profileImageView, nameLabel, studentInfoLabel, divLine, outingTime, bottomView].forEach { contentView.addSubview($0)}
    }
    
    // MARK: - Layout
    private func setLayout() {
        profileImageView.snp.makeConstraints {
            $0.width.equalTo(48)
            $0.leading.equalToSuperview().inset(16)
            $0.top.bottom.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.height.equalTo(28)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(16)
        }
        
        studentInfoLabel.snp.makeConstraints {
            $0.height.equalTo(20)
            $0.bottom.equalToSuperview().inset(12)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(16)
        }
        
        divLine.snp.makeConstraints {
            $0.height.equalTo(8)
            $0.width.equalTo(1)
            $0.bottom.equalToSuperview().inset(18)
            $0.leading.equalTo(studentInfoLabel.snp.trailing).offset(4)
        }
        
        outingTime.snp.makeConstraints {
            $0.leading.equalTo(divLine.snp.trailing).offset(4)
            $0.height.equalTo(20)
            $0.bottom.equalToSuperview().inset(12)
        }
        
        bottomView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
            $0.leading.trailing.equalToSuperview()
        }
    }
}

