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
        $0.alignment = .center
    }
    private let titleLabel = UILabel().then {
        $0.text = "최근 검색"
        $0.textColor = UIColor(red: 158/255, green: 158/255, blue: 158/255, alpha: 1)
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
    }
    
    private let clockIcon = UIImageView().then {
        $0.image = UIImage(named: "Time", in: Bundle.module, compatibleWith: nil)
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
        // 기록 리스트 배경을 탑바(31,31,31)보다 어둡게 설정
        self.backgroundColor = UIColor(red: 22/255, green: 22/255, blue: 22/255, alpha: 1)
        
        [titleStack, tableView].forEach { addSubview($0) }
        [titleLabel, clockIcon].forEach { titleStack.addArrangedSubview($0) }
        
        clockIcon.snp.makeConstraints { $0.size.equalTo(16) }
        
        titleStack.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20) // 서치바 아래 적당한 간격
            $0.leading.equalToSuperview().offset(24)
            $0.height.equalTo(20) // 최근검색 글자 높이 20
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(titleStack.snp.bottom).offset(16) // 회색선(간격) 16
            $0.leading.trailing.bottom.equalToSuperview() // 여기서 좌우를 0으로 밀어야 꽉 참
        }
    }
}
