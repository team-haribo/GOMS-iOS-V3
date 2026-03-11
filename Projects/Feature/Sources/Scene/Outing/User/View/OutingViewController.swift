//
//  OutingViewController.swift
//  Feature
//
//  Created by 김준표 on 2/25/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit

public final class OutingViewController: BaseViewController {
    
    // MARK: - Properties
    private let viewModel = OutingViewModel()
    
    var outingList: [OutingListData] = [] {
        didSet {
            outingListCollectionView.reloadData()
        }
    }
    
    let refreshControl = UIRefreshControl()
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private let searchTitle = UILabel().then {
        $0.text = "검색 결과"
        $0.textColor = .color.mainText.color
        $0.font = .suit(size: 18, weight: .semibold)
    }
    
    lazy var outingListCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init()).then {
        $0.backgroundColor = .clear
        $0.isScrollEnabled = true
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = true
        $0.clipsToBounds = true
        $0.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    private let coffeeIcon = UIImageView().then {
        $0.image = .image.grayCoffee.image
        $0.isHidden = true
    }
    
    private let outingNilLabel = UILabel().then {
        $0.text = "텅 비어있네요... 다들 바쁜가 봐요!"
        $0.textColor = .color.sub2.color
        $0.font = UIFont.suit(size: 14, weight: .semibold)
        $0.isHidden = true
    }

    private lazy var qrButton = QRButton(frame: CGRect(x: 0, y: 0, width: 64, height: 64), backgroundColor: .color.gomsPrimary.color).then {
        $0.addTarget(self, action: #selector(qrButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Selectors
    @objc func qrButtonTapped() {
        let qrCodeVC = StudentQRViewController()
        self.navigationController?.pushViewController(qrCodeVC, animated: true)
    }

    // MARK: - Life Cycel
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        outingListCollectionView.reloadData()
    }
        
    public override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.getOutingList {
            self.outingList = self.viewModel.outingListDatas
            self.setup()
        }
    }
    
    // MARK: - Setting
    public override func configNavigation() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "외출 현황"
        navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationController?.navigationBar.isHidden = false
    }
    
    func setup() {
        if outingList.isEmpty {
            searchTitle.isHidden = true
            coffeeIcon.isHidden = false
            outingNilLabel.isHidden = false
        } else {
            searchTitle.isHidden = false
            coffeeIcon.isHidden = true
            outingNilLabel.isHidden = true
        }
        setupSearchBar()
        setupCollectionView()
        setupScrollView()
    }
    
    private func setupScrollView() {
        addView()
        configureRefreshControl()
    }
    
    // MARK: - Refresh Control Setup
    private func configureRefreshControl() {
        outingListCollectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        refreshControl.tintColor = .color.gomsPrimary.color
    }

    @objc private func handleRefreshControl() {
        viewModel.gomsRefreshToken.tokenReissuance(){ success in}
        viewModel.getOutingList {
            self.outingList = self.viewModel.outingListDatas
            DispatchQueue.main.async {
                self.outingListCollectionView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func setupSearchBar() {
        searchController.searchBar.placeholder = "학생 검색"
        searchController.searchResultsUpdater = self
    }

    private func setupCollectionView() {
        self.outingListCollectionView.dataSource = self
        self.outingListCollectionView.delegate = self
        outingListCollectionView.register(OutingListCollectionViewCell.self, forCellWithReuseIdentifier: OutingListCollectionViewCell.identifier)
    }
    
    // MARK: - Configure UI
    public override func configureUI() {
        view.backgroundColor = .color.background.color
        qrButton.layer.cornerRadius = qrButton.frame.size.width / 2
        qrButton.clipsToBounds = true
    }
    
    // MARK: - Add View
    public override func addView() {
        [searchTitle, outingListCollectionView, coffeeIcon, outingNilLabel, qrButton].forEach { view.addSubview($0) }
    }
    
    // MARK: - Layout
    public override func setLayout() {
        searchTitle.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            $0.leading.equalTo(bounds.width * 0.05)
            $0.height.equalTo(32)
        }
        
        outingListCollectionView.snp.makeConstraints {
            $0.top.equalTo(searchTitle.snp.bottom).offset(8)
            $0.leading.equalTo(bounds.width * 0.05)
            $0.trailing.equalTo(-(bounds.width * 0.05))
            $0.bottom.equalToSuperview()
        }
        
        coffeeIcon.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.height.width.equalTo(80)
            $0.top.equalTo(bounds.height * 0.49)
        }
        
        outingNilLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.height.equalTo(24)
            $0.top.equalTo(coffeeIcon.snp.bottom).offset(8)
        }
        
        qrButton.snp.makeConstraints {
            $0.height.width.equalTo(64)
            $0.trailing.equalTo(-(bounds.width * 0.05))
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
    }
}

// MARK: - Extension
extension OutingViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return outingList.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = outingListCollectionView.dequeueReusableCell(withReuseIdentifier: OutingListCollectionViewCell.identifier, for: indexPath) as! OutingListCollectionViewCell
    
        let outingData = outingList[indexPath.row]
        cell.configureData(with: outingData)
        
        return cell
    }
}

extension OutingViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = bounds.width * 0.9
        let height: CGFloat = 72
        return CGSize(width: width, height: height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension OutingViewController: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        guard let searchString = searchController.searchBar.text else { return }
        if searchString.isEmpty {
            outingList = viewModel.outingListDatas
        } else {
            viewModel.searchStudent(searchString: searchString) {
                self.outingList = self.viewModel.outingSearchListDatas
                self.outingListCollectionView.reloadData()
            }
        }
    }
}
