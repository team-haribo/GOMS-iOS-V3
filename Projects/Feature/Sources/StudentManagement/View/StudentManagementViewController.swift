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
    
    let viewModel = StudentManagementViewModel()
    var userList: [UserData] = [] {
        didSet { studentCollectionView.reloadData() }
    }
    
    private var activeAuthorityVC: AuthorityBottomSheetVC?
    
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
        $0.text = "학생 관리"
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
        icon: UIImage(named: "qrIcon", in: Bundle.module, compatibleWith: nil) ?? UIImage()
    ).then {
        $0.layer.cornerRadius = 32
        $0.addTarget(self, action: #selector(createQRButtonTapped), for: .touchUpInside)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupSearchBar()
        
        viewModel.getUserList { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.userList = self.viewModel.userListDatas
            }
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    public override func shouldShowCustomNavigation() -> Bool {
        return false
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
        viewModel.searchStudent(searchString: text.isEmpty ? nil : text) { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.userList = self.viewModel.userListDatas
            }
        }
    }
    
    @objc private func filterButtonTapped() {
        let filterVC = FilterBottomSheetVC(studentManagementVC: self, viewModel: viewModel)
        filterVC.modalPresentationStyle = .overFullScreen
        self.present(filterVC, animated: false)
    }

    @objc private func createQRButtonTapped() {
        createQRButton.isUserInteractionEnabled = false
        let qrVC = AdminQRViewController()
        self.navigationController?.pushViewController(qrVC, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.createQRButton.isUserInteractionEnabled = true
        }
    }

    public override func configureUI() {
        createQRButton.layer.shadowColor = UIColor.color.admin.color.cgColor
        createQRButton.layer.shadowOpacity = 0.8
        createQRButton.layer.shadowRadius = 13
        createQRButton.layer.shadowOffset = CGSize(width: 0.81, height: 0.81)
    }
    
    public override func addView() {
        [customBackButton, titleLabel, searchBar, resultLabel, filterButton, studentCollectionView, createQRButton].forEach { view.addSubview($0) }
        view.bringSubviewToFront(customBackButton)
        view.bringSubviewToFront(createQRButton)
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
        filterButton.snp.makeConstraints {
            $0.centerY.equalTo(resultLabel)
            $0.trailing.equalToSuperview().inset(24)
        }
        studentCollectionView.snp.makeConstraints {
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
        return CGSize(width: collectionView.frame.width, height: 69)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let activeVC = activeAuthorityVC, activeVC.presentingViewController != nil {
            activeVC.userData = userList[indexPath.row]
        } else {
            let authorityVC = AuthorityBottomSheetVC(studentManagementVC: self, viewModel: viewModel)
            authorityVC.userData = userList[indexPath.row]
            authorityVC.modalPresentationStyle = .overFullScreen
            authorityVC.presentationController?.delegate = self
            self.activeAuthorityVC = authorityVC
            self.present(authorityVC, animated: false)
        }
    }
}

extension StudentManagementViewController: UIAdaptivePresentationControllerDelegate {
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.activeAuthorityVC = nil
        viewModel.getUserList { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.userList = self.viewModel.userListDatas
            }
        }
    }
}
