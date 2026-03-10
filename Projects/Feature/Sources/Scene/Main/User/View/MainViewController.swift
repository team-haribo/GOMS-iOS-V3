//
//  MainViewController.swift
//  Feature
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import Kingfisher
import Service

public final class MainViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // MARK: - Properties
    private let mainViewModel = MainViewModel()
    private let profileViewModel = ProfileViewModel()
    private let profileView = MainProfileView()
    private let basicsProfileView = ProfileCardView()
    private let authViewModel = AuthViewModel()
    private let lateCell = LateCell()

    let refreshControl = UIRefreshControl()
    let scrollView = UIScrollView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    let contentView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    var isClockOn: Bool = UserDefaults.standard.bool(forKey: "isClockOn") {
        didSet {
            updateLayout()
        }
    }

    let content = UIView()

    private let logo = UIImageView(image: UIImage(named: "gomsLightGrayLogo"))

    private lazy var settingButton = ExpandableButton().then {
        $0.setBackgroundImage(UIImage(named: "gomsSetting"), for: .normal)
        $0.addTarget(self, action: #selector(settingButtonTapped), for: .touchUpInside)
        $0.expandedTouchArea = 30
    }

    private let latecomerLabel = UILabel().then {
        $0.text = "지각자 TOP 3"
        $0.setDynamicTextColor(darkModeColor: .white, lightModeColor: .black)
        $0.font = UIFont.suit(size: 18, weight: .semibold)
    }

    lazy var lateNilView = LateNilView()

    private lazy var latecomerCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init()).then {
        $0.isScrollEnabled = false
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = true
        $0.backgroundColor = .clear
    }

    private let outingView = UIView()

    private let outingStatusLabel = UILabel().then {
        $0.text = "외출현황"
        $0.textColor = .color.mainText.color
        $0.font = UIFont.suit(size: 18, weight: .semibold)
    }

    private lazy var moreOutingStatusButton = UIButton().then {
        $0.backgroundColor = .color.surface.color
        $0.setTitle("더보기", for: .normal)
        $0.setTitleColor(.color.sub2.color, for: .normal)
        $0.titleLabel?.font = .suit(size: 13, weight: .regular)
        $0.layer.cornerRadius = 4
        $0.layer.masksToBounds = true
        $0.addTarget(self, action: #selector(moreOutingStatusButtonTapped), for: .touchUpInside)
    }

    let outingCountLabel = UILabel().then {
        $0.textColor = .color.sub2.color
        $0.font = UIFont.suit(size: 14, weight: .medium)
    }

    lazy var outingStatusCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init()).then {
        $0.isScrollEnabled = true
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = true
        $0.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -0)
        $0.backgroundColor = .clear
    }

    private lazy var qrButton = QRButton(frame: CGRect(x: 0, y: 0, width: 64, height: 64), backgroundColor: .color.gomsPrimary.color).then {
        $0.addTarget(self, action: #selector(qrButtonTapped), for: .touchUpInside)
    }
    
    private let tabBar = TabBar()

    private enum TabType {
        case home
        case map
    }

    private let mapContainerView = UIView().then {
        $0.isHidden = true
        $0.backgroundColor = .clear
    }

    private var selectedTab: TabType = .home {
        didSet {
            updateSelectedTab()
        }
    }

    private var isVisible: Bool = false

    // MARK: - Selectors
    @objc func settingButtonTapped() {
        settingButton.isUserInteractionEnabled = false
        
        let profileVC = UserProfileViewController()
        navigationController?.pushViewController(profileVC, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            self.settingButton.isUserInteractionEnabled = true
        }
    }

    @objc func moreOutingStatusButtonTapped() {
        let outingVC = OutingViewController()
        navigationController?.pushViewController(outingVC, animated: true)
    }

    @objc func qrButtonTapped() {
        qrButton.isUserInteractionEnabled = false

        let qrCodeVC = StudentQRViewController()
        self.navigationController?.pushViewController(qrCodeVC, animated: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            self.qrButton.isUserInteractionEnabled = true
        }
    }

    func selectHomeTab() {
        selectedTab = .home
    }

    func selectMapTab() {
        selectedTab = .map
    }

    private func updateSelectedTab() {
        let isHome = selectedTab == .home

        scrollView.isHidden = !isHome
        mapContainerView.isHidden = isHome
        qrButton.isHidden = !isHome

        view.bringSubviewToFront(tabBar)
        view.bringSubviewToFront(qrButton)
    }

    private func bindTabBar() {
        tabBar.onTabSelected = { [weak self] tab in
            guard let self = self else { return }

            switch tab {
            case .home:
                self.tabBar.selectedTab = .home
                self.selectHomeTab()
            case .map:
                self.tabBar.selectedTab = .map
                self.selectMapTab()
            case .profile:
                let profileVC = UserProfileViewController()
                self.navigationController?.pushViewController(profileVC, animated: true)
            }
        }
    }

    private func setupMap() {
        let mapVC = MapViewController()

        addChild(mapVC)
        mapContainerView.addSubview(mapVC.view)

        mapVC.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        mapVC.didMove(toParent: self)
    }

    // MARK: - Life Cycle
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isVisible = true

        mainViewModel.getLateList { [weak self] in
            self?.mainViewModel.getOutingList { [weak self] in
                self?.setup()
            }
        }
        
        fetchData()
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationItem.hidesBackButton = true
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isVisible = false
        refreshControl.endRefreshing()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.setHidesBackButton(true, animated: false)
        navigationController?.navigationBar.topItem?.hidesBackButton = true
        self.latecomerCollectionView.reloadData()
        self.outingStatusCollectionView.reloadData()
        bindTabBar()
        setupMap()
        handleRefreshControl()
        configureRefreshControl()
        updateSelectedTab()
        refreshControl.beginRefreshing()
    }

    func configureRefreshControl() {
        scrollView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        refreshControl.tintColor = .color.gomsPrimary.color
    }

    @objc func handleRefreshControl() {
        fetchData()
        guard let isLocalEmail = UserDefaults.standard.string(forKey: "localEmail"),
              let isLocalPass = UserDefaults.standard.string(forKey: "localPass") else {
            print("localEmail 또는 localPass 값이 없습니다.")
            let introVC = IntroViewController()
            self.navigationController?.setViewControllers([introVC], animated: false)
            self.refreshControl.endRefreshing()
            return
        }

        authViewModel.setupEmail(email: isLocalEmail)
        authViewModel.setupPassword(password: isLocalPass)

        authViewModel.signIn { [weak self] statusCode, _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                guard self.isVisible else {
                    self.refreshControl.endRefreshing()
                    return
                }

                switch statusCode {
                case 200:
                    self.profileViewModel.loadProfileInfo { [weak self] success, authority in
                        guard let self = self else { return }
                        DispatchQueue.main.async {
                            guard self.isVisible else {
                                self.refreshControl.endRefreshing()
                                return
                            }

                            if success {
                                if let authority = self.profileViewModel.profileInfo?.authority {
                                    let currentVC = self.navigationController?.viewControllers.last

                                    switch authority {
                                    case "ROLE_STUDENT_COUNCIL":
                                        if !(currentVC is AdminMainViewController) {
                                            let adminVC = AdminMainViewController()
                                            self.navigationController?.setViewControllers([adminVC], animated: false)
                                        }
                                    case "ROLE_STUDENT":
                                        if !(currentVC is MainViewController) {
                                            let mainVC = MainViewController()
                                            self.navigationController?.setViewControllers([mainVC], animated: false)
                                        }
                                    default:
                                        print("권한이 없습니다.")
                                    }
                                }
                            } else {
                                print("프로필 정보를 불러오는데 실패했습니다.")
                            }

                            self.refreshControl.endRefreshing()
                        }
                    }
                case 400:
                    print("400")
                    self.refreshControl.endRefreshing()
                case 404:
                    print("404")
                    self.refreshControl.endRefreshing()
                default:
                    print("error")
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }

    private func fetchData() {
        let group = DispatchGroup()

        group.enter()
        mainViewModel.getLateList { [weak self] in
            group.leave()
        }

        group.enter()
        mainViewModel.getProfile { [weak self] _ in
            group.leave()
        }

        group.enter()
        mainViewModel.getOutingList { [weak self] in
            group.leave()
        }

        group.notify(queue: .main) { [weak self] in
            guard let self = self, self.isVisible else {
                self?.refreshControl.endRefreshing()
                return
            }

            self.setupProfileView()
            self.setupViewComponents()
            self.latecomerCollectionView.reloadData()
            self.outingStatusCollectionView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }



    private func fetchData1() {
        let group = DispatchGroup()

        group.enter()
        mainViewModel.getLateList { [weak self] in
            group.leave()
        }

        group.enter()
        mainViewModel.getProfile { [weak self] _ in
            group.leave()
        }

        group.enter()
        mainViewModel.getOutingList { [weak self] in
            group.leave()
        }

        group.notify(queue: .main) { [weak self] in
            guard let self = self, self.isVisible else {
                self?.refreshControl.endRefreshing()
                return
            }
            self.setupProfileView()
            self.setupViewComponents()
            self.latecomerCollectionView.reloadData()
            self.outingStatusCollectionView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }


    private func setupViewComponents() {
        self.setup()
        self.view.layoutIfNeeded()
        self.setupCountLable()
        self.setCollectionView()
        self.setupProfileView()
        self.latecomerCollectionView.reloadData()
        self.outingStatusCollectionView.reloadData()

    }


    // MARK: - Setting
    func setup() {
        if self.mainViewModel.lateListDatas.count >= 1 {
            lateNilView.isHidden = true
        } else {
            lateNilView.isHidden = false
        }
        self.setCollectionView()
        self.setupCountLable()
    }

    func setupProfileView() {
        guard let grade = mainViewModel.profileData?.grade else { return }

        if let imageURL = mainViewModel.profileData?.profileUrl, let url = URL(string: imageURL) {
            basicsProfileView.profileImageView.kf.setImage(with: url, placeholder: UIImage(systemName: "person.crop.circle.fill"))
            basicsProfileView.profileImageView.layer.cornerRadius = basicsProfileView.profileImageView.frame.width / 2
        } else {
            basicsProfileView.profileImageView.image = .image.profile.image
        }

        basicsProfileView.nameLabel.text = mainViewModel.profileData?.name
        profileView.nameLabel.text = mainViewModel.profileData?.name
        if mainViewModel.profileData?.major == Major.sw.rawValue {
            profileView.studentInformationLabel.text = "\(grade)기 | SW개발"
            basicsProfileView.studentInformationLabel.text = "\(grade)기 | SW개발"
        } else if mainViewModel.profileData?.major == Major.iot.rawValue {
            profileView.studentInformationLabel.text = "\(grade)기 | IoT"
            basicsProfileView.studentInformationLabel.text = "\(grade)기 | IoT"
        } else {
            profileView.studentInformationLabel.text = "\(grade)기 | AI"
            basicsProfileView.studentInformationLabel.text = "\(grade)기 | AI"
        }
        basicsProfileView.lateCountLabel.text = "지각 횟수: \(mainViewModel.lateListDatas.count)회"

        if let isBlackList = mainViewModel.profileData?.isBlackList, let isOuting = mainViewModel.profileData?.isOuting {
            if isBlackList {
                profileView.profileStatus.text = "외출 금지"
                profileView.profileStatus.textColor = .color.gomsNegative.color
                basicsProfileView.myOutingStatusLabel.text = "외출 금지"
                basicsProfileView.myOutingStatusLabel.textColor = .color.gomsNegative.color
            } else if isOuting {
                profileView.profileStatus.text = "외출 중"
                profileView.profileStatus.textColor = .color.gomsPrimary.color
                basicsProfileView.myOutingStatusLabel.text = "외출 중"
                basicsProfileView.myOutingStatusLabel.textColor = .color.gomsPrimary.color
            } else {
                profileView.profileStatus.text = "외출 대기 중"
                profileView.profileStatus.textColor = .color.sub1.color
                basicsProfileView.myOutingStatusLabel.text = "외출 대기 중"
                basicsProfileView.myOutingStatusLabel.textColor = .color.sub1.color
            }
        }
    }

    private func setCollectionView() {
        self.outingStatusCollectionView.dataSource = self
        self.outingStatusCollectionView.delegate = self
        self.latecomerCollectionView.dataSource = self
        self.latecomerCollectionView.delegate = self
        outingStatusCollectionView.register(OutingStatusCollectionViewCell.self, forCellWithReuseIdentifier: OutingStatusCollectionViewCell.identifier)
        latecomerCollectionView.register(LateCell.self, forCellWithReuseIdentifier: LateCell.identifier)
    }

    func setupCountLable() {
        let attributedString = NSMutableAttributedString(string: "\(self.mainViewModel.outingListDatas.count)명이 외출 중")
        let range = (attributedString.string as NSString).range(of: "\(self.mainViewModel.outingListDatas.count)")
        attributedString.addAttribute(.foregroundColor, value: UIColor.color.gomsPrimary.color, range: range)
        attributedString.addAttribute(.font, value: UIFont.suit(size: 14, weight: .medium), range: range)
        self.outingCountLabel.attributedText = attributedString
    }

    // MARK: - Configure UI
    public override func configureUI() {
        qrButton.layer.cornerRadius = qrButton.frame.size.width / 2
        qrButton.clipsToBounds = false

        qrButton.layer.shadowColor = UIColor.color.gomsPrimary.color.cgColor
        qrButton.layer.shadowOpacity = 0.8
        qrButton.layer.shadowRadius = 13
        qrButton.layer.shadowOffset = CGSize(width: 0.81, height: 0.81)
    }
    // MARK: - Add View
    public override func addView() {
        view.addSubview(scrollView)
        view.addSubview(mapContainerView)
        scrollView.addSubview(contentView)

        [outingStatusLabel, moreOutingStatusButton, outingCountLabel, outingStatusCollectionView].forEach { self.outingView.addSubview($0) }
        [logo, settingButton, profileView, basicsProfileView, latecomerLabel, lateNilView, latecomerCollectionView, outingView].forEach { self.contentView.addSubview($0) }
        view.addSubview(qrButton)
        view.addSubview(tabBar)
    }

    // MARK: - Layout
    public override func setLayout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
            make.height.greaterThanOrEqualTo(view.snp.height).priority(.low)
        }

        tabBar.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(100)
        }

        mapContainerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(tabBar.snp.top)
        }

        qrButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(tabBar.snp.top).offset(-20)
            $0.height.width.equalTo(64)
        }

        logo.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalToSuperview().inset(20)
            $0.height.equalTo(24)
            $0.width.equalTo(87)
        }

        settingButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.height.equalTo(24)
        }

        updateLayout()

        lateNilView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(20)
            $0.top.equalTo(latecomerLabel.snp.bottom).offset(12)
        }

        latecomerCollectionView.snp.makeConstraints {
            $0.top.equalTo(lateNilView.snp.bottom).offset(0)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(136)
        }

        outingView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(lateNilView.snp.bottom).offset(24)
            $0.bottom.equalTo(contentView.snp.bottom).offset(-100)
        }

        outingStatusLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.height.equalTo(32)
            $0.top.equalToSuperview()
        }

        outingCountLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalTo(outingStatusLabel.snp.trailing).offset(8)
            $0.height.equalTo(32)
        }

        moreOutingStatusButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.equalTo(48)
            $0.height.equalTo(24)
        }

        outingStatusCollectionView.snp.makeConstraints {
            $0.top.equalTo(outingStatusLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
        }
    }

    func updateLayout() {
        profileView.snp.remakeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(logo.snp.bottom).offset(20)
            $0.height.equalTo(84)
        }

        latecomerLabel.snp.remakeConstraints {
            $0.top.equalTo(profileView.snp.bottom).offset(24)
            $0.leading.equalToSuperview().inset(20)
            $0.height.equalTo(32)
        }

        basicsProfileView.snp.remakeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(84)
            $0.top.equalTo(logo.snp.bottom).offset(20)
        }
        

        if isClockOn {
            profileView.isHidden = false
            basicsProfileView.isHidden = true
        } else {
            profileView.isHidden = true
            basicsProfileView.isHidden = false
        }

        view.layoutIfNeeded()
    }

    // MARK: - UICollectionViewDataSource
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == latecomerCollectionView {
            return mainViewModel.lateListDatas.count
        } else if collectionView == outingStatusCollectionView {
            return mainViewModel.outingListDatas.count
        }
        return 0
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == latecomerCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LateCell.identifier, for: indexPath) as? LateCell else { return UICollectionViewCell() }
            let data = mainViewModel.lateListDatas[indexPath.row]
            cell.configure(with: data)
            return cell
        } else if collectionView == outingStatusCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OutingStatusCollectionViewCell.identifier, for: indexPath) as? OutingStatusCollectionViewCell else { return UICollectionViewCell() }
            let data = mainViewModel.outingListDatas[indexPath.row]
            cell.configure(with: data)
            return cell
        }
        return UICollectionViewCell()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MainViewController {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == latecomerCollectionView {
            let width = bounds.width * 0.27
            let height: CGFloat = 136
            return CGSize(width: width, height: height)
        } else if collectionView == outingStatusCollectionView {
            let width = bounds.width * 0.9
            let height: CGFloat = 50
            return CGSize(width: width, height: height)
        }
        return CGSize(width: 0, height: 0)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == latecomerCollectionView {
            return bounds.width * 0.03
        } else if collectionView == outingStatusCollectionView {
            return 0
        }
        return 0
    }
}
