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
    
    // MARK: - State Enum
    public enum SearchBarState {
        case home    // 곰돌이 모드
        case search  // 뒤로가기 모드
    }
    
    // MARK: - UI Components
    private let containerView = UIView().then {
        $0.backgroundColor = UIColor(red: 25/255, green: 25/255, blue: 25/255, alpha: 1) // #191919
        $0.layer.cornerRadius = 8 // 디자인 Radius 8px
    }
    
    private let leftIcon = UIImageView().then {
        $0.image = UIImage(named: "GOMS_GOMS", in: Bundle.module, compatibleWith: nil) // 준표 아이콘 들어오면 갈아끼울 것
        $0.tintColor = UIColor(red: 95/255, green: 95/255, blue: 95/255, alpha: 1) // #5F5F5F
      
    }
    
    public let backButton = UIButton()
    
    public let textField = UITextField().then {
        // SUIT Medium 15px 적용
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(red: 95/255, green: 95/255, blue: 95/255, alpha: 1), // #5F5F5F
            .font: UIFont.systemFont(ofSize: 15, weight: .medium) // SUIT 대체용
        ]
        $0.attributedPlaceholder = NSAttributedString(
            string: "지번, 지점 이름을 입력해주세요",
            attributes: attributes
        )
        $0.textColor = .white
        $0.font = UIFont.systemFont(ofSize: 15, weight: .medium)
    }
    
    private let searchIcon = UIImageView().then {
        $0.image = UIImage(named: "Search", in: Bundle.module, compatibleWith: nil)
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
        [leftIcon, textField, searchIcon, backButton].forEach { containerView.addSubview($0) }
    }
    
    private func setLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(52) // 디자인 Height 52
        }
        
        // 곰돌이 아이콘
        leftIcon.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16) // 내부 패딩 16
            $0.centerY.equalToSuperview()
            $0.size.equalTo(26) // 키움
        }
        
        // 글씨랑 곰 간격
        textField.snp.makeConstraints {
            $0.leading.equalTo(leftIcon.snp.trailing).offset(5)
            $0.centerY.equalToSuperview()
            // 돋보기랑 간격
            $0.trailing.equalTo(searchIcon.snp.leading).offset(-57)
        }
        
        // 돋보기 아이콘
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
            leftIcon.image = UIImage(named: "GOMS_GOMS", in: Bundle.module, compatibleWith: nil)
            backButton.isEnabled = false
        case .search:
            leftIcon.image = UIImage(named: "Directional", in: Bundle.module, compatibleWith: nil)
            backButton.isEnabled = true
        }
    }
}
