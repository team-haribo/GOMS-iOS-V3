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
    private let dummyRecentSearches = [
        "메가MGC커피 광주송정시장점", "메가MGC커피 광주송정시장점",
        "메가MGC커피 광주송정시장점", "메가MGC커피 광주송정시장점",
        "메가MGC커피 광주송정시장점", "메가MGC커피 광주송정시장점"
    ]
    
    // MARK: - UI Components
    private let searchBar = MapSearchBar()
    private let recentSearchView = MapRecentSearchView()
    private let bottomSheetView = MapBottomSheetView()
    private let tabBar = TabBar()
    
    private var bottomSheetHeight: Constraint?
    private let defaultHeight: CGFloat = 216

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
        view.backgroundColor = .white
        // 순서: 뒤에 있을수록 화면 위로 올라옵니다. searchBar를 가장 마지막에 추가.
        [bottomSheetView, recentSearchView, tabBar, searchBar].forEach { view.addSubview($0) }
        
        recentSearchView.isHidden = true // 초기엔 최근 검색 화면 숨김
    }
    
    private func setupLayout() {
        searchBar.snp.makeConstraints {
            $0.top.equalToSuperview().offset(60)
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
        tabBar.backgroundColor = UIColor(red: 25/255, green: 25/255, blue: 25/255, alpha: 1)
        
        bottomSheetView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(tabBar.snp.top)
            self.bottomSheetHeight = $0.height.equalTo(defaultHeight).constraint
        }
    }

    private func setupDelegate() {
        // 테이블 뷰와 데이터를 연결합니다.
        recentSearchView.tableView.delegate = self
        recentSearchView.tableView.dataSource = self
    }

    private func setupActions() {
        // 1. 검색창 터치 시 (키보드 올라감)
        searchBar.textField.addTarget(self, action: #selector(didTapSearchBar), for: .editingDidBegin)
        
        // 2. 뒤로가기 버튼 클릭 시 (홈으로 복귀)
        searchBar.backButton.addTarget(self, action: #selector(backToHome), for: .touchUpInside)
    }

    // MARK: - Logic
    @objc private func didTapSearchBar() {
        UIView.animate(withDuration: 0.3) {
            self.searchBar.updateState(.search) // 아이콘 '>' 변경
            self.recentSearchView.isHidden = false
            self.bottomSheetView.isHidden = true
        }
    }

    @objc private func backToHome() {
        UIView.animate(withDuration: 0.3) {
            self.searchBar.updateState(.home) // 아이콘 '곰돌이' 변경
            self.recentSearchView.isHidden = true
            self.bottomSheetView.isHidden = false
            self.view.endEditing(true) // 키보드 내리기
        }
    }

    // MARK: - Gesture (바텀시트 드래그)
    private func setupGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        bottomSheetView.addGestureRecognizer(pan)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let newHeight = defaultHeight - translation.y
        let maxHeight = view.frame.height - (searchBar.frame.maxY + 90 + 8)
        
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

// MARK: - UITableViewDataSource & Delegate
extension MapViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dummyRecentSearches.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MapRecentSearchCell.identifier, for: indexPath) as? MapRecentSearchCell else {
            return UITableViewCell()
        }
        // 가짜 데이터 적용
        cell.configure(title: dummyRecentSearches[indexPath.row], date: "26.02.11")
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52 // 리스트 한 칸의 높이
    }
}
