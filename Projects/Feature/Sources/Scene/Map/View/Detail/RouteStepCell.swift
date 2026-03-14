//
//  RouteStepCell.swift
//  Feature
//
//  Created by 김민선 on 3/15/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit
import Then

final class RouteStepCell: UITableViewCell {
    static let identifier = "RouteStepCell"
    
    private let iconImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .semibold)
        $0.textColor = .black
    }
    
    private let descriptionLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.textColor = .gray
        $0.numberOfLines = 0
    }
    
    private let lineView = UIView().then {
        $0.backgroundColor = .gray.withAlphaComponent(0.2)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = .clear
        
        [lineView, iconImageView, titleLabel, descriptionLabel].forEach { addSubview($0) }
        
        iconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalToSuperview().offset(12)
            $0.size.equalTo(28)
        }
        
        lineView.snp.makeConstraints {
            $0.centerX.equalTo(iconImageView)
            $0.top.equalTo(iconImageView.snp.bottom).offset(4)
            $0.bottom.equalToSuperview().offset(4)
            $0.width.equalTo(1)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(iconImageView)
            $0.leading.equalTo(iconImageView.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().offset(-24)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.equalTo(titleLabel)
            $0.trailing.equalTo(titleLabel)
            $0.bottom.equalToSuperview().offset(-12)
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(with model: RouteStepModel, isLast: Bool) {
        // 수정된 모델의 iconName 사용
        iconImageView.image = UIImage(named: model.iconName)
        titleLabel.text = model.title
        descriptionLabel.text = model.description
        lineView.isHidden = isLast
    }
}
