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
    
    private let mainView = MapRouteDetailView()
    private var containerHeightConstraint: Constraint?
    private var isInitialLayout = true
    
    private var currentSteps: [RouteStepModel] = []
    
    public var routeTypeTitle: String = "추천"
    public var minSheetHeight: CGFloat = 330
    public var onDismiss: (() -> Void)?
    
    // 1. 추천 경로 데이터
    private let recommendationSteps: [RouteStepModel] = [
        RouteStepModel(turnType: .start, title: "출발", description: "학교"),
        RouteStepModel(turnType: .straight, title: "OO건물", description: "OO건물 까지 100m 이동"),
        RouteStepModel(turnType: .left, title: "OO건물", description: "OO건물 앞에서 왼쪽길로 4m 이동"),
        RouteStepModel(turnType: .right, title: "**건물", description: "**건물 앞에서 오른쪽길로 4m 이동"),
        RouteStepModel(turnType: .end, title: "도착", description: "짬뽕관 광주송정선운점")
    ]
    
    // 2. 큰길 우선 데이터
    private let mainRoadSteps: [RouteStepModel] = [
        RouteStepModel(turnType: .start, title: "출발", description: "학교 정문"),
        RouteStepModel(turnType: .straight, title: "큰대로변", description: "대로를 따라 300m 직진"),
        RouteStepModel(turnType: .right, title: "사거리", description: "우회전 후 50m 이동"),
        RouteStepModel(turnType: .end, title: "도착", description: "짬뽕관 광주송정선운점")
    ]

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupView()
        setupDelegate()
        setupActions()
        setupGesture()
        configureData()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if isInitialLayout {
            let targetHeight = view.frame.height * 0.75
            containerHeightConstraint?.update(offset: targetHeight)
            isInitialLayout = false
        }
    }
    
    private func setupView() {
        view.addSubview(mainView)
        mainView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        mainView.containerView.snp.remakeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            self.containerHeightConstraint = $0.height.equalTo(minSheetHeight).constraint
        }
    }

    private func setupDelegate() {
        mainView.tableView.delegate = self
        mainView.tableView.dataSource = self
    }
    
    private func setupActions() {
        mainView.closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
    }

    private func setupGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        mainView.containerView.addGestureRecognizer(panGesture)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let currentHeight = mainView.containerView.frame.height
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
        if routeTypeTitle.contains("추천") {
            mainView.routeTypeLabel.text = "추천 경로"
            currentSteps = recommendationSteps
            mainView.timeLabel.text = "8분"
            mainView.infoLabel.text = "339m | 25kcal"
        } else {
            mainView.routeTypeLabel.text = "큰길 우선 경로"
            currentSteps = mainRoadSteps
            mainView.timeLabel.text = "10분"
            mainView.infoLabel.text = "450m | 30kcal"
        }
        
        mainView.tableView.reloadData()
    }
    
    @objc private func didTapCloseButton() {
        self.dismiss(animated: true) { [weak self] in
            self?.onDismiss?()
        }
    }
}

extension MapRouteDetailViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentSteps.count
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RouteStepCell.identifier, for: indexPath) as? RouteStepCell else {
            return UITableViewCell()
        }
        cell.configure(with: currentSteps[indexPath.row])
        return cell
    }
}
