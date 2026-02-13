//
//  MapBottomSheetView.swift
//  Feature
//
//  Created by 김민선 on 2/13/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit
import Then

public final class MapBottomSheetView: UIView {
    
    // MARK: - UI Components
    private let handleView = UIView().then {
        $0.backgroundColor = .white.withAlphaComponent(0.2)
        $0.layer.cornerRadius = 2.5
    }
    
    // 🔥 최근 인기 장소 타이틀
    private let titleLabel = UILabel().then {
        $0.text = "최근 인기 장소 🔥"
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 16, weight: .bold)
    }
    
    // 📋 리스트가 들어갈 영역
    private let contentStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 16
    }

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        addView()
        setLayout()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupView() {
    
        self.backgroundColor = UIColor(red: 25/255, green: 25/255, blue: 25/255, alpha: 1)
        self.layer.cornerRadius = 12
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    private func addView() {
        [handleView, titleLabel, contentStackView].forEach { addSubview($0) }
    }
    
    private func setLayout() {
        handleView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(40)
            $0.height.equalTo(5)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(handleView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
        }
        
        contentStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.lessThanOrEqualToSuperview().inset(20)
        }
    }
}
