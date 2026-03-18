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
    
    private let iconContainerView = UIView()
    
    private let iconImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    private let textStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 2
        $0.alignment = .leading
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .suit(size: 16, weight: .semibold)
        $0.textColor = .color.mainText.color
    }
    
    private let descriptionLabel = UILabel().then {
        $0.font = .suit(size: 14, weight: .medium)
        $0.textColor = .color.mainText.color
        $0.numberOfLines = 1
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = .clear
        
        contentView.addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)
        contentView.addSubview(textStackView)
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(descriptionLabel)
        
        iconContainerView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(52)
        }
        

        iconImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(52)
        }
        
        textStackView.snp.makeConstraints {
            $0.leading.equalTo(iconContainerView.snp.trailing).offset(16)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-24)
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(with model: RouteStepModel) {
        iconImageView.image = UIImage(named: model.iconName, in: Bundle.module, compatibleWith: nil)
        titleLabel.text = model.title
        descriptionLabel.text = model.description
        
        let actualSize = (model.turnType == .start || model.turnType == .end) ? 24 : 52
        iconImageView.snp.updateConstraints {
            $0.size.equalTo(actualSize)
        }
        
        titleLabel.isHidden = model.title.isEmpty
    }
}
