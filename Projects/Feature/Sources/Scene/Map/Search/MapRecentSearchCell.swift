//
//  MapRecentSearchCell.swift
//  Feature
//
//  Created by 김민선 on 2/17/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit
import Then

public final class MapRecentSearchCell: UITableViewCell {
    static let identifier = "MapRecentSearchCell"
    public var onDeleteTap: (() -> Void)?
    
    private let pinIcon = UIImageView().then {
        $0.image = UIImage(named: "Destination", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        $0.tintColor = UIColor.color.sub2.color
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = UIColor.color.sub1.color
        // [수정] 장소 글자 크기 16
        $0.font = UIFont(name: "SUIT-Medium", size: 16) ?? .systemFont(ofSize: 16)
    }
    
    private let dateLabel = UILabel().then {
        $0.textColor = UIColor.color.sub2.color
        $0.font = UIFont(name: "SUIT-Medium", size: 14) ?? .systemFont(ofSize: 14)
        $0.textAlignment = .right
    }
    
    private let deleteButton = UIButton().then {
        $0.setImage(
            UIImage(named: "cancelButton", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        $0.tintColor = UIColor.color.sub2.color
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        setupView()
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupView() {
        self.selectionStyle = .none
        [pinIcon, titleLabel, dateLabel, deleteButton].forEach { contentView.addSubview($0) }
        
        pinIcon.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24) // [고정] 24x24
        }
        
        deleteButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-24)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(20) // [고정] 20x20
        }
        
        dateLabel.snp.makeConstraints {
            $0.trailing.equalTo(deleteButton.snp.leading).offset(-12)
            $0.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(pinIcon.snp.trailing).offset(12)
            $0.trailing.equalTo(dateLabel.snp.leading).offset(-8)
            $0.centerY.equalToSuperview()
        }
    }
    
    @objc private func deleteButtonTapped() { onDeleteTap?() }
    
    public func configure(title: String, date: String) {
        titleLabel.text = title
        dateLabel.text = date
    }
}
