//
//  MapPopupView.swift
//  Feature
//
//  Created by 김민선 on 2/21/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit
import Then

public final class MapPopupView: UIView {
    
    private let containerView = UIView().then {
        $0.backgroundColor = UIColor(red: 45/255, green: 45/255, blue: 45/255, alpha: 1)
        $0.layer.cornerRadius = 12
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 16, weight: .bold)
        $0.textAlignment = .center
    }
    
    private let descriptionLabel = UILabel().then {
        $0.textColor = UIColor(red: 160/255, green: 160/255, blue: 160/255, alpha: 1)
        $0.font = .systemFont(ofSize: 13)
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    
    public let leftButton = UIButton().then {
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 14)
    }
    
    public let rightButton = UIButton().then {
        $0.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupView() {
        self.backgroundColor = .black.withAlphaComponent(0.6)
        addSubview(containerView)
        [titleLabel, descriptionLabel, leftButton, rightButton].forEach { containerView.addSubview($0) }
        
        containerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(280)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.centerX.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        leftButton.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(24)
            $0.leading.bottom.equalToSuperview()
            $0.width.equalTo(140)
            $0.height.equalTo(52)
        }
        
        rightButton.snp.makeConstraints {
            $0.top.equalTo(leftButton)
            $0.trailing.bottom.equalToSuperview()
            $0.leading.equalTo(leftButton.snp.trailing)
            $0.height.equalTo(52)
        }
    }
    
    public func configure(title: String, desc: String, left: String, right: String, isWarning: Bool = false) {
        titleLabel.text = title
        descriptionLabel.text = desc
        leftButton.setTitle(left, for: .normal)
        rightButton.setTitle(right, for: .normal)
        rightButton.setTitleColor(isWarning ? .systemRed : .systemBlue, for: .normal)
        
        // 버튼이 하나인 완료 팝업의 경우
        leftButton.isHidden = left.isEmpty
        if left.isEmpty {
            rightButton.snp.remakeConstraints {
                $0.top.equalTo(descriptionLabel.snp.bottom).offset(24)
                $0.leading.trailing.bottom.equalToSuperview()
                $0.height.equalTo(52)
            }
        }
    }
}
