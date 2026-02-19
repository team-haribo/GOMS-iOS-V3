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
        $0.layer.cornerRadius = 8
    }
    
    private let leftIcon = UIImageView().then {
        $0.image = UIImage(systemName: "pawprint.fill")
        $0.tintColor = UIColor(red: 95/255, green: 95/255, blue: 95/255, alpha: 1)
        $0.contentMode = .scaleAspectFit
    }
    
    // 뒤로가기 동작을 위한 투명 버튼 (민선님 코드 반영)
    public let backButton = UIButton()
    
    public let textField = UITextField().then {
        $0.attributedPlaceholder = NSAttributedString(
            string: "지번, 지점 이름을 입력해주세요",
            attributes: [.foregroundColor: UIColor(red: 95/255, green: 95/255, blue: 95/255, alpha: 1)]
        )
        $0.textColor = .white
        $0.font = UIFont.systemFont(ofSize: 14)
    }
    
    private let searchIcon = UIImageView().then {
        $0.image = UIImage(systemName: "magnifyingglass")
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
        // 민선님이 주신 순서대로 버튼까지 추가
        [leftIcon, textField, searchIcon, backButton].forEach { containerView.addSubview($0) }
    }
    
    private func setLayout() {
        containerView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        leftIcon.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }
        
        // 버튼 영역: 왼쪽 아이콘을 충분히 덮도록 설정 (민선님 로직)
        backButton.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.width.equalTo(50)
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
    
    // MARK: - Public Method
    public func updateState(_ state: SearchBarState) {
        // 아이콘 선명도를 위해 굵기 설정 추가
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        
        switch state {
        case .home:
            leftIcon.image = UIImage(systemName: "pawprint.fill", withConfiguration: config)
            backButton.isEnabled = false // 홈일 때는 클릭 안 되게
        case .search:
            leftIcon.image = UIImage(systemName: "chevron.left", withConfiguration: config)
            backButton.isEnabled = true  // 검색창 눌렀을 때만 뒤로가기 활성화
        }
    }
}
