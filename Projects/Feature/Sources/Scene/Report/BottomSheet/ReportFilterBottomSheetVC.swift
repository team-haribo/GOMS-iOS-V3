//
//  ReportFilterBottomSheetVC.swift
//  Feature
//
//  Created by 김민선 on 4/13/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit
import Then
import Service

public final class ReportFilterBottomSheetVC: BaseViewController {
    
    private let viewModel: ReportListViewModel
    private weak var reportListVC: ReportListViewController?
            
    init(reportListVC: ReportListViewController, viewModel: ReportListViewModel) {
        self.reportListVC = reportListVC
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var dimmedView = UIView().then {
        $0.backgroundColor = .clear
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeButtonTapped))
        $0.addGestureRecognizer(tapGesture)
    }
    
    private let bottomSheetView = UIView().then {
        $0.backgroundColor = .color.surface.color
        $0.layer.cornerRadius = 20
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.clipsToBounds = true
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "필터"
        $0.textColor = .color.mainText.color
        $0.font = .suit(size: 20, weight: .bold)
    }
    
    private lazy var closeButton = UIButton().then {
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        $0.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
        $0.tintColor = .color.mainText.color
        $0.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }
    
    private let statusLabel = UILabel().then {
        $0.text = "상태"
        $0.textColor = .color.mainText.color
        $0.font = .suit(size: 20, weight: .bold)
    }
    
    private lazy var pendingButton = BottomSheetButton(frame: .zero, title: "처리전")
    private lazy var completedButton = BottomSheetButton(frame: .zero, title: "처리 완료")
    
    private lazy var resetButton = ResetButton().then {
        $0.setTitle("필터 초기화", for: .normal)
        $0.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = .clear
    }
    
    public override func shouldShowCustomNavigation() -> Bool {
        return false
    }
    
    @objc func closeButtonTapped() {
        self.dismiss(animated: true)
    }
    
    @objc func statusButtonTapped(sender: BottomSheetButton) {
        [pendingButton, completedButton].forEach {
            $0.isSelected = ($0 == sender) ? !sender.isSelected : false
        }
        applyFilter()
    }
    
    private func applyFilter() {
        let selectedStatus: ReportStatusType? = pendingButton.isSelected ? .pending : (completedButton.isSelected ? .resolved : nil)
        
        viewModel.filterReportsByStatus(status: selectedStatus)
        
        DispatchQueue.main.async {
            self.reportListVC?.reloadReportList()
        }
    }
    
    @objc func resetButtonTapped() {
        [pendingButton, completedButton].forEach { $0.isSelected = false }
        applyFilter()
    }
    
    public override func addView() {
        view.addSubview(dimmedView)
        view.addSubview(bottomSheetView)
        [titleLabel, closeButton, statusLabel, pendingButton, completedButton, resetButton].forEach {
            bottomSheetView.addSubview($0)
        }
        
        [pendingButton, completedButton].forEach {
            $0.addTarget(self, action: #selector(statusButtonTapped), for: .touchUpInside)
        }
    }
    
    public override func setLayout() {
        dimmedView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        bottomSheetView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(276)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(24)
            $0.top.equalToSuperview().inset(32)
        }
        
        closeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(24)
            $0.centerY.equalTo(titleLabel)
        }
        
        statusLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel)
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
        }
        
        pendingButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(24)
            $0.top.equalTo(statusLabel.snp.bottom).offset(12)
            $0.width.equalToSuperview().multipliedBy(0.43)
            $0.height.equalTo(48)
        }
        
        completedButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(24)
            $0.top.width.height.equalTo(pendingButton)
        }
        
        resetButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(52)
            $0.top.equalTo(pendingButton.snp.bottom).offset(24)
        }
    }
}
