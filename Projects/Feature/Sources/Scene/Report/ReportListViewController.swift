//
//  ReportListViewController.swift
//  Feature
//
//  Created by 김민선 on 3/29/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit
import Then

public final class ReportListViewController: BaseViewController {
    
    private let viewModel = ReportListViewModel()
    
    private lazy var customBackButton = UIButton().then {
        let backImage = UIImage(named: "Back", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        $0.setImage(backImage, for: .normal)
        $0.setTitle(" 돌아가기", for: .normal)
        $0.setTitleColor(UIColor.color.admin.color, for: .normal)
        $0.tintColor = UIColor.color.admin.color
        $0.titleLabel?.font = .suit(size: 18, weight: .medium)
        $0.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "신고 목록"
        $0.textColor = UIColor.color.mainText.color
        $0.font = .suit(size: 26, weight: .bold)
    }
    
    private let searchBar = GOMSSearchBar().then {
        $0.textField.attributedPlaceholder = NSAttributedString(
            string: "학생 검색",
            attributes: [
                .foregroundColor: UIColor.color.sub1.color,
                .font: UIFont.suit(size: 17, weight: .medium)
            ]
        )
    }
    
    private let resultLabel = UILabel().then {
        $0.text = "검색 결과"
        $0.textColor = UIColor.color.mainText.color
        $0.font = .suit(size: 20, weight: .bold)
    }
    
    private lazy var reportCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = false
    }

    private let createQRButton = AdminQRButton(
        frame: .zero,
        backgroundColor: UIColor.color.admin.color,
        icon: UIImage(systemName: "qrcode") ?? UIImage()
    ).then {
        $0.layer.cornerRadius = 32
        $0.addTarget(self, action: #selector(createQRButtonTapped), for: .touchUpInside)
    }

    // MARK: - LifeCycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        viewModel.loadMockData()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 네이티브 네비게이션 바 숨김
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 디테일 뷰에서 사용하신 방식: BaseViewController가 추가한 height 100짜리 navView를 찾아 삭제
        self.view.subviews.forEach {
            if $0 != customBackButton && $0 != titleLabel && $0.frame.height == 100 {
                $0.isHidden = true
                $0.removeFromSuperview()
            }
        }
    }

    private func setupCollectionView() {
        reportCollectionView.dataSource = self
        reportCollectionView.delegate = self
        reportCollectionView.register(ReportCollectionViewCell.self, forCellWithReuseIdentifier: ReportCollectionViewCell.identifier)
    }

    @objc private func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func createQRButtonTapped() { }

    // MARK: - UI
    public override func addView() {
        [customBackButton, titleLabel, searchBar, resultLabel, reportCollectionView, createQRButton].forEach { view.addSubview($0) }
        
        // 내 커스텀 버튼이 가장 앞으로 오도록 보장
        view.bringSubviewToFront(customBackButton)
    }
    
    public override func setLayout() {
        customBackButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.equalToSuperview().offset(20)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(customBackButton.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(24)
        }
        searchBar.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(52)
        }
        resultLabel.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(28)
            $0.leading.equalToSuperview().offset(24)
        }
        reportCollectionView.snp.makeConstraints {
            $0.top.equalTo(resultLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        createQRButton.snp.makeConstraints {
            $0.width.height.equalTo(64)
            $0.trailing.equalToSuperview().inset(24)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
}

extension ReportListViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.reports.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReportCollectionViewCell.identifier, for: indexPath) as? ReportCollectionViewCell else { return UICollectionViewCell() }
        cell.configure(with: viewModel.reports[indexPath.row])
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 335, height: 120)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = ReportDetailViewController()
        detailVC.reportData = viewModel.reports[indexPath.row]
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}
