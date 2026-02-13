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
    
    // MARK: - UI Components
    private let searchBar = MapSearchBar()
    private let bottomSheetView = MapBottomSheetView()
    
    
    private let tabBar = TabBar()
    
    private var bottomSheetHeight: Constraint?
    private let defaultHeight: CGFloat = 216

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        [bottomSheetView, tabBar, searchBar].forEach { view.addSubview($0) }
        
        setupLayout()
        setupGesture()
    }
    
    private func setupLayout() {
       
        searchBar.snp.makeConstraints {
            // 1. safeAreaLayoutGuide 말고 그냥 view 기준
            $0.top.equalToSuperview().offset(60)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(52)
        }
        
        // 2. TabBar: 하단에 고정하고 배경색 확실히 지정
        tabBar.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(90)
        }
        tabBar.backgroundColor = UIColor(red: 25/255, green: 25/255, blue: 25/255, alpha: 1) // #191919
        
        // 3. 바텀시트: 탭바와 간격 0으로 딱 붙이기
        bottomSheetView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(tabBar.snp.top) 
            self.bottomSheetHeight = $0.height.equalTo(defaultHeight).constraint
        }
    }

    // MARK: - Gesture (동일)
    private func setupGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        bottomSheetView.addGestureRecognizer(pan)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let newHeight = defaultHeight - translation.y
        
        // 최대 높이: 서치바 바닥에서 8px 밑까지
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
