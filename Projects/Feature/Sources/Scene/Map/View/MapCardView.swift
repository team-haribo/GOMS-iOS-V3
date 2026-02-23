//
//  MapCardView.swift
//  Feature
//
//  Created by 김민선 on 2/17/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit
import Then

public enum MapCardType {
    case popular
    case recommended
    case reviewed
}

public final class MapCardView: UIView {
    
    private let titleLabel = UILabel().then {
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 18, weight: .medium)
    }
    
    private let categoryLabel = UILabel().then {
        $0.textColor = .white.withAlphaComponent(0.4)
        $0.font = .systemFont(ofSize: 14, weight: .regular)
    }
    
    private let addressLabel = UILabel().then {
        $0.textColor = .white.withAlphaComponent(0.4)
        $0.font = .systemFont(ofSize: 14, weight: .regular)
    }
    
    private let statusLabel = UILabel().then {
        $0.textColor = .white.withAlphaComponent(0.4)
        $0.font = .systemFont(ofSize: 14, weight: .regular)
    }
    
    private let actionButton = UIButton()
    
    private let textStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 4
        $0.alignment = .leading
        $0.distribution = .fill
    }

    public init(type: MapCardType) {
        super.init(frame: .zero)
        setupView(type: type)
        configureData(type: type)
    }
    
    public required init?(coder: NSCoder) { super.init(coder: coder) }
    
    private func setupView(type: MapCardType) {
        self.backgroundColor = UIColor(red: 31/255, green: 31/255, blue: 31/255, alpha: 1)
        self.layer.cornerRadius = 12
        
        let titleStack = UIStackView(arrangedSubviews: [titleLabel, categoryLabel]).then {
            $0.axis = .horizontal
            $0.spacing = 6
            $0.alignment = .lastBaseline
        }
        
        addSubview(textStackView)
        [titleStack, addressLabel, statusLabel].forEach { textStackView.addArrangedSubview($0) }
        addSubview(actionButton)
        
        textStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.lessThanOrEqualTo(actionButton.snp.leading).offset(-8)
        }
        
        actionButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-16)
            $0.size.equalTo(26)
        }
        
        setupButton(type: type)
    }

    private func setupButton(type: MapCardType) {
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        let orangeColor = UIColor(red: 255/255, green: 165/255, blue: 0/255, alpha: 1)
        
        if type == .reviewed {
            actionButton.setImage(UIImage(named : "Trash", in: Bundle.module, compatibleWith: nil), for: .normal)
        } else {
            
            actionButton.setImage(
                UIImage(named: "Hart", in: Bundle.module, compatibleWith: nil),
                for: .normal
            )

            actionButton.setImage(
                UIImage(systemName: "heart.fill", withConfiguration: config),
                for: .selected
            )

            actionButton.tintColor = (type == .recommended) ? orangeColor : .white.withAlphaComponent(0.3)
            actionButton.isSelected = (type == .recommended)
        }
    }

    private func configureData(type: MapCardType) {
        titleLabel.text = "메가MGC커피 광주송정시장점"
        categoryLabel.text = "카페"
        addressLabel.text = "광주 광산구 내상로 23 가동 1층"
        
        if type == .reviewed {
            statusLabel.text = "작성한 후기가 이곳에 표시됩니다."
        } else {
            statusLabel.text = "학생 후기 10+ | 추천 20+"
        }
    }
}
