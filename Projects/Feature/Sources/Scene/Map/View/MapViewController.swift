//  MapViewController.swift
//  Feature
//
//  Created by 김민선 on 2/13/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

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
    private let defaultHeight: CGFloat = 330

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
        setupDelegate()
        setupGesture()
        setupActions()
    }
    
    private func setupView() {
        view.backgroundColor = UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1)
        [bottomSheetView, recentSearchView, placeDetailView, tabBar, searchBar, popupView, routeSelectionView].forEach {
            view.addSubview($0)
        }
        recentSearchView.isHidden = true
        placeDetailView.isHidden = true
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
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            self.bottomSheetHeight = $0.height.equalTo(defaultHeight).constraint
        }
        
        // ✅ [수정] offset(-90)을 없애서 탭바와의 간격을 제거하고 바닥에 딱 붙였습니다.
        placeDetailView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(600)
        }
        
        popupView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    private func setupDelegate() {
        recentSearchView.tableView.delegate = self
        recentSearchView.tableView.dataSource = self
        placeDetailView.tableView.delegate = self
        placeDetailView.tableView.dataSource = self
        routeSelectionView.dropdownTableView.delegate = self
        routeSelectionView.dropdownTableView.dataSource = self
    }
    
    private func setupActions() {
        // 기존 액션
        placeDetailView.heartButton.addTarget(self, action: #selector(didTapHeart), for: .touchUpInside)
        searchBar.backButton.addTarget(self, action: #selector(backToHome), for: .touchUpInside)
        routeSelectionView.backButton.addTarget(self, action: #selector(backToHome), for: .touchUpInside)
        placeDetailView.closeButton.addTarget(self, action: #selector(hideDetailView), for: .touchUpInside)
        
        // ✅ [수정] 출발/도착 버튼 클릭 시 페이지 이동 로직 연결
        placeDetailView.arriveButton.addTarget(self, action: #selector(didTapArriveRoute), for: .touchUpInside)
        placeDetailView.startRouteButton.addTarget(self, action: #selector(didTapStartRoute), for: .touchUpInside)
        
        bottomSheetView.onCardTapped = { [weak self] in self?.showDetailView() }
        searchBar.textField.addTarget(self, action: #selector(didTapSearchBar), for: .editingDidBegin)
    }

    // MARK: - Alert Logic
    private func showDeleteAlert(at index: Int) {
        GomsAlert.show(
            in: self,
            title: "후기 삭제",
            message: "정말 후기를 삭제하시겠습니까?",
            leftTitle: "취소",
            rightTitle: "삭제하기",
            rightColor: .systemRed
        ) { [weak self] in
            self?.dummyReviews.remove(at: index)
            self?.placeDetailView.tableView.reloadData()
            self?.showSimpleAlert(title: "후기 삭제 완료", message: "후기 삭제를 성공적으로 완료했습니다.")
        }
    }

    private func showReportAlert() {
        GomsAlert.show(
            in: self,
            title: "후기 신고",
            message: "이 후기를 신고하시겠습니까?\n신고 내용은 운영팀의 검토 후 처리됩니다.",
            leftTitle: "취소",
            rightTitle: "신고하기",
            rightColor: .systemRed
        ) { [weak self] in
            self?.showSimpleAlert(title: "후기 신고 완료", message: "신고가 접수되었습니다.\n더 나은 GOMS가 되기위해 노력하겠습니다!")
        }
    }

    private func showSimpleAlert(title: String, message: String) {
        GomsAlert.show(
            in: self,
            title: title,
            message: message,
            rightTitle: "돌아가기",
            rightColor: UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        )
    }

    // MARK: - Selectors
    @objc private func didTapHeart(_ sender: UIButton) {
        sender.isSelected.toggle()
        sender.tintColor = sender.isSelected ? UIColor(red: 255/255, green: 165/255, blue: 0/255, alpha: 1) : .white
        let imageName = sender.isSelected ? "heart.fill" : "heart"
        sender.setImage(UIImage(systemName: imageName), for: .normal)
    }

    @objc private func backToHome() {
        routeSelectionView.isHidden = true; recentSearchView.isHidden = true; placeDetailView.isHidden = true
        searchBar.isHidden = false; bottomSheetView.isHidden = false; searchBar.updateState(.home)
        view.endEditing(true)
    }

    @objc private func didTapSearchBar() {
        searchBar.updateState(.search); recentSearchView.isHidden = false; bottomSheetView.isHidden = true
    }

    private func showDetailView() {
        placeDetailView.isHidden = false; bottomSheetView.isHidden = true; recentSearchView.isHidden = true
    }
    
    @objc private func hideDetailView() {
        placeDetailView.isHidden = true; bottomSheetView.isHidden = false
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
    
    @objc private func didTapDropdown() { routeSelectionView.dropdownTableView.isHidden.toggle() }
    
    private func setupGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        bottomSheetView.addGestureRecognizer(pan)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let newHeight = defaultHeight - translation.y
        let maxHeight = view.frame.height - (searchBar.frame.maxY + 8)
        if gesture.state == .changed {
            if newHeight >= defaultHeight && newHeight <= maxHeight { bottomSheetHeight?.update(offset: newHeight) }
        } else if gesture.state == .ended {
            let target = newHeight > (defaultHeight + maxHeight) / 2 ? maxHeight : defaultHeight
            UIView.animate(withDuration: 0.3) {
                self.bottomSheetHeight?.update(offset: target)
                self.view.layoutIfNeeded()
            }
        }
    }
}

// MARK: - TableView Delegate & DataSource
extension MapViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == routeSelectionView.dropdownTableView { return 2 }
        return tableView == recentSearchView.tableView ? dummyRecentSearches.count : dummyReviews.count
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
            let cell = tableView.dequeueReusableCell(withIdentifier: MapReviewCell.identifier, for: indexPath) as! MapReviewCell
            let data = dummyReviews[indexPath.row]
            cell.configure(name: data.name, info: data.info, content: data.content, date: data.date)
            cell.onDeleteTap = { [weak self] in self?.showDeleteAlert(at: indexPath.row) }
            cell.onReportTap = { [weak self] in self?.showReportAlert() }
            return cell
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == recentSearchView.tableView { showDetailView() }
        else if tableView == routeSelectionView.dropdownTableView {
            let selectedText = indexPath.row == 0 ? "내 위치" : "학교"
            routeSelectionView.updateLocation(start: selectedText, end: "짬뽕관 광주송정선운점")
            routeSelectionView.dropdownTableView.isHidden = true
        }
    }
}
