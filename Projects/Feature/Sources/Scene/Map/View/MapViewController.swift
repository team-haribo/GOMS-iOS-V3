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
    
    private var dummyRecentSearches = ["메가MGC커피 광주송정시장점", "메가MGC커피 광주송정시장점", "메가MGC커피 광주송정시장점", "메가MGC커피 광주송정시장점"]
    
    private var dummyReviews: [MapReview] = [
        MapReview(name: "김민솔", info: "8기 | AI", content: "굳굳", date: "26.02.12"),
        MapReview(name: "권재현", info: "8기 | AI", content: "매워요", date: "26.02.12"),
        MapReview(name: "김태은", info: "8기 | AI", content: "맛있어요", date: "26.02.12"),
        MapReview(name: "이주언", info: "8기 | AI", content: "가성비 좋음", date: "26.02.12")
    ]
    
    private let routeSelectionView = MapRouteSelectionView().then { $0.isHidden = true }
    private let searchBar = MapSearchBar()
    
    private let recentSearchView = MapRecentSearchView().then {
        $0.isHidden = true
        $0.backgroundColor = .color.background.color
        $0.tableView.backgroundColor = .color.background.color
    }
    
    private let bottomSheetView = MapBottomSheetView()
    private let tabBar = TabBar()
    private let placeDetailView = MapPlaceDetailView().then {
        $0.isHidden = true
        $0.clipsToBounds = true
    }
    
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
        setupReviewWriteAction()
        bindTabBar()
    }

    private func setupView() {
        view.backgroundColor = .color.background.color
        [bottomSheetView, recentSearchView, routeSelectionView, placeDetailView, searchBar, tabBar].forEach {
            view.addSubview($0)
        }
        view.bringSubviewToFront(tabBar)
    }
    
    private func setupLayout() {
        tabBar.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(90)
        }

        routeSelectionView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        routeSelectionView.recommendationStackView.snp.remakeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(tabBar.snp.top).offset(-20)
            $0.height.equalTo(106)
        }
        
        // [수정] 서치바 위치를 60 -> 64로 살짝 내렸습니다.
        searchBar.snp.makeConstraints {
            $0.top.equalToSuperview().offset(64)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(52)
        }
        
        recentSearchView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        // [수정] 리스트를 위로 더 올리고(offset 20 -> 12), 서치바와의 간격도 조정
        recentSearchView.titleStack.snp.remakeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(20)
            $0.leading.equalToSuperview().inset(24)
        }

        recentSearchView.tableView.snp.remakeConstraints {
            $0.top.equalTo(recentSearchView.titleStack.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(tabBar.snp.top)
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

    private func bindTabBar() {
        tabBar.onTabSelected = { [weak self] tabType in
            guard let self = self else { return }
            switch tabType {
            case .home: self.navigationController?.popViewController(animated: false)
            case .profile:
                let profileVC = UserProfileViewController()
                self.navigationController?.pushViewController(profileVC, animated: false)
            case .map: break
            }
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

        routeSelectionView.recommendationStackView.arrangedSubviews.forEach { subview in
            if let card = subview as? PathRecommendationCard {
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapRouteCard))
                card.addGestureRecognizer(tapGesture)
                card.isUserInteractionEnabled = true
            }
        }
    }
    
    private func setupReviewWriteAction() {
        placeDetailView.reviewWriteButton.addTarget(self, action: #selector(didTapReviewWrite), for: .touchUpInside)
    }
    
    @objc private func didTapReviewWrite() {
        let reviewWriteVC = MapReviewWriteViewController()
        self.navigationController?.pushViewController(reviewWriteVC, animated: true)
    }

    @objc private func didTapRouteCard() {
        let detailVC = MapRouteDetailViewController()
        detailVC.modalPresentationStyle = .overFullScreen
        detailVC.onDismiss = { [weak self] in self?.routeSelectionView.isHidden = false }
        self.routeSelectionView.isHidden = true
        self.present(detailVC, animated: true)
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
        searchBar.isHidden = false
        view.bringSubviewToFront(tabBar)
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
        view.bringSubviewToFront(tabBar)
    }

    @objc private func didTapArriveRoute() {
        routeSelectionView.isHidden = false
        searchBar.isHidden = true
        [bottomSheetView, placeDetailView, recentSearchView].forEach { $0.isHidden = true }
        view.bringSubviewToFront(tabBar)
    }

    @objc private func didTapStartRoute() { didTapArriveRoute() }

    @objc private func backFromRouteSelection() {
        routeSelectionView.isHidden = true
        placeDetailView.isHidden = false
        searchBar.isHidden = false
        view.bringSubviewToFront(tabBar)
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
            
            // [배경색 수정] 셀 배경색도 투명하게 해서 뷰 컬러가 보이게 함
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
            cell.configure(name: data.name, info: data.info, content: data.content, date: data.date)
            
            cell.onDeleteTap = { [weak self, weak tableView] in
                guard let self = self, let tableView = tableView else { return }
                ReviewAlert.show(in: self, title: "후기 삭제", message: "작성하신 후기를 정말 삭제하시겠습니까?") {
                    if let currentIndexPath = tableView.indexPath(for: cell) {
                        self.dummyReviews.remove(at: currentIndexPath.row)
                        tableView.deleteRows(at: [currentIndexPath], with: .fade)
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
