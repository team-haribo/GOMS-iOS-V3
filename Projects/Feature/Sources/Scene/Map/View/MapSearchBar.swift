//
//  MapSearchBar.swift
//  Feature
//
//  Created by 김민선 on 2/13/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit
import Then

public final class MapSearchBar: UIView {
    
    // MARK: - UI Components
    private let containerView = UIView().then {
        $0.backgroundColor = UIColor(red: 25/255, green: 25/255, blue: 25/255, alpha: 1) // #191919
        $0.layer.cornerRadius = 8
    }
    
    private let leftIcon = UIImageView().then {
        
        let bundle = Bundle(for: MapSearchBar.self)
        let image = UIImage(named: "ic_graybear", in: bundle, with: nil)
        
        $0.image = image?.withRenderingMode(.alwaysTemplate)
        
        $0.tintColor = UIColor(red: 95/255, green: 95/255, blue: 95/255, alpha: 1)
        $0.contentMode = .scaleAspectFit
    }
    
    public let textField = UITextField().then {
        $0.attributedPlaceholder = NSAttributedString(
            string: "지번, 지점 이름을 입력해주세요",
            attributes: [.foregroundColor: UIColor(red: 95/255, green: 95/255, blue: 95/255, alpha: 1)]
        )
        $0.textColor = .white
        $0.font = UIFont.systemFont(ofSize: 14)
    }
    
    private let searchIcon = UIImageView().then {
        let bundle = Bundle(for: MapSearchBar.self)
        let image = UIImage(named: "ic_search", in: bundle, with: nil)
        
        $0.image = image?.withRenderingMode(.alwaysTemplate)
        $0.tintColor = UIColor(red: 95/255, green: 95/255, blue: 95/255, alpha: 1)
        $0.contentMode = .scaleAspectFit
    }

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        addView()
        setLayout()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Setup
    private func addView() {
        addSubview(containerView)
        [leftIcon, textField, searchIcon].forEach { containerView.addSubview($0) }
    }
    
    private func setLayout() {
        containerView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        leftIcon.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24) // 크기는 그대로 유지합니다.
        }
        
        searchIcon.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }
        
        textField.snp.makeConstraints {
            $0.leading.equalTo(leftIcon.snp.trailing).offset(8)
            $0.trailing.equalTo(searchIcon.snp.leading).offset(-8)
            $0.centerY.equalToSuperview()
        }
    }
}
