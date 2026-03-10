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
    private let iconSize: CGFloat = 28
    private let grayPoint = UIColor.color.button.color
    
    private let containerView = UIView().then {
        $0.backgroundColor = UIColor.color.surface.color
        $0.layer.cornerRadius = 12
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .equalSpacing
        $0.alignment = .center
    }
    
    public let mapButton = UIButton().then {
        $0.setImage(UIImage(named: "Map", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
    }
    
    public let homeButton = UIButton().then {
        $0.setImage(UIImage(named: "House", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
    }
    
    public let profileButton = UIButton().then {
        $0.setImage(UIImage(named: "User", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
    }

    public enum TabType {
        case map
        case home
        case profile
    }

    public var onTabSelected: ((TabType) -> Void)?

    public var selectedTab: TabType = .home {
        didSet {
            updateSelectedState()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.color.surface.color
        setupLayout()
        setupAction()
        updateSelectedState()
    }
    
    private func setupLayout() {
        addSubview(containerView)
        containerView.addSubview(stackView)
        
        [mapButton, homeButton, profileButton].forEach { button in
            stackView.addArrangedSubview(button)
            button.snp.makeConstraints { $0.size.equalTo(iconSize) }
        }
        
        containerView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.trailing.equalToSuperview().inset(52)
        }
    }

    private func setupAction() {
        mapButton.addTarget(self, action: #selector(mapButtonTapped), for: .touchUpInside)
        homeButton.addTarget(self, action: #selector(homeButtonTapped), for: .touchUpInside)
        profileButton.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
    }

    @objc private func mapButtonTapped() {
        selectedTab = .map
        onTabSelected?(.map)
    }

    @objc private func homeButtonTapped() {
        selectedTab = .home
        onTabSelected?(.home)
    }

    @objc private func profileButtonTapped() {
        selectedTab = .profile
        onTabSelected?(.profile)
    }

    private func updateSelectedState() {
        let activeColor = UIColor.color.sub2.color

        mapButton.tintColor = selectedTab == .map ? activeColor : grayPoint
        homeButton.tintColor = selectedTab == .home ? activeColor : grayPoint
        profileButton.tintColor = selectedTab == .profile ? activeColor : grayPoint
    }
    
    required init?(coder: NSCoder) { fatalError() }
}
