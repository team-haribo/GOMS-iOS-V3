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
    
    public var routeTypeTitle: String = "추천 경로"
    public var minSheetHeight: CGFloat = 330
    public var onDismiss: (() -> Void)?
    
    private let steps: [RouteStepModel] = [
        RouteStepModel(turnType: .start, title: "출발", description: "학교"),
        RouteStepModel(turnType: .straight, title: "OO건물", description: "OO건물 까지 100m 이동"),
        RouteStepModel(turnType: .left, title: "OO건물", description: "OO건물 앞에서 왼쪽길로 4m 이동"),
        RouteStepModel(turnType: .right, title: "**건물", description: "**건물 앞에서 오른쪽길로 4m 이동"),
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
        mainView.routeTypeLabel.text = routeTypeTitle
        mainView.timeLabel.text = "8분"
        mainView.infoLabel.text = "339m | 25kcal"
    }
    
    @objc private func didTapCloseButton() {
        // [수정] 닫힐 때 onDismiss를 호출하여 MapViewController에 신호를 보냄
        self.dismiss(animated: true) { [weak self] in
            self?.onDismiss?()
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RouteStepCell.identifier, for: indexPath) as? RouteStepCell else {
            return UITableViewCell()
        }
        cell.configure(with: steps[indexPath.row])
        return cell
    }
}
