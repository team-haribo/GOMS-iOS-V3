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

final class PassthroughView: UIView {
    let contentView = MapRouteDetailView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let targetView = contentView.containerView
        let convertedPoint = targetView.convert(point, from: self)

        if targetView.bounds.contains(convertedPoint) {
            return targetView.hitTest(convertedPoint, with: event)
        }
        return nil
    }
}

public final class MapRouteDetailViewController: UIViewController {

    public override func loadView() {
        self.view = mainView
    }
    
    private let mainView = PassthroughView()
    private var containerHeightConstraint: Constraint?
    private var isInitialLayout = true
    
    private var currentSteps: [RouteStepModel] = []
    
    public var routeTypeTitle: String = "추천"
    public var destinationName: String = ""
    public var minSheetHeight: CGFloat = 330
    public var onDismiss: (() -> Void)?
    
    public var routeResult: MapRouteModel? {
        didSet {
            configureData()
        }
    }
    
    private var recommendationSteps: [RouteStepModel] {
        return [
            RouteStepModel(turnType: .start, title: "출발", description: "학교"),
            RouteStepModel(turnType: .straight, title: "OO건물", description: "OO건물 까지 100m 이동"),
            RouteStepModel(turnType: .left, title: "OO건물", description: "OO건물 앞에서 왼쪽길로 4m 이동"),
            RouteStepModel(turnType: .right, title: "**건물", description: "**건물 앞에서 오른쪽길로 4m 이동"),
            RouteStepModel(turnType: .end, title: "도착", description: destinationName.isEmpty ? "목적지" : destinationName)
        ]
    }
    private var mainRoadSteps: [RouteStepModel] {
        return [
            RouteStepModel(turnType: .start, title: "출발", description: "학교 정문"),
            RouteStepModel(turnType: .straight, title: "큰대로변", description: "대로를 따라 300m 직진"),
            RouteStepModel(turnType: .right, title: "사거리", description: "우회전 후 50m 이동"),
            RouteStepModel(turnType: .end, title: "도착", description: destinationName.isEmpty ? "목적지" : destinationName)
        ]
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        mainView.isUserInteractionEnabled = true
        setupView()
        setupDelegate()
        setupActions()
        setupGesture()
        configureData()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if isInitialLayout {
            let targetHeight = minSheetHeight
            containerHeightConstraint?.update(offset: targetHeight)
            isInitialLayout = false
        }
    }
    
    private func setupView() {
        mainView.isUserInteractionEnabled = true
        mainView.backgroundColor = .clear

       
        mainView.contentView.containerView.backgroundColor = .color.surface.color

        mainView.contentView.containerView.snp.remakeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            self.containerHeightConstraint = $0.height.equalTo(minSheetHeight).constraint
        }
    }

    private func setupDelegate() {
        mainView.contentView.tableView.delegate = self
        mainView.contentView.tableView.dataSource = self
    }
    
    private func setupActions() {
        mainView.contentView.closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
    }

    private func setupGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        mainView.contentView.containerView.addGestureRecognizer(panGesture)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let currentHeight = mainView.contentView.containerView.frame.height
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
        guard let route = routeResult?.routes.first else {
            if routeTypeTitle.contains("추천") {
                mainView.contentView.routeTypeLabel.text = "추천 경로"
                currentSteps = recommendationSteps
                mainView.contentView.timeLabel.text = "8분"
                mainView.contentView.infoLabel.text = "339m | 25kcal"
            } else {
                mainView.contentView.routeTypeLabel.text = "큰길 우선 경로"
                currentSteps = mainRoadSteps
                mainView.contentView.timeLabel.text = "10분"
                mainView.contentView.infoLabel.text = "450m | 30kcal"
            }
            mainView.contentView.tableView.reloadData()
            return
        }

        let summary = route.summary

        mainView.contentView.routeTypeLabel.text = routeTypeTitle
        let minutes = Int(ceil(Double(summary.duration) / 60.0))
        mainView.contentView.timeLabel.text = "\(max(1, minutes))분"
        mainView.contentView.infoLabel.text = "\(summary.distance)m"

        var steps: [RouteStepModel] = []
        steps.append(RouteStepModel(turnType: .start, title: "출발", description: "학교"))
        for section in route.sections {
            for road in section.roads {
                let distance = road.vertexes.count / 2
                steps.append(
                    RouteStepModel(
                        turnType: .straight,
                        title: "이동",
                        description: "\(distance)m 이동"
                    )
                )
            }
        }
        steps.append(
            RouteStepModel(
                turnType: .end,
                title: "도착",
                description: destinationName.isEmpty ? "목적지" : destinationName
            )
        )
        currentSteps = steps
        mainView.contentView.tableView.reloadData()
    }
    
    @objc private func didTapCloseButton() {
        self.willMove(toParent: nil)
        self.view.removeFromSuperview()
        self.removeFromParent()
        
        onDismiss?()
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
