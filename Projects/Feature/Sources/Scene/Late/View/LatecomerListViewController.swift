//
//  LatecomerListViewController.swift
//  Feature
//
//  Created by 김준표 on 2/25/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit

public final class LatecomerListViewController: BaseViewController {

    // MARK: - Properties
    var latecomerList: [LatecomerListData] = [] {
        didSet {
            DispatchQueue.main.async {
                self.lateListCollectionView.reloadData()
            }
        }
    }
    
    var date: String = {
        let currentDate = Date()
        let lastWednesday = currentDate.lastWednesday()
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko")
        formatter.dateFormat = "yyyy년 M월 d일 (E)"
        
        return formatter.string(from: lastWednesday)
    }()
    
    private var dateLabel = UILabel().then {
        $0.textColor = .color.mainText.color
        $0.font = .suit(size: 18, weight: .semibold)
    }
    
    private let viewModel = LetecomerViewModel()
    
    private let scrollView = UIScrollView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private let contentView1 = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var  filterButton = UIButton().then {
        $0.setTitle("필터", for: .normal)
        $0.backgroundColor = .clear
        $0.setTitleColor(.color.gomsInformation.color, for: .normal)
        $0.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
    }
    
    lazy var lateListCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init()).then {
        $0.backgroundColor = .clear
        $0.isScrollEnabled = true
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = true
        $0.clipsToBounds = true
        $0.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    // MARK: - Life Cycel
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        viewModel.getLatecomerList { latecomerList in
            self.dateLabel.text = self.date
            self.latecomerList = latecomerList
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lateListCollectionView.dataSource = self
        self.lateListCollectionView.delegate = self
        
        setupCollectionView()
        configNavigation()
        setupScrollView()
    }
    
    func setDateString(date: String) {
        dateLabel.text = date
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView1)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView1.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView)
            make.bottom.equalTo(lateListCollectionView.snp.bottom)
        }
        addView()
    }

    @objc func filterButtonTapped() {
        let bottomSheetVC = CalendarBottomSheetVC(latecomerListVC: self)
        bottomSheetVC.modalPresentationStyle = .overFullScreen
        self.present(bottomSheetVC, animated: false, completion: nil)
    }
    
    public override func configNavigation() {
        super.configNavigation()
        navigationController?.navigationBar.tintColor = .color.admin.color
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "지각자 명단"
    }
    
    func setupCollectionView() {
        self.lateListCollectionView.dataSource = self
        self.lateListCollectionView.delegate = self
        lateListCollectionView.register(LatecomerCollectionViewCell.self, forCellWithReuseIdentifier: LatecomerCollectionViewCell.identifier)
    }
    
    public override func addView() {
        [dateLabel, filterButton, lateListCollectionView].forEach { view.addSubview($0) }
    }
    
    public override func setLayout() {
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            $0.leading.equalTo(bounds.width * 0.05)
            $0.height.equalTo(32)
        }
        
        filterButton.snp.makeConstraints {
            $0.height.equalTo(32)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            $0.trailing.equalTo(-bounds.width * 0.05)
        }
        
        lateListCollectionView.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(8)
            $0.leading.equalTo(bounds.width * 0.05)
            $0.trailing.equalTo(-(bounds.width * 0.05))
            $0.bottom.equalToSuperview()
        }
    }
}

// MARK: - Extension
extension LatecomerListViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return latecomerList.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = lateListCollectionView.dequeueReusableCell(withReuseIdentifier: LatecomerCollectionViewCell.identifier, for: indexPath) as! LatecomerCollectionViewCell
        
        let latecomerData = latecomerList[indexPath.item]
        cell.configureData(lateData: latecomerData)
        
        return cell
    }
}

extension LatecomerListViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = bounds.width * 0.9
        let height: CGFloat = 72
        return CGSize(width: width, height: height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
