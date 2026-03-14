//  MapViewController.swift
//  Feature
//
//  Created by 김민선 on 2/13/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit
import Then

// MARK: - Model (기존 유지)
struct ReviewModel {
    let name: String
    let info: String
    let content: String
    let date: String
}

public final class MapViewController: UIViewController {
    
    // MARK: - Dummy Data (기존 유지)
    private var dummyRecentSearches = ["메가MGC커피 광주송정시장점", "메가MGC커피 광주송정시장점", "메가MGC커피 광주송정시장점", "메가MGC커피 광주송정시장점"]
    private var dummyReviews: [ReviewModel] = [
        ReviewModel(name: "김민솔", info: "8기 | AI", content: "굳굳", date: "26.02.12"),
        ReviewModel(name: "권재현", info: "8기 | AI", content: "매워요", date: "26.02.12"),
        ReviewModel(name: "김태은", info: "8기 | AI", content: "맛있어요", date: "26.02.12"),
        ReviewModel(name: "이주언", info: "8기 | AI", content: "가성비 좋음", date: "26.02.12")
    ]
    
    // MARK: - UI Components (기존 유지)
    private let routeSelectionView = MapRouteSelectionView().then { $0.isHidden = true }
    private let searchBar = MapSearchBar()
    private let recentSearchView = MapRecentSearchView().then { $0.isHidden = true }
    private let bottomSheetView = MapBottomSheetView()
    private let tabBar = TabBar()
    private let placeDetailView = MapPlaceDetailView().then { $0.isHidden = true }
    
    private var bottomSheetHeight: Constraint?
    private var detailSheetHeight: Constraint?
    
    private let defaultHeight: CGFloat = 330
    private let detailMinHeight: CGFloat = 330

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
        setupDelegate()
        setupGesture()
        setupActions()
    }

    private func setupView() {
        view.backgroundColor = .color.background.color
        [bottomSheetView, recentSearchView, searchBar, routeSelectionView, placeDetailView, tabBar].forEach {
            view.addSubview($0)
        }
    }
    
    private func setupLayout() {
        routeSelectionView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.snp.top).offset(60)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(52)
        }
        
        recentSearchView.snp.makeConstraints { $0.edges.equalToSuperview() }
        recentSearchView.tableView.snp.remakeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(50)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(tabBar.snp.top)
        }
        
        tabBar.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(90)
        }
        
        bottomSheetView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            self.bottomSheetHeight = $0.height.equalTo(defaultHeight).constraint
        }
        
        placeDetailView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            self.detailSheetHeight = $0.height.equalTo(0).constraint
        }
    }
    
    private func setupDelegate() {
        // [오류 수정] routeSelectionView의 테이블뷰 참조 제거 (더 이상 테이블뷰가 아님)
        [recentSearchView.tableView, placeDetailView.tableView].forEach {
            $0.delegate = self
            $0.dataSource = self
        }
    }
    
    private func setupActions() {
        placeDetailView.closeButton.addTarget(self, action: #selector(hideDetailView), for: .touchUpInside)
        placeDetailView.arriveButton.addTarget(self, action: #selector(didTapArriveRoute), for: .touchUpInside)
        placeDetailView.startRouteButton.addTarget(self, action: #selector(didTapStartRoute), for: .touchUpInside)
        routeSelectionView.backButton.addTarget(self, action: #selector(backFromRouteSelection), for: .touchUpInside)
        
        bottomSheetView.onCardTapped = { [weak self] in self?.showDetailView() }
        searchBar.textField.addTarget(self, action: #selector(didTapSearchBar), for: .editingDidBegin)
        searchBar.backButton.addTarget(self, action: #selector(backToHome), for: .touchUpInside)
    }

    private func setupGesture() {
        let bottomSheetPan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        bottomSheetView.addGestureRecognizer(bottomSheetPan)
        let detailSheetPan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        placeDetailView.addGestureRecognizer(detailSheetPan)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let isDetail = gesture.view == placeDetailView
        let translation = gesture.translation(in: view)
        let currentHeight = isDetail ? placeDetailView.frame.height : bottomSheetView.frame.height
        let newHeight = currentHeight - translation.y
        let minH = defaultHeight
        let gap = dummyReviews.isEmpty ? 233 : 43
        let maxH = view.frame.height - (searchBar.frame.maxY + CGFloat(gap))
        
        if gesture.state == .changed {
            if newHeight >= minH && newHeight <= maxH {
                if isDetail { detailSheetHeight?.update(offset: newHeight) }
                else { bottomSheetHeight?.update(offset: newHeight) }
            }
        } else if gesture.state == .ended {
            let target = newHeight > (minH + maxH) / 2 ? maxH : minH
            UIView.animate(withDuration: 0.3) {
                if isDetail { self.detailSheetHeight?.update(offset: target) }
                else { self.bottomSheetHeight?.update(offset: target) }
                self.view.layoutIfNeeded()
            }
        }
        gesture.setTranslation(.zero, in: view)
    }

    private func showDetailView() {
        bottomSheetView.isHidden = true
        placeDetailView.isHidden = false
        view.layoutIfNeeded()
        detailSheetHeight?.update(offset: detailMinHeight)
        UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
    }

    @objc private func hideDetailView() {
        detailSheetHeight?.update(offset: 0)
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.placeDetailView.isHidden = true
            self.bottomSheetView.isHidden = false
        }
    }

    @objc private func backToHome() {
        hideDetailView()
        recentSearchView.isHidden = true
        searchBar.updateState(.home)
        view.endEditing(true)
    }

    @objc private func didTapSearchBar() {
        if !placeDetailView.isHidden { hideDetailView() }
        searchBar.updateState(.search)
        recentSearchView.isHidden = false
    }

    @objc private func didTapArriveRoute() {
        routeSelectionView.isHidden = false
        [searchBar, bottomSheetView, placeDetailView, recentSearchView].forEach { $0.isHidden = true }
    }

    @objc private func didTapStartRoute() {
        routeSelectionView.isHidden = false
        [searchBar, bottomSheetView, placeDetailView, recentSearchView].forEach { $0.isHidden = true }
    }

    @objc private func backFromRouteSelection() {
        routeSelectionView.isHidden = true
        searchBar.isHidden = false
        placeDetailView.isHidden = false
    }
}

// MARK: - TableView Delegate & DataSource (기존 유지 및 오류 수정)
extension MapViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // [오류 수정] routeSelectionView 관련 테이블뷰 체크 제거
        return tableView == recentSearchView.tableView ? dummyRecentSearches.count : dummyReviews.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == recentSearchView.tableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MapRecentSearchCell", for: indexPath) as! MapRecentSearchCell
            cell.configure(title: dummyRecentSearches[indexPath.row], date: "카페")
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: MapReviewCell.identifier, for: indexPath) as! MapReviewCell
            let data = dummyReviews[indexPath.row]
            cell.configure(name: data.name, info: data.info, content: data.content, date: data.date)
            cell.onDeleteTap = { [weak self] in
                guard let self = self else { return }
                ReviewAlert.show(in: self, title: "후기 삭제", message: "정말 후기를 삭제하시겠습니까?") {
                    self.dummyReviews.remove(at: indexPath.row)
                    self.placeDetailView.tableView.reloadData()
                    ReviewAlert.show(in: self, title: "후기 삭제 완료", message: "후기가 정상적으로 삭제되었습니다.")
                }
            }
            cell.onReportTap = { [weak self] in
                guard let self = self else { return }
                ReviewAlert.show(in: self, title: "후기 신고", message: "이 후기를 신고하시겠습니까?") {
                    ReviewAlert.show(in: self, title: "후기 신고 완료", message: "신고가 접수되었습니다.")
                }
            }
            return cell
        }
    }
}
