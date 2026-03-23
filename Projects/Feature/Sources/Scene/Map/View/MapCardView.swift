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
        $0.textColor = UIColor.color.mainText.color
        $0.font = .systemFont(ofSize: 18, weight: .medium)
    }
    
    private let categoryLabel = UILabel().then {
        $0.textColor = UIColor.color.sub1.color
        $0.font = .systemFont(ofSize: 14, weight: .regular)
    }
    
    private let addressLabel = UILabel().then {
        $0.textColor = UIColor.color.sub1.color
        $0.font = .systemFont(ofSize: 14, weight: .regular)
    }
    
    private let statusLabel = UILabel().then {
        $0.textColor = UIColor.color.sub1.color
        $0.font = .systemFont(ofSize: 14, weight: .regular)
    }
    
    // 바텀시트에서 접근해야 하므로 public 유지
    public let actionButton = UIButton()
    
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
        self.backgroundColor = UIColor.color.gomsCardBackgroundColor.color
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
            $0.size.equalTo(24) // 쓰레기통과 하트 크기 통일
        }
        
        setupButton(type: type)
    }

    private func setupButton(type: MapCardType) {
        if type == .reviewed {
            // 쓰레기통 아이콘 크기 조정 (하트와 맞춤)
            let deleteConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
            let deleteImage = UIImage(named: "GOMS_DeleteIcon", in: Bundle.module, compatibleWith: nil)?
                .withConfiguration(deleteConfig)
                .withRenderingMode(.alwaysTemplate)
            
            actionButton.setImage(deleteImage, for: .normal)
            actionButton.tintColor = UIColor.color.gomsNegative.color
        } else {
            // 보내주신 하트 채우기 로직 적용
            let heartConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
            
            // 일반 상태: Hart 에셋
            actionButton.setImage(
                UIImage(named: "Hart", in: Bundle.module, compatibleWith: nil),
                for: .normal
            )
            // 선택 상태: heart.fill 시스템 아이콘
            actionButton.setImage(
                UIImage(systemName: "heart.fill", withConfiguration: heartConfig),
                for: .selected
            )
            
            actionButton.isSelected = (type == .recommended)
            // 색상 설정 (추천 타입이면 Primary, 아니면 sub1)
            actionButton.tintColor = actionButton.isSelected ? UIColor.color.gomsPrimary.color : UIColor.color.sub1.color
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
