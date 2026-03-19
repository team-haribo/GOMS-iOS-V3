//
//  AdminOutingStatusViewController.swift
//  Feature
//
//  Created by 김준표 on 2/25/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit

public final class AdminOutingViewController: BaseViewController, AdminOutingCellDelegate {
    
    // MARK: - Properties
    private let viewModel = OutingViewModel()
    
    var outingList: [OutingListData] = [] {
        didSet {
            outingListCollectionView.reloadData()
        }
    }
    
    let refreshControl = UIRefreshControl()
    
    private lazy var searchTextField = GOMSTextField(
        frame: CGRect(x: 0, y: 0, width: 0, height: 0),
        placeholder: "학생 검색"
    ).then {
        let searchIconView = UIImageView(image: .image.search.image.withRenderingMode(.alwaysTemplate))
        searchIconView.tintColor = .color.sub2.color
        searchIconView.contentMode = .scaleAspectFit
        searchIconView.frame = CGRect(x: 8, y: 0, width: 18, height: 18)

        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 26, height: 18))
        containerView.addSubview(searchIconView)

        $0.rightView = containerView
        $0.rightViewMode = .always
        $0.clearButtonMode = .never
        $0.returnKeyType = .search
    }
    
    private let searchTitle = UILabel().then {
        $0.text = "외출 현황"
        $0.textColor = .color.mainText.color
        $0.font = .suit(size: 29, weight: .bold)
    }
    
    private let searchResultLabel = UILabel().then {
        $0.text = "검색 결과"
        $0.textColor = .color.mainText.color
        $0.font = .suit(size: 18, weight: .semibold)
    }
    
    lazy var outingListCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init()).then {
        $0.backgroundColor = .clear
        $0.isScrollEnabled = true
        $0.showsHorizontalScrollIndicator = false
        $0.clipsToBounds = true
        $0.showsVerticalScrollIndicator = true
        $0.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    private let coffeeIcon = UIImageView().then {
        $0.image = .image.coffee.image
        $0.isHidden = true
    }
    
    private let outingNilLabel = UILabel().then {
        $0.text = "오늘은 외출하는 날이 아니에요!"
        $0.textColor = .color.sub2.color
        $0.font = UIFont.suit(size: 14, weight: .semibold)
        $0.isHidden = true
    }
    
    // MARK: - Life Cycel
    public override func viewDidLoad() {
        super.viewDidLoad()

        addView()
        setLayout()
        configureUI()

        setup()

        viewModel.getOutingList {
            self.outingList = self.viewModel.outingListDatas
            self.setup()
        }
    }
    
    // MARK: - Setting
    public override func configNavigation() {
        self.navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "외출 현황"
        self.navigationItem.hidesSearchBarWhenScrolling = false
    
    }
    
    func setup() {
        if outingList.isEmpty {
        
            searchResultLabel.isHidden = false
            coffeeIcon.isHidden = true
            outingNilLabel.isHidden = true
        } else {
            
            searchResultLabel.isHidden = false
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
        refreshControl.tintColor = .color.admin.color
    }

    @objc private func handleRefreshControl() {
        viewModel.gomsRefreshToken.tokenReissuance { success in
        }
        viewModel.getOutingList {
            self.outingList = self.viewModel.outingListDatas
            DispatchQueue.main.async {
                self.outingListCollectionView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    private func setupCollectionView() {
        self.outingListCollectionView.dataSource = self
        self.outingListCollectionView.delegate  = self
        
        outingListCollectionView.register(AdminOutingCollectionViewCell.self, forCellWithReuseIdentifier: AdminOutingCollectionViewCell.identifier)
    }
    
    func setupSearchBar() {
        searchTextField.font = .suit(size: 16, weight: .medium)
        searchTextField.textColor = .color.mainText.color
        searchTextField.backgroundColor = .color.inputBackground.color
        searchTextField.layer.borderWidth = 1
        searchTextField.layer.borderColor = UIColor.color.inputBackground.color.cgColor
        searchTextField.layer.cornerRadius = 12
        searchTextField.clipsToBounds = true
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 48))
        searchTextField.leftView = paddingView
        searchTextField.leftViewMode = .always
        searchTextField.addTarget(self, action: #selector(searchTextFieldEditingChanged(_:)), for: .editingChanged)
    }
    
    @objc private func searchTextFieldEditingChanged(_ textField: UITextField) {
        let searchText = textField.text ?? ""
        if searchText.isEmpty {
            outingList = viewModel.outingListDatas
        } else {
            viewModel.searchStudent(searchString: searchText) {
                self.outingList = self.viewModel.outingSearchListDatas
                self.outingListCollectionView.reloadData()
            }
        }
    }
    
    // MARK: - Configure UI
    public override func configureUI() {
        view.backgroundColor = .color.background.color
    }
    
    // MARK: - Add View
    public override func addView() {
        [searchTitle, searchTextField, searchResultLabel, outingListCollectionView, coffeeIcon, outingNilLabel].forEach { view.addSubview($0) }
    }
        
    // MARK: - Layout
    public override func setLayout() {
        searchTitle.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.top.equalToSuperview().inset(100)
            $0.leading.equalToSuperview().inset(bounds.width * 0.05)
        }
        
        searchTextField.snp.makeConstraints {
            $0.top.equalTo(searchTitle.snp.bottom).offset(24)
            $0.leading.equalToSuperview().inset(bounds.width * 0.05)
            $0.trailing.equalToSuperview().inset(bounds.width * 0.05)
            $0.height.equalTo(48)
        }
        
        searchResultLabel.snp.makeConstraints {
            $0.top.equalTo(searchTextField.snp.bottom).offset(24)
            $0.leading.equalToSuperview().inset(bounds.width * 0.05)
            $0.height.equalTo(24)
        }
        
        outingListCollectionView.snp.makeConstraints {
            $0.top.equalTo(searchResultLabel.snp.bottom).offset(8)
            $0.leading.equalTo(bounds.width * 0.05)
            $0.trailing.equalTo(-(bounds.width * 0.05))
            $0.bottom.equalToSuperview()
        }
        
        coffeeIcon.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(40)
            $0.size.equalTo(80)
        }
        
        outingNilLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(coffeeIcon.snp.bottom).offset(12)
        }
    }
}

// MARK: - Extension
extension AdminOutingViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return outingList.isEmpty ? 5 : outingList.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = outingListCollectionView.dequeueReusableCell(withReuseIdentifier: AdminOutingCollectionViewCell.identifier, for: indexPath) as! AdminOutingCollectionViewCell

        cell.delegate = self
        cell.tag = indexPath.row

        if outingList.isEmpty {
            cell.contentView.alpha = 1.0
            cell.configureDummy()
        } else {
            cell.contentView.alpha = 1.0
            let outingData = outingList[indexPath.row]
            cell.configureData(with: outingData)
        }

        return cell
    }
}

extension AdminOutingViewController: UICollectionViewDelegate {
    func deleteButtonTapped(index: Int) {
        let alertController = UIAlertController(title: "외출 강제 복귀", message: "외출자를 강제로 복귀시키시겠습니까?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "복귀", style: .destructive, handler: { _ in
            self.viewModel.deleteOutingStudent(user: self.outingList[index]) {
                self.outingList = self.viewModel.outingListDatas
                self.viewModel.getOutingList {
                    self.outingList = self.viewModel.outingListDatas
                    DispatchQueue.main.async {
                        self.outingListCollectionView.reloadData()
                        self.searchTextField.text = ""
                    }
                }
            }
        }))
        present(alertController, animated: true, completion: nil)
    }
}

extension AdminOutingViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = bounds.width * 0.9
        let height: CGFloat = 72
        return CGSize(width: width, height: height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

