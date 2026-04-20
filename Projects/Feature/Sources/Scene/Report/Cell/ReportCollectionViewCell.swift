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
import Kingfisher

// 레이아웃 완전 재구성 (StackView 제거)
final class ReportCollectionViewCell: UICollectionViewCell {
    static let identifier = "ReportCollectionViewCell"
    
    private let reportContentLabel = UILabel().then {
        $0.font = .suit(size: 17, weight: .semibold)
        $0.textColor = UIColor.color.sub1.color
        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingTail
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        $0.setContentHuggingPriority(.required, for: .vertical)
    }
    
    private let locationLabel = UILabel().then {
        $0.font = .suit(size: 14, weight: .medium)
        $0.textColor = UIColor.color.sub2.color
        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingTail
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        $0.setContentHuggingPriority(.required, for: .vertical)
    }
    
    private let dateLabel = UILabel().then {
        $0.font = .suit(size: 14, weight: .medium)
        $0.textColor = UIColor.color.sub2.color
        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingTail
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        $0.setContentHuggingPriority(.required, for: .vertical)
    }

    private let statusLabel = UILabel().then {
        $0.font = .suit(size: 15, weight: .medium)
    }

    private let dividerView = UIView().then {
        $0.backgroundColor = UIColor.color.sub1.color.withAlphaComponent(0.3)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        
        [reportContentLabel, locationLabel, dateLabel, statusLabel, dividerView].forEach {
            contentView.addSubview($0)
        }
        
        reportContentLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.equalToSuperview().offset(36)
            $0.trailing.equalToSuperview().inset(36)
        }

        locationLabel.snp.makeConstraints {
            $0.top.equalTo(reportContentLabel.snp.bottom).offset(0)
            $0.leading.equalTo(reportContentLabel.snp.leading)
            $0.trailing.equalToSuperview().inset(36)
        }

        dateLabel.snp.makeConstraints {
            $0.top.equalTo(locationLabel.snp.bottom)
            $0.leading.equalTo(reportContentLabel.snp.leading)
            $0.trailing.equalToSuperview().inset(36)
        }

        statusLabel.snp.makeConstraints {
            $0.centerY.equalTo(reportContentLabel)
            $0.trailing.equalToSuperview().inset(36)
            $0.width.greaterThanOrEqualTo(50)
        }
        statusLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        dividerView.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Configure (Data Binding)
    func configure(with data: ReportData) {
        reportContentLabel.text = data.reportContent
        
        locationLabel.text = data.location
        reportContentLabel.numberOfLines = 1
        locationLabel.numberOfLines = 1
        dateLabel.numberOfLines = 1
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"

        if let date = formatter.date(from: data.reportCreatedAt) {
            let output = DateFormatter()
            output.dateFormat = "yy.MM.dd HH:mm:ss"
            dateLabel.text = output.string(from: date)
        } else {
            print("❌ date parse 실패:", data.reportCreatedAt)
            dateLabel.text = data.reportCreatedAt
        }
        
        switch data.reportStatus {
        case .pending:
            statusLabel.text = "처리전"
            statusLabel.textColor = UIColor.color.admin.color
        case .approved:
            statusLabel.text = "처리 완료"
            statusLabel.textColor = UIColor.color.sub2.color
        case .rejected:
            statusLabel.text = "기각"
            statusLabel.textColor = UIColor.color.sub2.color
        }
    }
}
