//
//  AdminOutingStatusViewController.swift
//  Feature
//
//  Created by 김준표 on 2/25/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit

public final class AdminOutingViewController: BaseViewController, AdminOutingCellDelegate {
    
    private let viewModel = OutingViewModel()
    
    var outingList: [OutingListData] = []
    
    let refreshControl = UIRefreshControl()

    private lazy var customBackButton = UIButton().then {
        let backImage = UIImage(named: "Back", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        $0.setImage(backImage, for: .normal)
        $0.setTitle(" 돌아가기", for: .normal)
        $0.setTitleColor(UIColor.color.sub2.color, for: .normal)
        $0.tintColor = UIColor.color.sub2.color
        $0.titleLabel?.font = .suit(size: 18, weight: .medium)
        $0.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }
    
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
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        addView()
        setLayout()
        configureUI()

        viewModel.getOutingList {
            self.outingList = self.viewModel.outingListDatas
            DispatchQueue.main.async {
                self.outingListCollectionView.reloadData()
                self.setup()
            }
        }
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = .color.sub2.color
    }
    
    public override func configNavigation() {
        self.navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "외출 현황"
        navigationController?.navigationBar.tintColor = .color.sub2.color
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func setup() {
        if outingList.isEmpty {
            searchResultLabel.isHidden = true
            outingListCollectionView.isHidden = true
            coffeeIcon.isHidden = false
            outingNilLabel.isHidden = false
        } else {
            searchResultLabel.isHidden = false
            outingListCollectionView.isHidden = false
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
                self.setup()
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
            self.setup()
            self.outingListCollectionView.reloadData()
        } else {
            viewModel.searchStudent(searchString: searchText) {
                self.outingList = self.viewModel.outingSearchListDatas
                DispatchQueue.main.async {
                    self.setup()
                    self.outingListCollectionView.reloadData()
                }
            }
        }
    }
    
    @objc private func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }

    public override func configureUI() {
        view.backgroundColor = .color.background.color
    }
    
    public override func addView() {
        [customBackButton, searchTitle, searchTextField, searchResultLabel, outingListCollectionView, coffeeIcon, outingNilLabel].forEach { view.addSubview($0) }
    }
        
    public override func setLayout() {
        customBackButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.equalToSuperview().offset(20)
        }

        searchTitle.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.top.equalTo(customBackButton.snp.bottom).offset(16)
            $0.leading.equalToSuperview().inset(bounds.width * 0.05)
        }
        
        searchTextField.snp.makeConstraints {
            $0.top.equalTo(searchTitle.snp.bottom).offset(4)
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

    public override func shouldShowCustomNavigation() -> Bool {
        return false
    }
}

extension AdminOutingViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return outingList.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = outingListCollectionView.dequeueReusableCell(withReuseIdentifier: AdminOutingCollectionViewCell.identifier, for: indexPath) as! AdminOutingCollectionViewCell

        cell.delegate = self
        cell.tag = indexPath.item

        let outingData = outingList[indexPath.row]
        cell.configureData(with: outingData)

        return cell
    }
}

extension AdminOutingViewController: UICollectionViewDelegate {
    func deleteButtonTapped(cell: AdminOutingCollectionViewCell) {
        guard let indexPath = outingListCollectionView.indexPath(for: cell) else { return }
        let index = indexPath.item

        GOMSAlert.show(
            in: self,
            title: "강제외출 복귀",
            message: "학생을 복귀 상태로 변경하시겠습니까?",
            actionTitle: "복귀",
            isNegative: true,
            highlightKeywords: [],
            action: {
                guard index < self.outingList.count else { return }

                let target = self.outingList[index]
                self.viewModel.forceOutingStudent(user: target) {
                    DispatchQueue.main.async {
                        self.viewModel.getOutingList {
                            self.outingList = self.viewModel.outingListDatas
                            self.setup()
                            self.outingListCollectionView.reloadData()
                        }
                    }
                }
            }
        )
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
