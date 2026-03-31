//
//  StudentManagementViewController.swift
//  Feature
//
//  Created by 김민선 on 3/23/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit
import Then

public final class StudentManagementViewController: BaseViewController {
    
    private let viewModel = StudentManagementViewModel()
    var userList: [UserData] = [] {
        didSet { studentCollectionView.reloadData() }
    }
    
    private lazy var backButton = UIButton().then {
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        $0.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        $0.setTitle(" 돌아가기", for: .normal)
        $0.setTitleColor(UIColor.color.admin.color, for: .normal)
        $0.tintColor = UIColor.color.admin.color
        $0.titleLabel?.font = .suit(size: 16, weight: .medium)
        $0.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "학생 관리"
        $0.textColor = UIColor.color.mainText.color
        $0.font = .suit(size: 24, weight: .bold)
    }
    
    private let searchBar = GOMSSearchBar()
    
    private let resultLabel = UILabel().then {
        $0.text = "검색 결과"
        $0.textColor = UIColor.color.mainText.color
        $0.font = .suit(size: 20, weight: .bold)
    }
    
    private lazy var filterButton = UIButton().then {
        $0.setTitle("필터", for: .normal)
        $0.setTitleColor(UIColor.color.admin.color, for: .normal)
        $0.titleLabel?.font = .suit(size: 16, weight: .medium)
        $0.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
    }
    
    lazy var studentCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
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
        
        self.userList = StudentMockData.students
        viewModel.getUserList {
            if !self.viewModel.userListDatas.isEmpty {
                self.userList = self.viewModel.userListDatas
            }
        }
    }
    
    private func setupCollectionView() {
        studentCollectionView.dataSource = self
        studentCollectionView.delegate = self
        studentCollectionView.register(StudentCollectionViewCell.self, forCellWithReuseIdentifier: StudentCollectionViewCell.identifier)
    }
    
    private func setupSearchBar() {
        searchBar.textField.addTarget(self, action: #selector(searchTextFieldDidChange), for: .editingChanged)
    }

    @objc private func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func searchTextFieldDidChange(_ textField: UITextField) {
        let text = textField.text ?? ""
        viewModel.serachStudent(searchString: text.isEmpty ? nil : text) { self.userList = $0 }
    }
    
    @objc private func filterButtonTapped() {
        let filterVC = FilterBottomSheetVC(studentManagementVC: self)
        filterVC.modalPresentationStyle = .overFullScreen
        self.present(filterVC, animated: false)
    }

    @objc private func createQRButtonTapped() {
        let qrVC = AdminQRViewController()
        self.navigationController?.pushViewController(qrVC, animated: true)
    }
    
    public override func addView() {
        [backButton, titleLabel, searchBar, resultLabel, filterButton, studentCollectionView, createQRButton].forEach { view.addSubview($0) }
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
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(52)
        }
        resultLabel.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(24)
        }
        filterButton.snp.makeConstraints {
            $0.centerY.equalTo(resultLabel)
            $0.trailing.equalToSuperview().inset(24)
        }
        studentCollectionView.snp.makeConstraints {
            $0.top.equalTo(resultLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview()
        }
        createQRButton.snp.makeConstraints {
            $0.width.height.equalTo(64)
            $0.trailing.equalToSuperview().inset(24)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
}

extension StudentManagementViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userList.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StudentCollectionViewCell.identifier, for: indexPath) as? StudentCollectionViewCell else { return UICollectionViewCell() }
        cell.configureData(with: userList[indexPath.row])
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 80)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let authorityVC = AuthorityBottomSheetVC(studentManagementVC: self)
        authorityVC.userData = userList[indexPath.row]
        authorityVC.modalPresentationStyle = .overFullScreen
        self.present(authorityVC, animated: false)
    }
}
