//
//  MapRecentSearchView.swift
//  Feature
//
//  Created by 김민선 on 2/17/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit
import Then

public final class MapRecentSearchView: UIView {
    
    private let titleStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "최근 검색"
        $0.textColor = UIColor(red: 158/255, green: 158/255, blue: 158/255, alpha: 1)
        $0.font = .systemFont(ofSize: 12)
    }
    
    private let clockIcon = UIImageView().then {
        $0.image = UIImage(systemName: "clock.arrow.circlepath")
        $0.tintColor = UIColor(red: 158/255, green: 158/255, blue: 158/255, alpha: 1)
        $0.snp.makeConstraints { $0.size.equalTo(14) }
    }
    
    public let tableView = UITableView().then {
        $0.backgroundColor = .clear
        $0.separatorStyle = .none
        $0.register(MapRecentSearchCell.self, forCellReuseIdentifier: MapRecentSearchCell.identifier)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupView() {
        self.backgroundColor = UIColor(red: 31/255, green: 31/255, blue: 31/255, alpha: 1) // 다크 배경
        
        [titleStack, tableView].forEach { addSubview($0) }
        [titleLabel, clockIcon].forEach { titleStack.addArrangedSubview($0) }
        
        titleStack.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(20)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(titleStack.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}
