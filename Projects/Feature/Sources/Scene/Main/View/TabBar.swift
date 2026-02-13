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
    
    // MARK: - UI Components
    private let containerView = UIView().then {
        // 배경색: #191919
        $0.backgroundColor = UIColor(red: 25/255, green: 25/255, blue: 25/255, alpha: 1)
        $0.layer.cornerRadius = 12
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.clipsToBounds = true
    }
    
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.alignment = .fill
    }
    
    
    private let mapButton = UIButton().then {
        let image = UIImage(named: "ic_map")?.withRenderingMode(.alwaysTemplate)
        $0.setImage(image, for: .normal)
        $0.tintColor = UIColor(red: 176/255, green: 176/255, blue: 176/255, alpha: 1) // #B0B0B0
    }
    
    private let homeButton = UIButton().then {
        let image = UIImage(named: "ic_home")?.withRenderingMode(.alwaysTemplate)
        $0.setImage(image, for: .normal)
        $0.tintColor = UIColor(red: 95/255, green: 95/255, blue: 95/255, alpha: 1) // #5F5F5F
    }
    
    private let profileButton = UIButton().then {
        let image = UIImage(named: "ic_profile")?.withRenderingMode(.alwaysTemplate)
        $0.setImage(image, for: .normal)
        $0.tintColor = UIColor(red: 95/255, green: 95/255, blue: 95/255, alpha: 1) // #5F5F5F
    }
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        addView()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addView() {
        addSubview(containerView)
        containerView.addSubview(stackView)
        [mapButton, homeButton, profileButton].forEach { stackView.addArrangedSubview($0) }
    }
    
    private func setLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(84)
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(60)
        }
    }
}
