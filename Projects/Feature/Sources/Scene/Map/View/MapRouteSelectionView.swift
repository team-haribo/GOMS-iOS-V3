//
//  MapRouteSelectionView.swift
//  Feature
//
//  Created by 김민선 on 2/21/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit
import Then

public final class MapRouteSelectionView: UIView {
    
    private let locations = ["내 위치", "학교", "광주송정역"]
    
    private let containerView = UIView().then {
        $0.backgroundColor = UIColor(red: 25/255, green: 25/255, blue: 25/255, alpha: 1)
        $0.layer.cornerRadius = 12
        $0.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    
    public let backButton = UIButton().then {
        $0.setImage(UIImage(named: "Directional", in: Bundle.module, compatibleWith: nil), for: .normal)
    }
    
    private let startLabel = UILabel().then {
        $0.text = "출발"; $0.textColor = .lightGray; $0.font = .systemFont(ofSize: 14, weight: .medium)
    }

    private let endLabel = UILabel().then {
        $0.text = "도착"; $0.textColor = .lightGray; $0.font = .systemFont(ofSize: 14, weight: .medium)
    }
    
    public let startDropdownButton = UIButton().then {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = UIColor(red: 31/255, green: 31/255, blue: 31/255, alpha: 1)
        config.baseForegroundColor = .white
        var titleAttr = AttributedString("출발 위치를 선택해주세요")
        titleAttr.font = .systemFont(ofSize: 14)
        config.attributedTitle = titleAttr
        $0.setImage(UIImage(named: "Down directional", in: Bundle.module, compatibleWith: nil), for: .normal)
        config.imagePlacement = .trailing
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        $0.configuration = config
        $0.contentHorizontalAlignment = .fill
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
    }
    
    public let endLocationLabel = UILabel().then {
        $0.textColor = .white; $0.font = .systemFont(ofSize: 14)
        $0.backgroundColor = UIColor(red: 31/255, green: 31/255, blue: 31/255, alpha: 1)
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
        $0.text = "  짬뽕관 광주송정선운점"
    }
    
    public let reverseButton = UIButton().then {
        $0.setImage(UIImage(named: "Shift", in: Bundle.module, compatibleWith: nil), for: .normal)
        $0.tintColor = .orange
        $0.isUserInteractionEnabled = false
    }
    
    public let dropdownTableView = UITableView().then {
        $0.backgroundColor = UIColor(red: 31/255, green: 31/255, blue: 31/255, alpha: 1)
        $0.isHidden = true
        $0.layer.cornerRadius = 8
        $0.separatorStyle = .singleLine
        $0.separatorColor = .darkGray
        $0.register(UITableViewCell.self, forCellReuseIdentifier: "dropdownCell")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupActions()
        setupTableView()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupLayout() {
        self.backgroundColor = .clear
        addSubview(containerView)
        [backButton, startLabel, startDropdownButton, reverseButton, endLabel, endLocationLabel, dropdownTableView].forEach {
            containerView.addSubview($0)
        }
        
        containerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(238)
        }
        
        endLocationLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(20)
            $0.leading.equalToSuperview().offset(56)
            $0.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(52)
        }
        
        endLabel.snp.makeConstraints {
            $0.bottom.equalTo(endLocationLabel.snp.top).offset(-6)
            $0.leading.equalTo(endLocationLabel)
        }

        startDropdownButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(103)
            $0.leading.trailing.equalTo(endLocationLabel)
            $0.height.equalTo(52)
        }
        
        backButton.snp.makeConstraints {
            $0.centerY.equalTo(startLabel)
            $0.leading.equalToSuperview().offset(16)
            $0.size.equalTo(24)
        }

        startLabel.snp.makeConstraints {
            $0.bottom.equalTo(startDropdownButton.snp.top).offset(-6)
            $0.leading.equalTo(backButton.snp.trailing).offset(8)
        }

        reverseButton.snp.makeConstraints {
            $0.centerX.equalTo(backButton)
            $0.bottom.equalToSuperview().inset(87)
            $0.size.equalTo(24)
        }

        dropdownTableView.snp.makeConstraints {
            $0.top.equalTo(startDropdownButton.snp.bottom).offset(2)
            $0.leading.trailing.equalTo(startDropdownButton)
            $0.height.equalTo(120)
        }
    }

    private func setupActions() {
        startDropdownButton.addTarget(self, action: #selector(toggleDropdown), for: .touchUpInside)
    }

    private func setupTableView() {
        dropdownTableView.delegate = self
        dropdownTableView.dataSource = self
    }

    @objc private func toggleDropdown() {
        dropdownTableView.isHidden.toggle()
    }

    public func updateLocation(start: String? = nil, end: String? = nil) {
        guard let locationText = start else { return }
        
        var config = startDropdownButton.configuration
        var titleAttr = AttributedString(locationText)
        titleAttr.font = .systemFont(ofSize: 14)
        config?.attributedTitle = titleAttr
        startDropdownButton.configuration = config
        
        dropdownTableView.isHidden = true
    }
}

extension MapRouteSelectionView: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dropdownCell", for: indexPath)
        cell.textLabel?.text = locations[indexPath.row]
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = .systemFont(ofSize: 14)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        updateLocation(start: locations[indexPath.row])
    }
}
