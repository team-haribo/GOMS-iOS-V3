//
//  ReportDetailViewController.swift
//  Feature
//
//  Created by 김민선 on 3/29/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit
import Then

public final class ReportDetailViewController: BaseViewController {
    
    // MARK: - UI Components
    private lazy var backButton = UIButton().then {
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        $0.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        $0.setTitle(" 돌아가기", for: .normal)
        $0.setTitleColor(UIColor.color.admin.color, for: .normal)
        $0.tintColor = UIColor.color.admin.color
        $0.titleLabel?.font = .suit(size: 18, weight: .medium)
        $0.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }

    // 학생 정보 섹션 (셀 스타일과 통일)
    private let profileImageView = UIImageView().then {
        $0.backgroundColor = UIColor.color.sub1.color.withAlphaComponent(0.2)
        $0.layer.cornerRadius = 32
        $0.clipsToBounds = true
    }
    
    private let nameLabel = UILabel().then {
        $0.text = "김민선"
        $0.font = .suit(size: 20, weight: .bold)
        $0.textColor = UIColor.color.mainText.color
    }
    
    private let infoLabel = UILabel().then {
        $0.text = "3기 | AI과"
        $0.font = .suit(size: 16, weight: .medium)
        $0.textColor = UIColor.color.sub1.color
    }

    // 신고 상세 섹션
    private let contentTitleLabel = UILabel().then {
        $0.text = "신고 내용"
        $0.font = .suit(size: 18, weight: .bold)
        $0.textColor = UIColor.color.mainText.color
    }
    
    private let contentLabel = UILabel().then {
        $0.text = "무단 외출 후 복귀하지 않았습니다."
        $0.font = .suit(size: 16, weight: .regular)
        $0.textColor = UIColor.color.mainText.color
        $0.numberOfLines = 0
    }
    
    private let locationTitleLabel = UILabel().then {
        $0.text = "신고 장소"
        $0.font = .suit(size: 18, weight: .bold)
        $0.textColor = UIColor.color.mainText.color
    }
    
    private let locationLabel = UILabel().then {
        $0.text = "담소"
        $0.font = .suit(size: 16, weight: .regular)
        $0.textColor = UIColor.color.mainText.color
    }
    
    private let timeTitleLabel = UILabel().then {
        $0.text = "신고 시간"
        $0.font = .suit(size: 18, weight: .bold)
        $0.textColor = UIColor.color.mainText.color
    }
    
    private let timeLabel = UILabel().then {
        $0.text = "2026.03.29 14:30"
        $0.font = .suit(size: 16, weight: .regular)
        $0.textColor = UIColor.color.mainText.color
    }

    // MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @objc private func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }

    public override func addView() {
        [
            backButton, profileImageView, nameLabel, infoLabel,
            contentTitleLabel, contentLabel,
            locationTitleLabel, locationLabel,
            timeTitleLabel, timeLabel
        ].forEach { view.addSubview($0) }
    }

    public override func setLayout() {
        backButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.equalToSuperview().offset(20)
        }
        
        // 프로필 중앙 배치
        profileImageView.snp.makeConstraints {
            $0.top.equalTo(backButton.snp.bottom).offset(40)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(64)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }
        
        infoLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
        }
        
        // 신고 내용
        contentTitleLabel.snp.makeConstraints {
            $0.top.equalTo(infoLabel.snp.bottom).offset(48)
            $0.leading.equalToSuperview().inset(24)
        }
        
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(contentTitleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        
        // 장소
        locationTitleLabel.snp.makeConstraints {
            $0.top.equalTo(contentLabel.snp.bottom).offset(32)
            $0.leading.equalToSuperview().inset(24)
        }
        
        locationLabel.snp.makeConstraints {
            $0.top.equalTo(locationTitleLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().inset(24)
        }
        
        // 시간
        timeTitleLabel.snp.makeConstraints {
            $0.top.equalTo(locationLabel.snp.bottom).offset(32)
            $0.leading.equalToSuperview().inset(24)
        }
        
        timeLabel.snp.makeConstraints {
            $0.top.equalTo(timeTitleLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().inset(24)
        }
    }
}
