//
//  StudentManagementViewController.swift
//  Feature
//
//  Created by 김준표 on 2/25/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit

public final class StudentManagementViewController: BaseViewController {
    
    // MARK: - Properties
    private let viewModel = StudentManagementViewModel()
    
    var userList: [UserData] = [] {
        didSet {
            studentCollectionView.reloadData()
        }
    }
    
    let refreshControl = UIRefreshControl()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    private let titleLabel = UILabel().then {
        $0.text = "검색 결과"
        $0.textColor = .color.mainText.color
        $0.font = .suit(size: 18, weight: .semibold)
    }
    
    private lazy var filterButton = UIButton().then {
        $0.setTitle("필터", for: .normal)
        $0.backgroundColor = .clear
        $0.setTitleColor(.color.gomsInformation.color, for: .normal)
        $0.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
    }
    
    lazy var studentCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init()).then {
        $0.backgroundColor = .clear
        $0.isScrollEnabled = true
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = true
        $0.clipsToBounds = true
        $0.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    @objc func filterButtonTapped() {
        let filterVC = FilterBottomSheetVC(studentManagementVC: self)
        filterVC.modalPresentationStyle = .overFullScreen
        self.present(filterVC, animated: false, completion: nil)
    }
    
    // MARK: - Life Cycel
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        viewModel.getUserList {
            self.userList = self.viewModel.userListDatas
            self.setupCollectionView()
            self.setupSearchBar()
            self.configureRefreshControl()
            self.studentCollectionView.reloadData()
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
    }
    
    private func setupScrollView() {
        addView()
        configureRefreshControl()
    }

    // MARK: - Refresh Control Setup
    func configureRefreshControl() {
        studentCollectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        refreshControl.tintColor = .color.admin.color
    }

    @objc private func handleRefreshControl() {
        viewModel.gomsRefreshToken.tokenReissuance(){ success in}
        viewModel.getUserList {
            self.userList = self.viewModel.userListDatas
            DispatchQueue.main.async {
                self.studentCollectionView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }

    public override func configNavigation() {
        super.configNavigation()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "학생 관리"
        navigationController?.navigationBar.tintColor = .color.admin.color
        navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationController?.navigationBar.isHidden = false
    }
    
    private func setupCollectionView() {
        self.studentCollectionView.dataSource = self
        self.studentCollectionView.delegate = self
        studentCollectionView.register(StudentCollectionViewCell.self, forCellWithReuseIdentifier: StudentCollectionViewCell.identifier)
    }
    
    func setupSearchBar() {
        searchController.searchBar.placeholder = "학생 검색"
        searchController.searchResultsUpdater = self
    }
    
    // MARK: - Add View
    public override func addView() {
        [titleLabel, filterButton, studentCollectionView].forEach { view.addSubview($0) }
    }
    
    // MARK: Layout
    public override func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            $0.leading.equalTo(bounds.width * 0.05)
            $0.height.equalTo(32)
        }
        
        filterButton.snp.makeConstraints {
            $0.height.equalTo(32)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            $0.trailing.equalTo(-bounds.width * 0.05)
        }
        
        studentCollectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.equalTo(bounds.width * 0.05)
            $0.trailing.equalTo(-(bounds.width * 0.05))
            $0.bottom.equalToSuperview()
        }
    }
}

// MARK: - Extension
extension StudentManagementViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userList.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = studentCollectionView.dequeueReusableCell(withReuseIdentifier: StudentCollectionViewCell.identifier, for: indexPath) as! StudentCollectionViewCell
    
        let userData = userList[indexPath.row]
        cell.configureData(with: userData)
        
        return cell
    }
}

extension StudentManagementViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = bounds.width * 0.9
        let height: CGFloat = 72
        return CGSize(width: width, height: height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension StudentManagementViewController: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        guard let searchString = searchController.searchBar.text else { return }
        if searchString.isEmpty {
            viewModel.resetInfo()
            viewModel.serachStudent(searchString: nil) { newList in
                self.userList = newList
                self.studentCollectionView.reloadData()
            }
            userList = viewModel.userListDatas
        } else {
            viewModel.serachStudent(searchString: searchString) { newList in
                self.userList = newList
                self.studentCollectionView.reloadData()
            }
        }
    }
}
