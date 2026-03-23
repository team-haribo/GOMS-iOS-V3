//
//  MapRouteDetailView.swift
//  Feature
//
//  Created by 김민선 on 3/16/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit
import Then

public final class MapRouteDetailView: UIView {
    
    let containerView = UIView().then {
        $0.backgroundColor = .color.surface.color
        $0.layer.cornerRadius = 20
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    let grabberView = UIView().then {
        $0.backgroundColor = .color.sub2.color.withAlphaComponent(0.3)
        $0.layer.cornerRadius = 2.5
    }
    
    let closeButton = UIButton().then {
        $0.setImage(UIImage(named: "cancelButton", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = .color.sub2.color
    }
    
    let routeTypeLabel = UILabel().then {
        $0.textColor = .color.mainText.color
        $0.font = .suit(size: 16, weight: .semibold)
    }
    
    let timeLabel = UILabel().then {
        $0.textColor = .color.mainText.color
        $0.font = .suit(size: 28, weight: .semibold)
    }
    
    let infoLabel = UILabel().then {
        $0.textColor = .color.sub2.color
        $0.font = .suit(size: 16, weight: .medium)
    }
    
    let tableView = UITableView().then {
        $0.separatorStyle = .none
        $0.backgroundColor = .clear
        $0.register(RouteStepCell.self, forCellReuseIdentifier: RouteStepCell.identifier)
        $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 120, right: 0)
        $0.showsVerticalScrollIndicator = false // 디자인을 위해 스크롤 바 숨김
    }
    
    let tabBar = TabBar()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupLayout() {
        addSubview(containerView)
        [tableView, grabberView, closeButton, routeTypeLabel, timeLabel, infoLabel, tabBar].forEach {
                containerView.addSubview($0)
            }
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        grabberView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(40); $0.height.equalTo(5)
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.size.equalTo(28)
        }
        
        routeTypeLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(60)
            $0.leading.equalToSuperview().offset(24)
        }
        
        timeLabel.snp.makeConstraints {
            $0.top.equalTo(routeTypeLabel.snp.bottom).offset(8)
            $0.leading.equalTo(routeTypeLabel)
        }
        
        infoLabel.snp.makeConstraints {
            $0.top.equalTo(timeLabel.snp.bottom).offset(4)
            $0.leading.equalTo(timeLabel)
        }
        
        tabBar.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(90)
        }
        
        tableView.snp.makeConstraints {
                $0.top.equalTo(infoLabel.snp.bottom).offset(24)
                $0.leading.trailing.equalToSuperview()
                $0.bottom.equalToSuperview()
            }
    }
}
