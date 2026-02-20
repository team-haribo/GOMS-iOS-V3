//
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
    
    // MARK: - Dummy Data
    private var dummyRecentSearches = ["메가MGC커피 광주송정시장점", "메가MGC커피 광주송정시장점", "메가MGC커피 광주송정시장점", "메가MGC커피 광주송정시장점"]
    private var dummyReviews: [(name: String, info: String, content: String, date: String)] = [
        ("김민솔", "8기 | AI", "굳굳", "26.02.12"),
        ("권재현", "8기 | AI", "매워요", "26.02.12"),
        ("김태은", "8기 | AI", "맛있어요", "26.02.12"),
        ("이주언", "8기 | AI", "가성비 좋음", "26.02.12")
    ]
    
    // MARK: - UI Components
    private let routeSelectionView = MapRouteSelectionView().then { $0.isHidden = true }
    private let searchBar = MapSearchBar()
    private let recentSearchView = MapRecentSearchView()
    private let bottomSheetView = MapBottomSheetView()
    private let tabBar = TabBar()
    private let placeDetailView = MapPlaceDetailView()
    private let popupView = MapPopupView().then { $0.isHidden = true }
    
    private var bottomSheetHeight: Constraint?
    private let defaultHeight: CGFloat = 280

    // MARK: - Life Cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
        setupDelegate()
        setupGesture()
        setupActions()
    }
    
    private func setupView() {
        // 배경 회색
        view.backgroundColor = UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1)
        routeSelectionView.backgroundColor = .clear
        [bottomSheetView, recentSearchView, placeDetailView, tabBar, searchBar, popupView, routeSelectionView].forEach {
            view.addSubview($0)
        }
        
        recentSearchView.isHidden = true
        placeDetailView.isHidden = true
    }
    
    private func setupLayout() {
            routeSelectionView.snp.makeConstraints {
                $0.top.leading.trailing.equalToSuperview()
                $0.bottom.equalTo(tabBar.snp.top)
            }
            
            // 1. 서치바: 민선님이 조절한 위치(offset 60) 유지
            searchBar.snp.makeConstraints {
                $0.top.equalTo(view.snp.top).offset(60)
                $0.leading.trailing.equalToSuperview().inset(24)
                $0.height.equalTo(52)
            }
                
            recentSearchView.snp.makeConstraints {
                $0.top.equalTo(searchBar.snp.bottom).offset(8)
                $0.leading.trailing.equalToSuperview()
                $0.bottom.equalTo(tabBar.snp.top)
            }
                
            tabBar.snp.makeConstraints {
                $0.leading.trailing.bottom.equalToSuperview()
                $0.height.equalTo(90)
            }
                
            // 2. 바텀시트: 기존 방식(height 조절) + 탭바 뒤까지 배경 채우기
            bottomSheetView.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview()
                // 바닥을 superview에 붙여야 시트가 올라와도 탭바 뒤가 안 비어보여
                $0.bottom.equalToSuperview()
                // 제스처로 높이(height)를 조절하는 방식 그대로 유지
                self.bottomSheetHeight = $0.height.equalTo(defaultHeight).constraint
            }
                
            placeDetailView.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview()
                $0.bottom.equalTo(tabBar.snp.top)
                $0.height.equalTo(600)
            }
                
            popupView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
    
    private func setupDelegate() {
        // [오류 수정] bottomSheetView.tableView 관련 코드 완전 제거
        recentSearchView.tableView.delegate = self
        recentSearchView.tableView.dataSource = self
        placeDetailView.tableView.delegate = self
        placeDetailView.tableView.dataSource = self
        routeSelectionView.dropdownTableView.delegate = self
        routeSelectionView.dropdownTableView.dataSource = self
    }
    
    private func setupActions() {
        searchBar.backButton.addTarget(self, action: #selector(backToHome), for: .touchUpInside)
        routeSelectionView.backButton.addTarget(self, action: #selector(backToHome), for: .touchUpInside)
        placeDetailView.arriveButton.addTarget(self, action: #selector(didTapArriveRoute), for: .touchUpInside)
        placeDetailView.startRouteButton.addTarget(self, action: #selector(didTapStartRoute), for: .touchUpInside)
        routeSelectionView.reverseButton.addTarget(self, action: #selector(didTapReverseRoute), for: .touchUpInside)
        routeSelectionView.startDropdownButton.addTarget(self, action: #selector(didTapDropdown), for: .touchUpInside)
        searchBar.textField.addTarget(self, action: #selector(didTapSearchBar), for: .editingDidBegin)
        placeDetailView.closeButton.addTarget(self, action: #selector(hideDetailView), for: .touchUpInside)

        // 바텀시트 카드 클릭 시 상세 페이지 이동 연결
        bottomSheetView.onCardTapped = { [weak self] in
            self?.showDetailView()
        }
    }

    // MARK: - Logic
    @objc private func backToHome() {
        routeSelectionView.isHidden = true
        recentSearchView.isHidden = true
        placeDetailView.isHidden = true
        searchBar.isHidden = false
        bottomSheetView.isHidden = false
        searchBar.updateState(.home)
        view.endEditing(true)
    }

    @objc private func didTapArriveRoute() {
        searchBar.isHidden = true; placeDetailView.isHidden = true; routeSelectionView.isHidden = false
        routeSelectionView.updateLocation(start: "출발 위치를 선택해주세요", end: "짬뽕관 광주송정선운점")
    }

    @objc private func didTapStartRoute() {
        searchBar.isHidden = true; placeDetailView.isHidden = true; routeSelectionView.isHidden = false
        routeSelectionView.updateLocation(start: "짬뽕관 광주송정선운점", end: "도착 위치를 선택해주세요")
    }
    
    @objc private func didTapReverseRoute() {
        let currentStart = routeSelectionView.startDropdownButton.configuration?.title ?? ""
        let currentEnd = routeSelectionView.endLocationLabel.text?.trimmingCharacters(in: .whitespaces) ?? ""
        routeSelectionView.updateLocation(start: currentEnd, end: currentStart)
    }
    
    @objc private func didTapDropdown() {
        routeSelectionView.dropdownTableView.isHidden.toggle()
    }

    @objc private func didTapSearchBar() {
        UIView.animate(withDuration: 0.3) {
            self.searchBar.updateState(.search)
            self.recentSearchView.isHidden = false
            self.bottomSheetView.isHidden = true
        }
    }

    private func showDetailView() {
        placeDetailView.isHidden = false
        bottomSheetView.isHidden = true
        recentSearchView.isHidden = true
    }
    
    @objc private func hideDetailView() {
        placeDetailView.isHidden = true
        bottomSheetView.isHidden = false
    }

    private func setupGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        bottomSheetView.addGestureRecognizer(pan)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let newHeight = defaultHeight - translation.y
        
        // 간격 8px 반영: 100 대신 8로 수정
        let maxHeight = view.frame.height - (searchBar.frame.maxY + 8)
        
        if gesture.state == .changed {
            if newHeight >= defaultHeight && newHeight <= maxHeight {
                bottomSheetHeight?.update(offset: newHeight)
            }
        } else if gesture.state == .ended {
            let target = newHeight > (defaultHeight + maxHeight) / 2 ? maxHeight : defaultHeight
            UIView.animate(withDuration: 0.3) {
                self.bottomSheetHeight?.update(offset: target)
                self.view.layoutIfNeeded()
            }
        }
    }
}

// MARK: - TableView 연결
extension MapViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == routeSelectionView.dropdownTableView { return 2 }
        if tableView == recentSearchView.tableView { return dummyRecentSearches.count }
        return dummyReviews.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == routeSelectionView.dropdownTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "dropdownCell", for: indexPath)
            cell.backgroundColor = .clear; cell.textLabel?.textColor = .white
            cell.textLabel?.text = indexPath.row == 0 ? "내 위치" : "학교"
            return cell
        }
        
        if tableView == recentSearchView.tableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MapRecentSearchCell", for: indexPath) as! MapRecentSearchCell
            cell.configure(title: dummyRecentSearches[indexPath.row], date: "카페")
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MapReviewCell", for: indexPath) as! MapReviewCell
            let data = dummyReviews[indexPath.row]
            cell.configure(name: data.name, info: data.info, content: data.content, date: data.date)
            return cell
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == recentSearchView.tableView {
            showDetailView()
        } else if tableView == routeSelectionView.dropdownTableView {
            let selectedText = indexPath.row == 0 ? "내 위치" : "학교"
            routeSelectionView.updateLocation(start: selectedText, end: "짬뽕관 광주송정선운점")
            routeSelectionView.dropdownTableView.isHidden = true
        }
    }
}
