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
    private let containerView = UIView().then {
        $0.backgroundColor = UIColor(red: 45/255, green: 45/255, blue: 45/255, alpha: 1)
        $0.layer.cornerRadius = 12
        $0.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    
    public let backButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        $0.tintColor = .white
        $0.isUserInteractionEnabled = true // 터치 보장
    }
    
    private let startLabel = UILabel().then {
        $0.text = "출발"; $0.textColor = .lightGray; $0.font = .systemFont(ofSize: 12)
    }

    private let endLabel = UILabel().then {
        $0.text = "도착"; $0.textColor = .lightGray; $0.font = .systemFont(ofSize: 12)
    }
    
    public let startDropdownButton = UIButton().then {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = UIColor(red: 55/255, green: 55/255, blue: 55/255, alpha: 1)
        config.baseForegroundColor = .white
        var titleAttr = AttributedString("출발 위치를 선택해주세요")
        titleAttr.font = .systemFont(ofSize: 14)
        config.attributedTitle = titleAttr
        $0.configuration = config
        $0.contentHorizontalAlignment = .left
        $0.layer.cornerRadius = 8
    }
    
    public let endLocationLabel = UILabel().then {
        $0.textColor = .white; $0.font = .systemFont(ofSize: 14)
        $0.backgroundColor = UIColor(red: 55/255, green: 55/255, blue: 55/255, alpha: 1)
        $0.layer.cornerRadius = 8; $0.clipsToBounds = true
    }
    
    public let reverseButton = UIButton().then {
        $0.setImage(UIImage(systemName: "arrow.up.arrow.down"), for: .normal)
        $0.tintColor = .orange
    }
    
    public let dropdownTableView = UITableView().then {
        $0.backgroundColor = UIColor(red: 55/255, green: 55/255, blue: 55/255, alpha: 1)
        $0.isHidden = true
        $0.layer.cornerRadius = 8
        $0.register(UITableViewCell.self, forCellReuseIdentifier: "dropdownCell")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    private func setupLayout() {
        addSubview(containerView)
        // 필요한 모든 뷰를 containerView에 추가
        [backButton, reverseButton, startLabel, endLabel, startDropdownButton, endLocationLabel, dropdownTableView].forEach {
            containerView.addSubview($0)
        }
        
        containerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(endLocationLabel.snp.bottom).offset(24)
        }
        
        // 뒤로가기 버튼: safeArea 기준 상단 배치
        backButton.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(10)
            $0.leading.equalToSuperview().offset(16)
            $0.size.equalTo(44)
        }
        
        // 출발 글씨: 뒤로가기 버튼 바로 옆
        startLabel.snp.makeConstraints {
            $0.centerY.equalTo(backButton)
            $0.leading.equalTo(backButton.snp.trailing).offset(4)
        }
        
        // 출발 입력 박스: 뒤로가기 버튼 아래로 밀착해서 상단 여백 최소화
        startDropdownButton.snp.makeConstraints {
            $0.top.equalTo(backButton.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(56) // 뒤로가기 아이콘 너비만큼 띄움
            $0.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(44)
        }

        reverseButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalTo(startDropdownButton.snp.bottom).offset(10)
        }

        endLabel.snp.makeConstraints {
            $0.top.equalTo(startDropdownButton.snp.bottom).offset(12)
            $0.leading.equalTo(startLabel)
        }
        
        endLocationLabel.snp.makeConstraints {
            $0.top.equalTo(endLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalTo(startDropdownButton)
            $0.height.equalTo(44)
        }

        dropdownTableView.snp.makeConstraints {
            $0.top.equalTo(startDropdownButton.snp.bottom).offset(2)
            $0.leading.trailing.equalTo(startDropdownButton)
            $0.height.equalTo(88)
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }

    public func updateLocation(start: String, end: String) {
        var config = startDropdownButton.configuration
        var titleAttr = AttributedString(start)
        titleAttr.font = .systemFont(ofSize: 14)
        config?.attributedTitle = titleAttr
        startDropdownButton.configuration = config
        endLocationLabel.text = "  \(end)"
    }
}
