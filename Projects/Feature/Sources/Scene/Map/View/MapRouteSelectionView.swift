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
        $0.backgroundColor = UIColor(red: 25/255, green: 25/255, blue: 25/255, alpha: 1) // #191919
        $0.layer.cornerRadius = 12
        $0.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    
    // ✅ 사이즈 24x24로 고정
    public let backButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        $0.tintColor = .white
    }
    
    // ✅ 텍스트 높이감 있게 폰트 사이즈 살짝 조정 (14pt)
    private let startLabel = UILabel().then {
        $0.text = "출발"; $0.textColor = .lightGray; $0.font = .systemFont(ofSize: 14, weight: .medium)
    }

    private let endLabel = UILabel().then {
        $0.text = "도착"; $0.textColor = .lightGray; $0.font = .systemFont(ofSize: 14, weight: .medium)
    }
    
    public let startDropdownButton = UIButton().then {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = UIColor(red: 31/255, green: 31/255, blue: 31/255, alpha: 1) // #1F1F1F
        config.baseForegroundColor = .white
        var titleAttr = AttributedString("출발 위치를 선택해주세요")
        titleAttr.font = .systemFont(ofSize: 14)
        config.attributedTitle = titleAttr
        config.image = UIImage(systemName: "chevron.down")
        config.imagePlacement = .trailing
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        $0.configuration = config
        $0.contentHorizontalAlignment = .fill
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
    }
    
    public let endLocationLabel = UILabel().then {
        $0.textColor = .white; $0.font = .systemFont(ofSize: 14)
        $0.backgroundColor = UIColor(red: 31/255, green: 31/255, blue: 31/255, alpha: 1) // #1F1F1F
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
        $0.text = "  짬뽕관 광주송정선운점"
    }
    
    // ✅ 사이즈 24x24, 틴트 오렌지
    public let reverseButton = UIButton().then {
        $0.setImage(UIImage(systemName: "arrow.up.arrow.down"), for: .normal)
        $0.tintColor = .orange
    }
    
    public let dropdownTableView = UITableView().then {
        $0.backgroundColor = UIColor(red: 31/255, green: 31/255, blue: 31/255, alpha: 1)
        $0.isHidden = true
        $0.layer.cornerRadius = 8
        $0.separatorStyle = .none
        $0.register(UITableViewCell.self, forCellReuseIdentifier: "dropdownCell")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) { fatalError() }

    private func setupLayout() {
        self.backgroundColor = .clear
        addSubview(containerView)
        [backButton, startLabel, startDropdownButton, reverseButton, endLabel, endLocationLabel, dropdownTableView].forEach {
            containerView.addSubview($0)
        }
        
        containerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(238)
        }
        
        // 📏 도착 박스: 하단에서 20 (민선 가이드)
        endLocationLabel.snp.makeConstraints {
            $0.bottom.equalTo(containerView.snp.bottom).inset(20)
            $0.leading.equalToSuperview().offset(56)
            $0.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(52)
        }
        
        endLabel.snp.makeConstraints {
            $0.bottom.equalTo(endLocationLabel.snp.top).offset(-6)
            $0.leading.equalTo(endLocationLabel)
        }

        // 📏 출발 박스: 하단에서 103 (민선 가이드)
        startDropdownButton.snp.makeConstraints {
            $0.bottom.equalTo(containerView.snp.bottom).inset(103)
            $0.leading.trailing.equalTo(endLocationLabel)
            $0.height.equalTo(52)
        }
        
        // ✅ 뒤로가기 버튼: 출발 박스 옆, 사이즈 24x24
        backButton.snp.makeConstraints {
            $0.centerY.equalTo(startLabel)
            $0.leading.equalToSuperview().offset(16)
            $0.size.equalTo(24)
        }

        startLabel.snp.makeConstraints {
            $0.bottom.equalTo(startDropdownButton.snp.top).offset(-6)
            $0.leading.equalTo(backButton.snp.trailing).offset(8)
        }

        // 📏 전환 아이콘: 하단에서 87, 사이즈 24x24 (민선 가이드)
        reverseButton.snp.makeConstraints {
            $0.centerX.equalTo(backButton)
            $0.bottom.equalTo(containerView.snp.bottom).inset(87)
            $0.size.equalTo(24)
        }

        dropdownTableView.snp.makeConstraints {
            $0.top.equalTo(startDropdownButton.snp.bottom).offset(2)
            $0.leading.trailing.equalTo(startDropdownButton)
            $0.height.equalTo(100)
        }
    }
    
    public func updateLocation(start: String? = nil, end: String? = nil) {
        if let startText = start {
            var config = startDropdownButton.configuration
            var titleAttr = AttributedString(startText)
            titleAttr.font = .systemFont(ofSize: 14)
            config?.attributedTitle = titleAttr
            startDropdownButton.configuration = config
        }
        if let endText = end {
            endLocationLabel.text = "  \(endText)"
        }
    }
}
