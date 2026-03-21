//  MapViewController.swift
//  Feature
//
//  Created by 김민선 on 2/13/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit
import Then

public final class MapViewController: UIViewController {
    
    private var dummyRecentSearches = MapMockData.recentSearches
    
    private var dummyReviews = MapMockData.reviews {
        didSet {
            self.placeDetailView.updateReviewCount(dummyReviews.count)
            self.placeDetailView.tableView.reloadData()
        }
    }
    
    private let routeSelectionView = MapRouteSelectionView().then { $0.isHidden = true }
    private let searchBar = MapSearchBar()
    
    private let recentSearchView = MapRecentSearchView().then {
        $0.isHidden = true
        $0.backgroundColor = .color.background.color
        $0.tableView.backgroundColor = .color.background.color
    }
    
    private let bottomSheetView = MapBottomSheetView()
    
    private let placeDetailView = MapPlaceDetailView().then {
        $0.isHidden = true
        $0.clipsToBounds = true
    }
    
    private var bottomSheetHeight: Constraint?
    private var detailSheetHeight: Constraint?
    
    private let defaultHeight: CGFloat = 240
    private let detailMinHeight: CGFloat = 225

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
        setupDelegate()
        setupGesture()
        setupActions()
        setupReviewWriteAction()
    }

    private func setupView() {
        view.backgroundColor = .color.background.color
        [bottomSheetView, recentSearchView, routeSelectionView, placeDetailView, searchBar].forEach {
            view.addSubview($0)
        }
    }
    
    private func setupLayout() {
        routeSelectionView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        routeSelectionView.recommendationStackView.snp.remakeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            $0.height.equalTo(106)
        }
        
        searchBar.snp.makeConstraints {
            $0.top.equalToSuperview().offset(64)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(52)
        }
        
        recentSearchView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        recentSearchView.titleStack.snp.remakeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(20)
            $0.leading.equalToSuperview().inset(24)
        }

        recentSearchView.tableView.snp.remakeConstraints {
            $0.top.equalTo(recentSearchView.titleStack.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        bottomSheetView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            self.bottomSheetHeight = $0.height.equalTo(defaultHeight).constraint
        }
        
        placeDetailView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            self.detailSheetHeight = $0.height.equalTo(0).priority(.high).constraint
        }
    }

    private func setupDelegate() {
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

        // 하트 취소 로직
        placeDetailView.onHeartToggled = { [weak self] isSelected in
            if !isSelected {
                print("하트 취소됨")
            }
        }

        routeSelectionView.onCardTapped = { [weak self] routeTitle in
            let detailVC = MapRouteDetailViewController()
            detailVC.routeTypeTitle = routeTitle
            detailVC.modalPresentationStyle = .overFullScreen
            detailVC.onDismiss = { [weak self] in self?.routeSelectionView.isHidden = false }
            self?.routeSelectionView.isHidden = true
            self?.present(detailVC, animated: true)
        }
    }
    
    private func setupReviewWriteAction() {
        placeDetailView.reviewWriteButton.addTarget(self, action: #selector(didTapReviewWrite), for: .touchUpInside)
    }
    
    @objc private func didTapReviewWrite() {
        let detailData = MapMockData.detailExample
        let reviewWriteVC = MapReviewWriteViewController(placeData: detailData)
        self.navigationController?.pushViewController(reviewWriteVC, animated: true)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let isDetail = gesture.view == placeDetailView
        let translation = gesture.translation(in: view)
        let currentHeight = isDetail ? placeDetailView.frame.height : bottomSheetView.frame.height
        let newHeight = currentHeight - translation.y
        
        let minH = isDetail ? detailMinHeight : defaultHeight
        let gap: CGFloat = 20
        let maxH = view.frame.height - (searchBar.frame.maxY + gap)
        
        if gesture.state == .changed {
            let clampedHeight = max(minH, min(newHeight, maxH))
            if isDetail { detailSheetHeight?.update(offset: clampedHeight) }
            else { bottomSheetHeight?.update(offset: clampedHeight) }
        } else if gesture.state == .ended {
            let velocity = gesture.velocity(in: view).y
            let targetHeight: CGFloat
            
            if velocity < -500 { targetHeight = maxH }
            else if velocity > 500 { targetHeight = minH }
            else { targetHeight = newHeight > (minH + maxH) / 2 ? maxH : minH }

            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
                if isDetail { self.detailSheetHeight?.update(offset: targetHeight) }
                else { self.bottomSheetHeight?.update(offset: targetHeight) }
                self.view.layoutIfNeeded()
            }
        }
        gesture.setTranslation(.zero, in: view)
    }

    private func showDetailView() {
        let detailData = MapMockData.detailExample
        placeDetailView.configure(with: detailData)
        
        bottomSheetView.isHidden = true
        placeDetailView.isHidden = false
        searchBar.isHidden = false
        detailSheetHeight?.update(offset: detailMinHeight)
        UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
    }
    
    private func setupGesture() {
        let bottomSheetPan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        bottomSheetView.addGestureRecognizer(bottomSheetPan)
        
        let detailSheetPan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        placeDetailView.addGestureRecognizer(detailSheetPan)
    }

    @objc private func hideDetailView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.detailSheetHeight?.update(offset: 0)
            self.view.layoutIfNeeded()
        }) { _ in
            if self.detailSheetHeight?.layoutConstraints.first?.constant == 0 {
                self.placeDetailView.isHidden = true
                self.bottomSheetView.isHidden = false
            }
        }
    }

    @objc private func backToHome() {
        hideDetailView()
        recentSearchView.isHidden = true
        searchBar.updateState(.home)
        searchBar.isHidden = false
        view.endEditing(true)
    }

    @objc private func didTapSearchBar() {
        if !placeDetailView.isHidden { hideDetailView() }
        searchBar.updateState(.search)
        recentSearchView.isHidden = false
    }

    @objc private func didTapArriveRoute() {
        routeSelectionView.isHidden = false
        searchBar.isHidden = true
        [bottomSheetView, placeDetailView, recentSearchView].forEach { $0.isHidden = true }
    }

    @objc private func didTapStartRoute() { didTapArriveRoute() }

    @objc private func backFromRouteSelection() {
        routeSelectionView.isHidden = true
        placeDetailView.isHidden = false
        searchBar.isHidden = false
        detailSheetHeight?.update(offset: detailMinHeight)
        UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
    }
}

extension MapViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView == recentSearchView.tableView ? dummyRecentSearches.count : dummyReviews.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == recentSearchView.tableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MapRecentSearchCell", for: indexPath) as! MapRecentSearchCell
            cell.configure(title: dummyRecentSearches[indexPath.row], date: "26.02.11")
            cell.backgroundColor = .clear
            
            cell.onDeleteTap = { [weak self, weak tableView] in
                guard let self = self,
                      let tableView = tableView,
                      let currentIndexPath = tableView.indexPath(for: cell) else { return }
                
                self.dummyRecentSearches.remove(at: currentIndexPath.row)
                tableView.deleteRows(at: [currentIndexPath], with: .fade)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: MapReviewCell.identifier, for: indexPath) as! MapReviewCell
            let data = dummyReviews[indexPath.row]
            
            cell.configure(with: data)
            
            cell.onDeleteTap = { [weak self, weak tableView] in
                guard let self = self, let tableView = tableView else { return }
                ReviewAlert.show(in: self, title: "후기 삭제", message: "작성하신 후기를 정말 삭제하시겠습니까?") {
                    // [수정] 정확한 인덱스를 찾아서 삭제
                    if let currentIndexPath = tableView.indexPath(for: cell) {
                        self.dummyReviews.remove(at: currentIndexPath.row)
                        // dummyReviews의 didSet에서 reloadData가 되므로 deleteRows는 생략하거나 didSet 로직을 확인하세요.
                    }
                }
            }
            
            cell.onReportTap = { [weak self] in
                guard let self = self else { return }
                ReviewAlert.show(in: self, title: "후기 신고", message: "이 후기를 신고하시겠습니까?") {
                    print("신고 처리 완료")
                }
            }
            return cell
        }
    }
}
