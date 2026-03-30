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
        $0.image = UIImage(named: "Profile", in: Bundle.module, compatibleWith: nil)
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 25
        $0.clipsToBounds = true
    }
    
    private let nameLabel = UILabel().then {
        $0.font = .suit(size: 17, weight: .semibold)
        $0.textColor = UIColor.color.sub1.color
        $0.textAlignment = .center
    }
    
    private let infoLabel = UILabel().then {
        $0.font = .suit(size: 14, weight: .medium)
        $0.textColor = UIColor.color.sub2.color
        $0.textAlignment = .center
    }
    
    private let reportContentLabel = UILabel().then {
        $0.font = .suit(size: 17, weight: .medium)
        $0.textColor = UIColor.color.sub1.color
    }
    
    private let locationLabel = UILabel().then {
        $0.font = .suit(size: 14, weight: .medium)
        $0.textColor = UIColor.color.sub2.color
    }
    
    private let dateLabel = UILabel().then {
        $0.font = .suit(size: 14, weight: .medium)
        $0.textColor = UIColor.color.sub2.color
    }

    private let statusLabel = UILabel().then {
        $0.font = .suit(size: 15, weight: .medium)
    }

    private let textStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 4
        $0.alignment = .leading
        $0.distribution = .fill
    }
    
    private let dividerView = UIView().then {
        $0.backgroundColor = UIColor.color.sub1.color.withAlphaComponent(0.3)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        
        [profileImageView, nameLabel, infoLabel, textStackView, statusLabel, dividerView].forEach {
            contentView.addSubview($0)
        }
        
        [reportContentLabel, locationLabel, dateLabel].forEach {
            textStackView.addArrangedSubview($0)
        }
        
        profileImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(4)
            $0.width.height.equalTo(48)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(4)
            $0.centerX.equalTo(profileImageView)
        }
        
        infoLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(2)
            $0.centerX.equalTo(profileImageView)
        }
        
        textStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(profileImageView.snp.trailing).offset(18)
            $0.trailing.lessThanOrEqualTo(statusLabel.snp.leading).offset(-8)
        }
        
        statusLabel.snp.makeConstraints {
            $0.centerY.equalTo(textStackView)
            $0.trailing.equalToSuperview().inset(4)
        }
        
        dividerView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(with data: ReportData) {
        nameLabel.text = data.reviewerName
        infoLabel.text = "\(data.reviewerGrade)기 | \(data.reviewerDepartment)"
        reportContentLabel.text = data.reportContent
        locationLabel.text = data.location
        dateLabel.text = data.reportCreatedAt
        
        if data.reportStatus == "RECEIVED" {
            statusLabel.text = "처리전"
            statusLabel.textColor = UIColor.color.admin.color
        } else {
            statusLabel.text = "처리 완료"
            statusLabel.textColor = UIColor.color.sub2.color
        }
    }
}
