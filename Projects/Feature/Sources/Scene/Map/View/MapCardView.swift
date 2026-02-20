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

// 1. 타입을 파일 상단에 같이 둠
public enum MapCardType {
    case popular
    case recommended
    case reviewed
}

public final class MapCardView: UIView {
    
    // UI 컴포넌트 선언
    private let titleLabel = UILabel().then {
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 16, weight: .semibold)
    }
    private let categoryLabel = UILabel().then {
        $0.textColor = .lightGray
        $0.font = .systemFont(ofSize: 12, weight: .regular)
    }
    private let addressLabel = UILabel().then {
        $0.textColor = .lightGray
        $0.font = .systemFont(ofSize: 12, weight: .regular)
    }
    private let statusLabel = UILabel().then {
        $0.textColor = .lightGray
        $0.font = .systemFont(ofSize: 12, weight: .regular)
    }
    private let actionButton = UIButton()

    public init(type: MapCardType) {
        super.init(frame: .zero)
        setupView(type: type)
        // 시안용 임시 데이터 세팅
        configureData(type: type)
    }
    
    public required init?(coder: NSCoder) { super.init(coder: coder) }
    
    private func setupView(type: MapCardType) {
        self.backgroundColor = UIColor(red: 31/255, green: 31/255, blue: 31/255, alpha: 1)
        self.layer.cornerRadius = 8
        
        [titleLabel, categoryLabel, addressLabel, statusLabel, actionButton].forEach { addSubview($0) }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(16)
        }
        
        categoryLabel.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.leading.equalTo(titleLabel.snp.trailing).offset(4)
        }
        
        addressLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.equalTo(titleLabel)
        }
        
        statusLabel.snp.makeConstraints {
            $0.top.equalTo(addressLabel.snp.bottom).offset(4)
            $0.leading.equalTo(titleLabel)
        }
        
        actionButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-16)
            $0.size.equalTo(24)
        }
        
        setupButton(type: type)
    }

    private func setupButton(type: MapCardType) {
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        if type == .reviewed {
            actionButton.setImage(UIImage(systemName: "trash", withConfiguration: config), for: .normal)
            actionButton.tintColor = .systemRed
        } else {
            actionButton.setImage(UIImage(systemName: "heart", withConfiguration: config), for: .normal)
            actionButton.setImage(UIImage(systemName: "heart.fill", withConfiguration: config), for: .selected)
            actionButton.tintColor = (type == .recommended) ? .orange : .lightGray
            actionButton.isSelected = (type == .recommended)
        }
    }

    private func configureData(type: MapCardType) {
        // 시안(image_07e901.png) 기반 데이터
        titleLabel.text = "메가MGC커피 광주송정시장점"
        categoryLabel.text = "카페"
        addressLabel.text = "광주 광산구 내상로 23 가동 1층"
        
        if type == .reviewed {
            statusLabel.text = "군군군군군군군군군...  작성일: 26.02.11"
        } else {
            statusLabel.text = "학생 후기 10+ | 추천 20+"
        }
    }
}
