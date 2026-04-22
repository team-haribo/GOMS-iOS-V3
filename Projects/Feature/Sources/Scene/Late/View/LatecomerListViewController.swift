//
//  LatecomerListViewController.swift
//  Feature
//
//  Created by 김민선 on 4/21/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit
import Then

public final class LatecomerListViewController: BaseViewController {

    var latecomerList: [LatecomerListData] = [] {
        didSet {
            DispatchQueue.main.async {
                self.lateListCollectionView.reloadData()
            }
        }
    }
    
    private static let dateFormatter = DateFormatter().then {
        $0.locale = Locale(identifier: "ko")
        $0.dateFormat = "yyyy년 M월 d일 (E)"
    }
    
    var date: String {
        return Self.dateFormatter.string(from: Date())
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "지각자 명단"
        $0.textColor = .color.mainText.color
        $0.font = .suit(size: 24, weight: .bold)
    }
    
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
    
    private lazy var dateFilterButton = UIButton().then {
        $0.setTitle("날짜", for: .normal)
        $0.backgroundColor = .clear
        $0.setTitleColor(.color.admin.color, for: .normal)
        $0.titleLabel?.font = .suit(size: 18, weight: .regular)
        $0.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
    }
    
    private lazy var customBackButton = UIButton().then {
        let backImage = UIImage(named: "Back", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        $0.setImage(backImage, for: .normal)
        $0.setTitle(" 돌아가기", for: .normal)
        $0.setTitleColor(.color.admin.color, for: .normal)
        $0.tintColor = .color.admin.color
        $0.titleLabel?.font = .suit(size: 18, weight: .medium)
        $0.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }

    lazy var lateListCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        $0.backgroundColor = .clear
        $0.isScrollEnabled = true
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = true
        $0.clipsToBounds = true
    }
    
    public override func shouldShowCustomNavigation() -> Bool {
        return false
    }
    
    @objc private func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.dateLabel.text = self.date
        viewModel.getLatecomerList { [weak self] latecomerList in
            self?.latecomerList = latecomerList
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
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
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func setupCollectionView() {
        self.lateListCollectionView.dataSource = self
        self.lateListCollectionView.delegate = self
        lateListCollectionView.register(LatecomerCollectionViewCell.self, forCellWithReuseIdentifier: LatecomerCollectionViewCell.identifier)
    }
    
    public override func addView() {
        [customBackButton, titleLabel, dateLabel, dateFilterButton, lateListCollectionView].forEach { view.addSubview($0) }
    }
    
    public override func setLayout() {
        customBackButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            $0.leading.equalToSuperview().inset(16)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(customBackButton.snp.bottom).offset(20)
            $0.leading.equalToSuperview().inset(20)
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().inset(20)
        }
        
        dateFilterButton.snp.makeConstraints {
            $0.centerY.equalTo(dateLabel)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        lateListCollectionView.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
        }
    }
}

extension LatecomerListViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return latecomerList.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = lateListCollectionView.dequeueReusableCell(withReuseIdentifier: LatecomerCollectionViewCell.identifier, for: indexPath) as? LatecomerCollectionViewCell else {
            return UICollectionViewCell()
        }
        let latecomerData = latecomerList[indexPath.item]
        cell.configureData(lateData: latecomerData)
        return cell
    }
}

extension LatecomerListViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        return CGSize(width: width, height: 80)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
}
