//
//  MapReviewCell.swift
//  Feature
//
//  Created by 김민선 on 2/20/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit
import Then

public final class MapReviewCell: UITableViewCell {
    static let identifier = "MapReviewCell"
    
    // MARK: - Actions
    // 컨트롤러에서 팝업을 띄우기 위해 연결할 클로저입니다
    public var onDeleteTap: (() -> Void)?
    public var onReportTap: (() -> Void)?
    
    // MARK: - UI Components
    private let profileImageView = UIImageView().then {
        $0.image = UIImage(systemName: "person.circle.fill")
        $0.tintColor = .lightGray
        $0.layer.cornerRadius = 18
        $0.clipsToBounds = true
    }
    
    private let nameLabel = UILabel().then {
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 14, weight: .bold)
    }
    
    private let infoLabel = UILabel().then {
        $0.textColor = UIColor(red: 160/255, green: 160/255, blue: 160/255, alpha: 1)
        $0.font = .systemFont(ofSize: 12)
    }
    
    private let contentLabel = UILabel().then {
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 13)
        $0.numberOfLines = 0
    }
    
    private let dateLabel = UILabel().then {
        $0.textColor = UIColor(red: 95/255, green: 95/255, blue: 95/255, alpha: 1)
        $0.font = .systemFont(ofSize: 11)
    }
    
    // 신고 버튼 (기존 public 유지)
    public let reportButton = UIButton().then {
        $0.setImage(UIImage(systemName: "exclamationmark.circle"), for: .normal)
        $0.tintColor = UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 1)
    }
    
    // 삭제 버튼 추가 (시안의 쓰레기통 아이콘 대응)
    public let deleteButton = UIButton().then {
        $0.setImage(UIImage(systemName: "trash"), for: .normal)
        $0.tintColor = UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 1)
        $0.isHidden = true // 기본은 숨김 처리
    }

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setLayout()
        setupActions() // 버튼 액션 연결 추가
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupView() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        [profileImageView, nameLabel, infoLabel, contentLabel, dateLabel, reportButton, deleteButton].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setLayout() {
        profileImageView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(16)
            $0.size.equalTo(36)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(12)
        }
        
        infoLabel.snp.makeConstraints {
            $0.centerY.equalTo(nameLabel)
            $0.leading.equalTo(nameLabel.snp.trailing).offset(4)
        }
        
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(4)
            $0.leading.equalTo(nameLabel)
            $0.trailing.equalToSuperview().inset(40)
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(contentLabel.snp.bottom).offset(4)
            $0.leading.equalTo(nameLabel)
            $0.bottom.equalToSuperview().inset(16)
        }
        
        // 신고 버튼 위치
        reportButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(16)
            $0.size.equalTo(24)
        }
        
        // 삭제 버튼 위치 (신고 버튼과 같은 위치)
        deleteButton.snp.makeConstraints {
            $0.edges.equalTo(reportButton)
        }
    }
    
    // 버튼 액션 설정
    private func setupActions() {
        reportButton.addTarget(self, action: #selector(reportTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
    }
    
    @objc private func reportTapped() {
        onReportTap?()
    }
    
    @objc private func deleteTapped() {
        onDeleteTap?()
    }
    
    public func configure(name: String, info: String, content: String, date: String) {
        nameLabel.text = name
        infoLabel.text = info
        contentLabel.text = content
        dateLabel.text = date
        
        // 내 리뷰인지 여부에 따라 버튼 분기 처리 (현재는 테스트를 위해 첫 번째 셀만 삭제 버튼 노출)
        // 실제 데이터 연동 시에는 '작성자 == 나' 조건으로 처리합니다.
        if name == "김민솔" {
            deleteButton.isHidden = false
            reportButton.isHidden = true
        } else {
            deleteButton.isHidden = true
            reportButton.isHidden = false
        }
    }
}
