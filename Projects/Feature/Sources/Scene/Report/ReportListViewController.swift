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
    
    private lazy var backButton = UIButton().then {
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        $0.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
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
    
    // 민선님이 만든 GOMSSearchBar 그대로 사용
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
    
    private lazy var filterButton = UIButton().then {
        $0.setImage(UIImage(systemName: "line.3.horizontal.decrease"), for: .normal)
        $0.tintColor = UIColor.color.admin.color
        $0.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
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

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupSearchBar()
        viewModel.loadMockData()
    }
    
    private func setupCollectionView() {
        reportCollectionView.dataSource = self
        reportCollectionView.delegate = self
        reportCollectionView.register(ReportCollectionViewCell.self, forCellWithReuseIdentifier: ReportCollectionViewCell.identifier)
    }

    private func setupSearchBar() {
        searchBar.textField.addTarget(self, action: #selector(searchTextFieldDidChange), for: .editingChanged)
    }
    
    @objc private func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func searchTextFieldDidChange(_ textField: UITextField) {
        print("입력된 이름: \(textField.text ?? "")")
    }
    
    @objc private func filterButtonTapped() { }
    @objc private func createQRButtonTapped() { }

    public override func addView() {
        [backButton, titleLabel, searchBar, resultLabel, filterButton, reportCollectionView, createQRButton].forEach { view.addSubview($0) }
    }
    
    public override func setLayout() {
        backButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.equalToSuperview().offset(20)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(backButton.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(24)
        }
        searchBar.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(48)
        }
        resultLabel.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(28)
            $0.leading.equalToSuperview().offset(24)
        }
        filterButton.snp.makeConstraints {
            $0.centerY.equalTo(resultLabel)
            $0.trailing.equalToSuperview().inset(24)
            $0.size.equalTo(24)
        }
        reportCollectionView.snp.makeConstraints {
            $0.top.equalTo(resultLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(16)
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
        return CGSize(width: collectionView.frame.width, height: 69)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = ReportDetailViewController()
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}
