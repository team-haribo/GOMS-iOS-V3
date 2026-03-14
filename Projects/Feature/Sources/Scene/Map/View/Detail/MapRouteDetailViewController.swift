//
//  MapRouteDetailViewController.swift
//  Feature
//
//  Created by 김민선 on 3/15/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit
import Then

public final class MapRouteDetailViewController: UIViewController {
    
    public var routeTypeTitle: String = "추천 경로"
    public var minSheetHeight: CGFloat = 330
    public var onResetToHome: (() -> Void)?
    
    private let steps: [(String, String, String, Bool)] = [
        ("ic_route_location_pin", "출발", "학교", true),
        ("ic_route_straight", "OO건물", "OO건물 까지 100m 이동", true),
        ("ic_route_turn_left", "OO건물", "OO건물 앞에서 왼쪽길로 4m 이동", true),
        ("ic_route_turn_right", "**건물", "**건물 앞에서 오른쪽길로 4m 이동", true),
        ("ic_route_location_pin", "도착", "짬뽕관 광주송정선운점", false)
    ]
    
    private let containerView = UIView().then {
        $0.backgroundColor = .color.surface.color
        $0.layer.cornerRadius = 20
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    private let grabberView = UIView().then {
        $0.backgroundColor = .color.sub2.color.withAlphaComponent(0.3)
        $0.layer.cornerRadius = 2.5
    }
    
    private let closeButton = UIButton().then {
        $0.setImage(UIImage(named: "cancelButton", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = .color.sub2.color
    }
    
    private let routeTypeLabel = UILabel().then {
        $0.textColor = .color.mainText.color
        $0.font = .suit(size: 16, weight: .semibold)
    }
    
    private let timeLabel = UILabel().then {
        $0.textColor = .color.mainText.color
        $0.font = .suit(size: 28, weight: .semibold)
    }
    
    private let infoLabel = UILabel().then {
        $0.textColor = .color.sub2.color
        $0.font = .suit(size: 16, weight: .medium)
    }
    
    public let tableView = UITableView().then {
        $0.separatorStyle = .none
        $0.backgroundColor = .clear
        $0.register(MapRouteStepCell.self, forCellReuseIdentifier: "MapRouteStepCell")
        $0.isScrollEnabled = true
        $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 90, right: 0)
    }
    
    private let tabBar = TabBar()
    private var containerHeightConstraint: Constraint?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
        setupActions()
        setupGesture()
        configureData()
    }
    
    private func setupView() {
        view.backgroundColor = .clear
        view.addSubview(containerView)
        
        [grabberView, closeButton, routeTypeLabel, timeLabel, infoLabel, tableView, tabBar].forEach {
            containerView.addSubview($0)
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        containerView.bringSubviewToFront(tabBar)
    }
    
    private func setupLayout() {
        containerView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            self.containerHeightConstraint = $0.height.equalTo(view.frame.height * 0.75).constraint
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
    
    private func setupActions() {
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
    }

    private func setupGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        containerView.addGestureRecognizer(panGesture)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let currentHeight = containerView.frame.height
        let newHeight = currentHeight - translation.y
        let maxHeight = view.frame.height * 0.75
        
        if gesture.state == .changed {
            if newHeight >= minSheetHeight && newHeight <= maxHeight {
                containerHeightConstraint?.update(offset: newHeight)
            }
        } else if gesture.state == .ended {
            let target = newHeight > (minSheetHeight + maxHeight) / 2 ? maxHeight : minSheetHeight
            UIView.animate(withDuration: 0.3) {
                self.containerHeightConstraint?.update(offset: target)
                self.view.layoutIfNeeded()
            }
        }
        gesture.setTranslation(.zero, in: view)
    }
    
    private func configureData() {
        routeTypeLabel.text = routeTypeTitle
        timeLabel.text = "8분"
        infoLabel.text = "339m | 25kcal"
    }
    
    @objc private func didTapCloseButton() {
        self.dismiss(animated: true) {
            self.onResetToHome?()
        }
    }
}

extension MapRouteDetailViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return steps.count
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MapRouteStepCell", for: indexPath) as? MapRouteStepCell else {
            return UITableViewCell()
        }
        let step = steps[indexPath.row]
        cell.configure(iconName: step.0, title: step.1, subtitle: step.2, showLine: step.3)
        return cell
    }
}

class MapRouteStepCell: UITableViewCell {
    private let iconImageView = UIImageView().then { $0.contentMode = .scaleAspectFit }
    private let lineView = UIView().then { $0.backgroundColor = .color.sub2.color.withAlphaComponent(0.2) }
    private let titleLabel = UILabel().then {
        $0.textColor = .color.mainText.color
        $0.font = .suit(size: 16, weight: .semibold)
    }
    private let subtitleLabel = UILabel().then {
        $0.textColor = .color.sub2.color
        $0.font = .suit(size: 14, weight: .medium)
        $0.numberOfLines = 1
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        [lineView, iconImageView, titleLabel, subtitleLabel].forEach { contentView.addSubview($0) }
        
        iconImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(-10)
            $0.leading.equalToSuperview().offset(32)
            $0.size.equalTo(24)
        }
        lineView.snp.makeConstraints {
            $0.centerX.equalTo(iconImageView)
            $0.top.equalTo(iconImageView.snp.bottom).offset(4)
            $0.bottom.equalToSuperview()
            $0.width.equalTo(2)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(iconImageView)
            $0.leading.equalTo(iconImageView.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().offset(-24)
        }
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(2)
            $0.leading.equalTo(titleLabel)
            $0.trailing.equalTo(titleLabel)
        }
    }
    required init?(coder: NSCoder) { fatalError() }
    func configure(iconName: String, title: String, subtitle: String, showLine: Bool) {
        iconImageView.image = UIImage(named: iconName, in: Bundle.module, compatibleWith: nil)
        titleLabel.text = title
        subtitleLabel.text = subtitle
        lineView.isHidden = !showLine
    }
}
