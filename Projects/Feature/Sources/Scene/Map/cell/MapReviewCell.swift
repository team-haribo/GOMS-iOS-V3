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
    
    public var onDeleteTap: (() -> Void)?
    public var onReportTap: (() -> Void)?
    
    // MARK: - UI Components
    private let profileImageView = UIImageView().then {
        $0.image = UIImage(systemName: "person.circle.fill")
        $0.tintColor = .lightGray
        $0.layer.cornerRadius = 24
        $0.clipsToBounds = true
    }
    
    private let nameLabel = UILabel().then {
        $0.textColor = .white // 이미지 가이드 반영: 흰색
        $0.font = .systemFont(ofSize: 20, weight: .bold)
    }
    
    private let infoLabel = UILabel().then {
        $0.textColor = UIColor(red: 176/255, green: 176/255, blue: 176/255, alpha: 1)
        $0.font = .systemFont(ofSize: 16)
    }
    
    private let contentLabel = UILabel().then {
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 16)
        $0.numberOfLines = 0
    }
    
    private let dateLabel = UILabel().then {
        $0.textColor = UIColor(red: 95/255, green: 95/255, blue: 95/255, alpha: 1)
        $0.font = .systemFont(ofSize: 15)
    }
    
    public let reportButton = UIButton().then {
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        $0.setImage(UIImage(systemName: "exclamationmark.circle", withConfiguration: config), for: .normal)
        $0.tintColor = UIColor(red: 95/255, green: 95/255, blue: 95/255, alpha: 1)
    }
    
    public let deleteButton = UIButton().then {
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        $0.setImage(UIImage(systemName: "trash", withConfiguration: config), for: .normal)
        $0.tintColor = UIColor(red: 95/255, green: 95/255, blue: 95/255, alpha: 1)
        $0.isHidden = true
    }
    
    private let cellDivider = UIView().then {
        $0.backgroundColor = UIColor(red: 45/255, green: 45/255, blue: 45/255, alpha: 1)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setLayout()
        setupActions()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupView() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        [profileImageView, nameLabel, infoLabel, contentLabel, dateLabel, reportButton, deleteButton, cellDivider].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setLayout() {
        profileImageView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(16)
            $0.size.equalTo(48)
        }
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(12)
        }
        infoLabel.snp.makeConstraints {
            $0.centerY.equalTo(nameLabel)
            $0.leading.equalTo(nameLabel.snp.trailing).offset(8)
        }
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(8)
            $0.leading.equalTo(nameLabel)
            $0.trailing.equalToSuperview().inset(50)
        }
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(contentLabel.snp.bottom).offset(8)
            $0.leading.equalTo(nameLabel)
            $0.bottom.equalToSuperview().inset(20)
        }
        [reportButton, deleteButton].forEach {
            $0.snp.makeConstraints { make in
                make.top.equalTo(profileImageView).offset(4)
                make.trailing.equalToSuperview().inset(16)
                make.size.equalTo(28)
            }
        }
        cellDivider.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    
    private func setupActions() {
        reportButton.addTarget(self, action: #selector(reportTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
    }
    
    @objc private func reportTapped() { onReportTap?() }
    @objc private func deleteTapped() { onDeleteTap?() }
    
    public func configure(name: String, info: String, content: String, date: String) {
        nameLabel.text = name
        infoLabel.text = info
        contentLabel.text = content
        dateLabel.text = date
        
        if name == "김민솔" {
            deleteButton.isHidden = false
            reportButton.isHidden = true
        } else {
            deleteButton.isHidden = true
            reportButton.isHidden = false
        }
    }
}
