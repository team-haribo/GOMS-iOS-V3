//
//  ReportCollectionViewCell.swift
//  Feature
//
//  Created by 김민선 on 3/29/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit
import Then

final class ReportCollectionViewCell: UICollectionViewCell {
    static let identifier = "ReportCollectionViewCell"
    
    private let profileImageView = UIImageView().then {
        $0.backgroundColor = UIColor.color.sub1.color.withAlphaComponent(0.2)
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 24
        $0.clipsToBounds = true
    }
    
    private let nameLabel = UILabel().then {
        $0.font = .suit(size: 16, weight: .semibold)
        $0.textColor = UIColor.color.mainText.color
    }
    
    private let infoLabel = UILabel().then {
        $0.textColor = UIColor.color.sub1.color
        $0.font = .suit(size: 14, weight: .medium)
    }
    
    private let statusLabel = UILabel().then {
        $0.font = .suit(size: 14, weight: .medium)
    }

    private let dividerView = UIView().then {
        $0.backgroundColor = UIColor.color.sub1.color.withAlphaComponent(0.3)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        [profileImageView, nameLabel, infoLabel, statusLabel, dividerView].forEach { contentView.addSubview($0) }
        
        profileImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(48)
        }
        
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(profileImageView.snp.trailing).offset(16)
            $0.bottom.equalTo(contentView.snp.centerY).offset(0)
        }
        
        infoLabel.snp.makeConstraints {
            $0.leading.equalTo(nameLabel)
            $0.top.equalTo(contentView.snp.centerY).offset(0)
        }
        
        statusLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(10)
            $0.centerY.equalToSuperview()
        }
        
        dividerView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(with data: MockReportData) {
        nameLabel.text = data.userName
        infoLabel.text = "\(data.grade)기 | \(data.grade >= 1 ? "AI과" : "SW과")"
        statusLabel.text = data.status
        
        if data.status == "처리전" {
            statusLabel.textColor = UIColor.color.admin.color // 보라색 포인트
        } else {
            statusLabel.textColor = UIColor.color.sub1.color
        }
    }
}
