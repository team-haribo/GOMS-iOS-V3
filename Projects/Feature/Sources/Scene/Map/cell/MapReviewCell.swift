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
    
    private let profileImageView = UIImageView().then {
        $0.image = UIImage(named: "New_jeans", in: Bundle.module, compatibleWith: nil)
        $0.layer.cornerRadius = 24
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .systemGray6
    }
    
    private let nameLabel = UILabel().then {
        $0.textColor = .label
        $0.font = .systemFont(ofSize: 18, weight: .bold)
    }
    
    private let infoLabel = UILabel().then {
        $0.textColor = .color.sub2.color
        $0.font = .systemFont(ofSize: 15, weight: .medium)
    }
    
    private let contentLabel = UILabel().then {
        $0.textColor = .color.sub2.color
        $0.font = .systemFont(ofSize: 17, weight: .medium)
        $0.numberOfLines = 0
    }
    
    private let dateLabel = UILabel().then {
        $0.textColor = .color.sub2.color
        $0.font = .systemFont(ofSize: 15, weight: .medium)
    }
    
    public let reportButton = UIButton().then {
        $0.setImage(UIImage(named: "Warning", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = .color.sub2.color
    }
    
    public let deleteButton = UIButton().then {
        $0.setImage(UIImage(named: "Trash", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = .color.sub2.color
        $0.isHidden = true
    }
    
    private let cellDivider = UIView().then {
        $0.backgroundColor = .color.sub2.color.withAlphaComponent(0.2)
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
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(24)
            $0.size.equalTo(48)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(18)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(16)
        }
        
        infoLabel.snp.makeConstraints {
            $0.centerY.equalTo(nameLabel)
            $0.leading.equalTo(nameLabel.snp.trailing).offset(8)
        }
        
        [reportButton, deleteButton].forEach {
            $0.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.trailing.equalToSuperview().inset(36)
                $0.size.equalTo(24)
            }
        }
        
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(4)
            $0.leading.equalTo(nameLabel)
            $0.trailing.equalTo(reportButton.snp.leading).offset(-16)
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(contentLabel.snp.bottom).offset(4)
            $0.leading.equalTo(nameLabel)
            $0.bottom.equalToSuperview().inset(18)
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
    
    public func configure(profileImageName: String = "New_jeans", name: String, info: String, content: String, date: String) {
        profileImageView.image = UIImage(named: profileImageName, in: Bundle.module, compatibleWith: nil)
        nameLabel.text = name
        infoLabel.text = info
        contentLabel.text = content
        dateLabel.text = date
        
        let isMyReview = (name == "김민솔")
        deleteButton.isHidden = !isMyReview
        reportButton.isHidden = isMyReview
    }
}
