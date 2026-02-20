//
//  MapRouteSelectionView.swift
//  Feature
//
//  Created by 김민선 on 2/21/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit
import Then

public final class MapRouteSelectionView: UIView {
    
    // 상단 블랙 컨테이너 (디자인처럼 상단에만 위치)
    private let containerView = UIView().then {
        $0.backgroundColor = UIColor(red: 25/255, green: 25/255, blue: 25/255, alpha: 1)
        $0.layer.cornerRadius = 12
        $0.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    
    public let backButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        $0.tintColor = .white
    }
    
    private let startLabel = UILabel().then {
        $0.text = "출발"; $0.textColor = .lightGray; $0.font = .systemFont(ofSize: 12)
    }

    private let endLabel = UILabel().then {
        $0.text = "도착"; $0.textColor = .lightGray; $0.font = .systemFont(ofSize: 12)
    }
    
    // 디자인과 동일한 회색 박스 스타일 (Configuration으로 통일)
    public let startDropdownButton = UIButton().then {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = UIColor(red: 45/255, green: 45/255, blue: 45/255, alpha: 1) // 디자인 회색
        config.baseForegroundColor = .white
        var titleAttr = AttributedString("출발 위치를 선택해주세요")
        titleAttr.font = .systemFont(ofSize: 14)
        config.attributedTitle = titleAttr
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0)
        $0.configuration = config
        $0.contentHorizontalAlignment = .left
        $0.layer.cornerRadius = 10 // 디자인에 맞춰 조정
        $0.clipsToBounds = true
    }
    
    // Label도 Button과 똑같은 배경색, 여백, 곡률로 수정
    public let endLocationLabel = UILabel().then {
        $0.textColor = .white; $0.font = .systemFont(ofSize: 14)
        $0.backgroundColor = UIColor(red: 45/255, green: 45/255, blue: 45/255, alpha: 1)
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
        $0.text = "  짬뽕관 광주송정선운점" // 실제 데이터 연결 전 가이드
    }
    
    public let reverseButton = UIButton().then {
        $0.setImage(UIImage(systemName: "arrow.up.arrow.down"), for: .normal)
        $0.tintColor = .orange
    }
    
    public let dropdownTableView = UITableView().then {
        $0.backgroundColor = UIColor(red: 45/255, green: 45/255, blue: 45/255, alpha: 1)
        $0.isHidden = true
        $0.layer.cornerRadius = 10
        $0.register(UITableViewCell.self, forCellReuseIdentifier: "dropdownCell")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) { fatalError() }

    private func setupLayout() {
        // 배경은 투명하게 해서 뒤의 지도가 보이게 설정
        self.backgroundColor = .clear
        
        addSubview(containerView)
        [backButton, startLabel, startDropdownButton, reverseButton, endLabel, endLocationLabel, dropdownTableView].forEach {
            containerView.addSubview($0)
        }
        
        // 1. 컨테이너 위치: 위로 바짝 붙임
        containerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(endLocationLabel.snp.bottom).offset(24) // 디자인 여백 반영
        }
        
        // 2. 내부 요소 배치: 디자인 간격 정밀 조정
        backButton.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(0) // 최상단 밀착
            $0.leading.equalToSuperview().offset(16)
            $0.size.equalTo(44)
        }
        
        startLabel.snp.makeConstraints {
            $0.centerY.equalTo(backButton)
            $0.leading.equalTo(backButton.snp.trailing).offset(4)
        }
        
        startDropdownButton.snp.makeConstraints {
            $0.top.equalTo(backButton.snp.bottom).offset(4)
            $0.leading.equalToSuperview().offset(56)
            $0.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(44)
        }

        reverseButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(18)
            $0.centerY.equalTo(startDropdownButton.snp.bottom).offset(12)
        }

        endLabel.snp.makeConstraints {
            $0.top.equalTo(startDropdownButton.snp.bottom).offset(12)
            $0.leading.equalTo(startLabel)
        }
        
        endLocationLabel.snp.makeConstraints {
            $0.top.equalTo(endLabel.snp.bottom).offset(6)
            $0.leading.trailing.equalTo(startDropdownButton)
            $0.height.equalTo(44)
        }

        dropdownTableView.snp.makeConstraints {
            $0.top.equalTo(startDropdownButton.snp.bottom).offset(2)
            $0.leading.trailing.equalTo(startDropdownButton)
            $0.height.equalTo(88)
        }
    }

    public func updateLocation(start: String, end: String) {
        var config = startDropdownButton.configuration
        var titleAttr = AttributedString(start)
        titleAttr.font = .systemFont(ofSize: 14)
        config?.attributedTitle = titleAttr
        startDropdownButton.configuration = config
        endLocationLabel.text = "  \(end)"
    }
}
