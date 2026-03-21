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
    public let titleStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 6
        $0.alignment = .center
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "최근 검색"
        $0.textColor = UIColor.color.sub2.color
        $0.font = UIFont(name: "SUIT-Medium", size: 16) ?? .systemFont(ofSize: 16)
    }
    
    private let clockIcon = UIImageView().then {
        $0.image = UIImage(named: "Time", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        $0.tintColor = UIColor.color.sub2.color
    }
    
    public let tableView = UITableView().then {
        $0.backgroundColor = .clear
        $0.separatorStyle = .none
        $0.register(MapRecentSearchCell.self, forCellReuseIdentifier: MapRecentSearchCell.identifier)
        $0.rowHeight = 56
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupView() {
        self.backgroundColor = UIColor.color.surface.color
        [titleStack, tableView].forEach { addSubview($0) }
        [titleLabel, clockIcon].forEach { titleStack.addArrangedSubview($0) }
        
        clockIcon.snp.makeConstraints { $0.size.equalTo(18) }
        
        titleStack.snp.makeConstraints {
            $0.top.equalToSuperview().offset(134)
            $0.leading.equalToSuperview().offset(24)
            $0.height.equalTo(20)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(titleStack.snp.bottom).offset(10)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}
