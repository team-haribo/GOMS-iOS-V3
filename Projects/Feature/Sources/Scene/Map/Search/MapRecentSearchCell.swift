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
    
    // 삭제 버튼 클릭 시 실행할 클로저 추가
    public var onDeleteTap: (() -> Void)?
    
    private let pinIcon = UIImageView().then {
        $0.image = UIImage(systemName: "mappin.circle")
        $0.tintColor = UIColor(red: 95/255, green: 95/255, blue: 95/255, alpha: 1)
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 14, weight: .regular)
    }
    
    private let dateLabel = UILabel().then {
        $0.textColor = UIColor(red: 95/255, green: 95/255, blue: 95/255, alpha: 1)
        $0.font = .systemFont(ofSize: 12)
    }
    
    private let deleteButton = UIButton().then {
        $0.setImage(UIImage(systemName: "xmark"), for: .normal)
        $0.tintColor = UIColor(red: 95/255, green: 95/255, blue: 95/255, alpha: 1)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupActions()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupView() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        [pinIcon, titleLabel, dateLabel, deleteButton].forEach { contentView.addSubview($0) }
        
        pinIcon.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(20)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(pinIcon.snp.trailing).offset(12)
            $0.centerY.equalToSuperview()
        }
        
        deleteButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(20)
        }
        
        dateLabel.snp.makeConstraints {
            $0.trailing.equalTo(deleteButton.snp.leading).offset(-12)
            $0.centerY.equalToSuperview()
        }
    }
    
    private func setupActions() {
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }
    
    @objc private func deleteButtonTapped() {
        onDeleteTap?()
    }
    
    public func configure(title: String, date: String) {
        titleLabel.text = title
        dateLabel.text = date
    }
}
