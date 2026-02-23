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
    private let grayPoint = UIColor(red: 73/255, green: 73/255, blue: 73/255, alpha: 1) // #494949
    
    private let containerView = UIView().then {
        $0.backgroundColor = UIColor(red: 25/255, green: 25/255, blue: 25/255, alpha: 1) // #191919
        $0.layer.cornerRadius = 12
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .equalSpacing
        $0.alignment = .center
    }
    
    public let mapButton = UIButton().then {
        $0.setImage(UIImage(systemName: "map.fill"), for: .normal)
        $0.tintColor = .white
    }
    
    public let homeButton = UIButton().then {
        $0.setImage(UIImage(named: "House", in: Bundle.module, compatibleWith: nil ), for: .normal)
    }
    
    public let profileButton = UIButton().then {
        $0.setImage(UIImage(systemName: "person"), for: .normal)
        $0.tintColor = UIColor(red: 73/255, green: 73/255, blue: 73/255, alpha: 1) // #494949
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
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
    
    required init?(coder: NSCoder) { fatalError() }
}
