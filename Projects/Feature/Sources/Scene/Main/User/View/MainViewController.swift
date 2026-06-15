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
import Combine

public final class MainViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // MARK: - Properties
    private var cancellables = Set<AnyCancellable>()
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
            profileView.isClockOn = isClockOn
            updateLayout()
        }
    }

    let content = UIView()

    private let logo = UIImageView().then {
        $0.image = UIImage(
            named: "graylogo",
            in: Bundle.module,
            compatibleWith: nil
        )
    }

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

    lazy var lateNilView = LateNilView().then {
        $0.isHidden = true
    }

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
        $0.backgroundColor = .clear
    }

    private lazy var qrButton = QRButton(frame: CGRect(x: 0, y: 0, width: 64, height: 64), backgroundColor: .color.gomsPrimary.color).then {
        $0.addTarget(self, action: #selector(qrButtonTapped), for: .touchUpInside)
    }
    
    private let tabBar = TabBar()

    private enum TabType {
        case home
        case map
        case profile
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
    private var profileVC: UserProfileViewController?
    private var mapVC: MapViewController?

    // MARK: - Selectors
    @objc func settingButtonTapped() {
        settingButton.isUserInteractionEnabled = false
        showProfileOverlay()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.settingButton.isUserInteractionEnabled = true
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

    private func showProfileOverlay() {
        if profileVC != nil { return }

        let vc = UserProfileViewController()
        profileVC = vc

        addChild(vc)
        view.addSubview(vc.view)

        vc.view.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(tabBar.snp.top)
        }

        vc.didMove(toParent: self)
        qrButton.isHidden = true
        view.bringSubviewToFront(tabBar)
    }

    private func hideProfileOverlay() {
        guard let profile = profileVC else { return }

        profile.willMove(toParent: nil)
        profile.view.removeFromSuperview()
        profile.removeFromParent()
        profileVC = nil
        
        fetchData()
    }

    func selectHomeTab() {
        hideProfileOverlay()
        selectedTab = .home
    }

    func selectMapTab() {
        hideProfileOverlay()
        selectedTab = .map

        setupMap()
    }

    private func updateSelectedTab() {
        let isHome = selectedTab == .home

        scrollView.isHidden = !isHome
        mapContainerView.isHidden = isHome
        qrButton.isHidden = !isHome
        if profileVC != nil {
            qrButton.isHidden = true
        }

        view.bringSubviewToFront(tabBar)
        view.bringSubviewToFront(qrButton)
        if let profileView = profileVC?.view {
            view.bringSubviewToFront(profileView)
            view.bringSubviewToFront(tabBar)
        }
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
                self.tabBar.selectedTab = .profile
                self.showProfileOverlay()
            }
        }
    }

    private func setupMap() {
        if let existingMapVC = mapVC {
            existingMapVC.willMove(toParent: nil)
            existingMapVC.view.removeFromSuperview()
            existingMapVC.removeFromParent()
            mapVC = nil
        }

        let mapVC = MapViewController()
        self.mapVC = mapVC

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
        isClockOn = UserDefaults.standard.bool(forKey: "isClockOn")

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
        profileViewModel.$profileInfo
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.setupProfileView()
            }
            .store(in: &cancellables)
        handleRefreshControl()
        configureRefreshControl()
        updateSelectedTab()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleClockChanged),
            name: Notification.Name("clockChanged"),
            object: nil
        )
    }

    func configureRefreshControl() {
        scrollView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        refreshControl.tintColor = .color.gomsPrimary.color
    }
    
    func updateLateView(hasLateStudents: Bool) {
        if hasLateStudents {
            lateNilView.isHidden = true
            latecomerCollectionView.isHidden = false
            
            latecomerCollectionView.snp.remakeConstraints { make in
                make.top.equalTo(latecomerLabel.snp.bottom).offset(12)
                make.leading.trailing.equalToSuperview().inset(20)
                make.height.equalTo(136)
            }
            
            outingView.snp.remakeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.top.equalTo(latecomerCollectionView.snp.bottom).offset(24)
                make.bottom.equalTo(contentView.snp.bottom).offset(-100)
            }
        } else {
            lateNilView.isHidden = false
            latecomerCollectionView.isHidden = true
            
            lateNilView.snp.remakeConstraints { make in
                make.top.equalTo(latecomerLabel.snp.bottom).offset(12)
                make.leading.trailing.equalToSuperview().inset(20)
                make.height.equalTo(20)
            }
            
            outingView.snp.remakeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.top.equalTo(lateNilView.snp.bottom).offset(24)
                make.bottom.equalTo(contentView.snp.bottom).offset(-100)
            }
        }
        view.layoutIfNeeded()
    }

    @objc func handleRefreshControl() {
        fetchData()
        guard let isLocalEmail = UserDefaults.standard.string(forKey: "localEmail"),
              let isLocalPass = UserDefaults.standard.string(forKey: "localPass") else {
            let introVC = IntroViewController()
            self.navigationController?.setViewControllers([introVC], animated: false)
            self.refreshControl.endRefreshing()
            return
        }
        
        authViewModel.setupEmail(email: isLocalEmail)
        authViewModel.setupPassword(password: isLocalPass)
        
        authViewModel.signIn { [weak self] (statusCode: Int, _) in
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
                                      let introVC = IntroViewController()
                                      self.navigationController?.setViewControllers([introVC], animated: false)
                                    }
                                }
                            }
                            self.refreshControl.endRefreshing()
                        }
                    }
                default:
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }

    private func fetchData() {
        let group = DispatchGroup()

        group.enter()
        mainViewModel.getLateList {
            group.leave()
        }

        group.enter()
        mainViewModel.getProfile { _ in
            group.leave()
        }

        group.enter()
        mainViewModel.getOutingList {
            group.leave()
        }

        group.enter()
        profileViewModel.loadProfileInfo { _, _ in
            group.leave()
        }

        group.notify(queue: .main) { [weak self] in
            guard let self = self, self.isVisible else {
                self?.refreshControl.endRefreshing()
                return
            }

            self.setupViewComponents()
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
        let isLateEmpty = self.mainViewModel.lateListDatas.isEmpty

        updateLateView(hasLateStudents: !isLateEmpty)
        outingView.isHidden = false

        self.setCollectionView()
        self.setupCountLable()
    }

    func setupProfileView() {
        let profile = mainViewModel.profileData
        let grade = profile?.grade ?? 0
        let name = profile?.name ?? "이름 없음"
        let department = profile?.department ?? "정보 없음"
        let lateCount = profile?.lateCount ?? 0
        let status = profile?.status ?? "UNKNOWN"

        if let urlString = profileViewModel.profileInfo?.profileImageUrl,
           let url = URL(string: urlString) {
            basicsProfileView.profileImageView.kf.setImage(with: url, placeholder: UIImage.image.profile.image, options: [.forceRefresh])
            profileView.profileImageView.kf.setImage(with: url, placeholder: UIImage.image.profile.image, options: [.forceRefresh])
        } else {
            basicsProfileView.profileImageView.image = .image.profile.image
            profileView.profileImageView.image = .image.profile.image
        }

        basicsProfileView.nameLabel.text = name
        profileView.nameLabel.text = name

        let majorText = department == Major.sw.rawValue ? "SW" : (department == Major.iot.rawValue ? "IoT" : (department == Major.ai.rawValue ? "AI" : ""))
        let info = majorText.isEmpty ? "\(grade)기" : "\(grade)기 | \(majorText)"
        profileView.studentInformationLabel.text = info
        basicsProfileView.studentInformationLabel.text = info

        basicsProfileView.lateCountLabel.text = "지각 횟수: \(lateCount)회"
        profileView.lateCountLabel.text = "지각 횟수: \(lateCount)회"

        if status == "CANNOT_OUTING" {
            profileView.profileStatus.text = "외출 금지"
            profileView.profileStatus.textColor = .color.gomsNegative.color
            basicsProfileView.myOutingStatusLabel.text = "외출 금지"
            basicsProfileView.myOutingStatusLabel.textColor = .color.gomsNegative.color
        } else if status == "OUTING" {
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

    private func setCollectionView() {
        self.outingStatusCollectionView.dataSource = self
        self.outingStatusCollectionView.delegate = self
        self.latecomerCollectionView.dataSource = self
        self.latecomerCollectionView.delegate = self
        outingStatusCollectionView.register(OutingStatusCollectionViewCell.self, forCellWithReuseIdentifier: OutingStatusCollectionViewCell.identifier)
        latecomerCollectionView.register(LateCell.self, forCellWithReuseIdentifier: LateCell.identifier)
    }

    func setupCountLable() {
        let count = mainViewModel.outingListDatas.count
        let attributedString = NSMutableAttributedString(string: "\(count)명이 외출 중")
        let range = (attributedString.string as NSString).range(of: "\(count)")
        attributedString.addAttribute(.foregroundColor, value: UIColor.color.gomsPrimary.color, range: range)
        attributedString.addAttribute(.font, value: UIFont.suit(size: 14, weight: .medium), range: range)
        outingCountLabel.attributedText = attributedString
        outingCountLabel.isHidden = false
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
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(tabBar.snp.top)
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
            $0.top.equalTo(contentView.snp.top)
            $0.height.equalTo(56)
            $0.width.equalTo(135)
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
            $0.top.equalTo(latecomerLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(136)
        }

        outingView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(latecomerCollectionView.snp.bottom).offset(24)
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
            $0.top.equalTo(outingStatusLabel.snp.bottom).offset(17)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview()
        }
    }

    func updateLayout() {
        profileView.snp.remakeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(logo.snp.bottom).offset(20)
            $0.height.equalTo(84)
        }

        basicsProfileView.snp.remakeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(84)
            $0.top.equalTo(logo.snp.bottom).offset(20)
        }

        if isClockOn {
            profileView.isHidden = false
            basicsProfileView.isHidden = true
            
            latecomerLabel.snp.remakeConstraints {
                $0.top.equalTo(profileView.snp.bottom).offset(24)
                $0.leading.equalToSuperview().inset(20)
                $0.height.equalTo(32)
            }
        } else {
            profileView.isHidden = true
            basicsProfileView.isHidden = false
            
            latecomerLabel.snp.remakeConstraints {
                $0.top.equalTo(basicsProfileView.snp.bottom).offset(24)
                $0.leading.equalToSuperview().inset(20)
                $0.height.equalTo(32)
            }
        }
        view.layoutIfNeeded()
    }

    @objc private func handleClockChanged() {
        isClockOn = UserDefaults.standard.bool(forKey: "isClockOn")
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
            
            if !mainViewModel.outingListDatas.isEmpty {
                let data = mainViewModel.outingListDatas[indexPath.row]
                cell.configure(with: data, showTime: false)
            }
            return cell
        }
        return UICollectionViewCell()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MainViewController {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == latecomerCollectionView {
            let width = UIScreen.main.bounds.width * 0.27
            return CGSize(width: width, height: 136)
        } else if collectionView == outingStatusCollectionView {
            return CGSize(width: collectionView.bounds.width, height: 44)
        }
        return .zero
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return collectionView == latecomerCollectionView ? UIScreen.main.bounds.width * 0.03 : 0
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return collectionView == outingStatusCollectionView ? 4 : 10
    }
}
