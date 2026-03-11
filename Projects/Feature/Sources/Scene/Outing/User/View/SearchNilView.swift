//
//  SearchNilView.swift
//  Feature
//
//  Created by 김준표 on 2/25/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit

import SnapKit
import Then

class SearchNilView: UIView {

    private let iconLabel = UILabel().then {
        $0.text = "🤔"
        $0.font = .systemFont(ofSize: 80)
    }
    
    private let mainLabel = UILabel().then {
        $0.text = "검색 결과가 없습니다\n검색 내용이 잘못되진 않았나요?"
        $0.font = UIFont.suit(size: 16, weight: .regular)
        $0.numberOfLines = 2
        $0.setLineSpacing(spacing: 12)
        $0.textAlignment = .center
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        [iconLabel, mainLabel].forEach { self.addSubview($0) }
        
        iconLabel.snp.makeConstraints {
            $0.width.height.equalTo(80)
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        mainLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(56)
        }
    }
}
