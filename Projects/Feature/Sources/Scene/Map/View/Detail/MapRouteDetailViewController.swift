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

        var previousPoint: (lat: Double, lng: Double)?
        var accumulatedDistance: Int = 0

        for section in route.sections {
            for road in section.roads {
                let v = road.vertexes

                for i in stride(from: 0, to: v.count - 2, by: 2) {
                    if i + 3 >= v.count { break }
                    let current = (lat: v[i + 1], lng: v[i])
                    let next = (lat: v[i + 3], lng: v[i + 2])

                    var direction: RouteTurnType = .straight
                    var title = "직진"

                    if let prev = previousPoint {
                        let angle = calculateAngle(prev: prev, current: current, next: next)

                        if angle > 30 {
                            direction = .right
                            title = "우회전"
                        } else if angle < -30 {
                            direction = .left
                            title = "좌회전"
                        }
                    }

                    let distance = calculateDistance(from: current, to: next)

                    if direction == .straight {
                        accumulatedDistance += distance
                    } else {
                        
                        if accumulatedDistance > 0 {
                            steps.append(
                                RouteStepModel(
                                    turnType: .straight,
                                    title: "직진",
                                    description: "\(accumulatedDistance)m 이동"
                                )
                            )
                            accumulatedDistance = 0
                        }

                      
                        steps.append(
                            RouteStepModel(
                                turnType: direction,
                                title: title,
                                description: "\(distance)m 이동"
                            )
                        )
                    }

                    previousPoint = current
                }
            }
        }

       
        if steps.count == 1 {
            steps.append(
                RouteStepModel(
                    turnType: .straight,
                    title: "직진",
                    description: "\(max(1, summary.distance))m 이동"
                )
            )
        }

    
        if accumulatedDistance > 0 {
            steps.append(
                RouteStepModel(
                    turnType: .straight,
                    title: "직진",
                    description: "\(accumulatedDistance)m 이동"
                )
            )
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

    private func calculateAngle(
        prev: (lat: Double, lng: Double),
        current: (lat: Double, lng: Double),
        next: (lat: Double, lng: Double)
    ) -> Double {

        let v1 = (
            x: current.lng - prev.lng,
            y: current.lat - prev.lat
        )

        let v2 = (
            x: next.lng - current.lng,
            y: next.lat - current.lat
        )

        let dot = v1.x * v2.x + v1.y * v2.y
        let det = v1.x * v2.y - v1.y * v2.x

        return atan2(det, dot) * 180 / .pi
    }

private func calculateDistance(
    from: (lat: Double, lng: Double),
    to: (lat: Double, lng: Double)
) -> Int {
    let lat1 = from.lat * .pi / 180
    let lon1 = from.lng * .pi / 180
    let lat2 = to.lat * .pi / 180
    let lon2 = to.lng * .pi / 180

    let dLat = lat2 - lat1
    let dLon = lon2 - lon1

    let a = sin(dLat/2) * sin(dLat/2) +
            cos(lat1) * cos(lat2) *
            sin(dLon/2) * sin(dLon/2)

    let c = 2 * atan2(sqrt(a), sqrt(1 - a))
    let distance = 6371000 * c

    return Int(distance)
}
