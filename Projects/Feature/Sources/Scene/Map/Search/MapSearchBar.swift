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
    
    public enum SearchBarState {
        case home
        case search
    }
    
    private let containerView = UIView().then {
        $0.backgroundColor = UIColor.color.surface.color
        $0.layer.cornerRadius = 8
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.05
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        $0.layer.shadowRadius = 4
    }
    
    private let leftIcon = UIImageView().then {
        $0.image = UIImage(named: "GOMS", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        $0.tintColor = UIColor.color.sub1.color
        $0.contentMode = .scaleAspectFit
    }
    
    public let backButton = UIButton()
    
    public let textField = UITextField().then {
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.color.sub1.color,
            .font: UIFont.systemFont(ofSize: 15, weight: .medium)
        ]
        $0.attributedPlaceholder = NSAttributedString(
            string: "지번, 지점 이름을 입력해주세요",
            attributes: attributes
        )
        $0.textColor = UIColor.color.mainText.color
        $0.font = UIFont.systemFont(ofSize: 15, weight: .medium)
    }
    
    private let searchIcon = UIImageView().then {
        $0.image = UIImage(named: "Search", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        $0.tintColor = UIColor.color.sub1.color
        $0.contentMode = .scaleAspectFit
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addView()
        setLayout()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func addView() {
        addSubview(containerView)
        [leftIcon, textField, searchIcon, backButton].forEach { containerView.addSubview($0) }
    }
    
    private func setLayout() {
        // containerView가 부모(MapSearchBar)의 전체를 꽉 채우도록 고정
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        leftIcon.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(26)
        }
        
        textField.snp.makeConstraints {
            $0.leading.equalTo(leftIcon.snp.trailing).offset(10)
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(searchIcon.snp.leading).offset(-10)
        }
        
        searchIcon.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(26)
        }
        
        backButton.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.width.equalTo(50)
        }
    }
    
    public func updateState(_ state: SearchBarState) {
        switch state {
        case .home:
            leftIcon.image = UIImage(named: "GOMS", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            backButton.isEnabled = false
        case .search:
            leftIcon.image = UIImage(named: "Directional", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            backButton.isEnabled = true
        }
        leftIcon.tintColor = UIColor.color.sub1.color
    }
}
