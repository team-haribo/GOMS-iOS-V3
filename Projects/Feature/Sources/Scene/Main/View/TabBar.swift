//
//  _GOMSTabBar.swift
//  Feature
//
//  Created by 김민선 on 2/12/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit
import Then

public final class TabBar: UIView {
    
    private let figmaDarkColor = UIColor(red: 25/255, green: 25/255, blue: 25/255, alpha: 1)
    
    // 컴포넌트 선언 (기존 코드 유지)
    private let containerView = UIView().then {
        $0.backgroundColor = UIColor(red: 25/255, green: 25/255, blue: 25/255, alpha: 1)
    }
    
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
    }
    
    public let mapButton = UIButton().then {
        $0.setImage(UIImage(systemName: "map.fill"), for: .normal)
        $0.tintColor = UIColor(red: 176/255, green: 176/255, blue: 176/255, alpha: 1)
    }
    
    public let homeButton = UIButton().then {
        $0.setImage(UIImage(systemName: "house.fill"), for: .normal)
        $0.tintColor = UIColor(red: 95/255, green: 95/255, blue: 95/255, alpha: 1)
    }
    
    public let profileButton = UIButton().then {
        $0.setImage(UIImage(systemName: "person.fill"), for: .normal)
        $0.tintColor = UIColor(red: 95/255, green: 95/255, blue: 95/255, alpha: 1)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupLayout()
    }
    
    required init?(coder: NSCoder) { fatalError() }

    private func setupView() {
        self.backgroundColor = figmaDarkColor
        
        // 탭바와 바텀시트가 자연스럽게 이어지도록 상단 그림자 추가
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: -4)
        self.layer.shadowOpacity = 0.3
        self.layer.shadowRadius = 10
        
        self.layer.cornerRadius = 12
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.clipsToBounds = false // 그림자를 위해 false
    }
    
    private func setupLayout() {
        addSubview(containerView)
        containerView.addSubview(stackView)
        [mapButton, homeButton, profileButton].forEach { stackView.addArrangedSubview($0) }
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10) // 상단 여백
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(60) // 아이콘 영역 높이
        }
    }
}
