//
//  AdminMainViewController.swift
//  Feature
//
//  Created by 김준표 on 2/25/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import Kingfisher
import Service
import SnapKit
import Then

public class AdminMainViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // MARK: - Properties
    private let viewModel = MainViewModel()
    private let basicsProfileView = ProfileCardView()
    private let authViewModel = AuthViewModel()
    private let profileViewModel = ProfileViewModel()
    private let profileView = MainProfileView()
    let refreshControl = UIRefreshControl()

    let scrollView = UIScrollView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.showsVerticalScrollIndicator = true
        $0.showsHorizontalScrollIndicator = false
    }

    let contentView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    var isClockOn: Bool = UserDefaults.standard.bool(forKey: "isClockOn") {
        didSet {
            basicsProfileView.isClockOn = isClockOn
            profileView.isClockOn = isClockOn
            updateLayout()
        }
    }

    let content = UIView()

    private let logo = UIImageView().then {
        $0.image = UIImage(named: "graylogo", in: Bundle.module, compatibleWith: nil)
    }

    private lazy var adminMenuButton = ExpandableButton().then {
        let image = UIImage.image.adminMenu.image
        $0.setBackgroundImage(image, for: .normal)
        $0.addTarget(self, action: #selector(adminMenuButtonTapped), for: .touchUpInside)
        $0.expandedTouchArea = 30
    }

    private lazy var reportButton = UIButton().then {
        let image = UIImage(named: "Warning", in: Bundle.module, compatibleWith: nil)
        $0.setImage(image, for: .normal)
        $0.contentHorizontalAlignment = .fill
        $0.contentVerticalAlignment = .fill
        $0.imageView?.contentMode = .scaleAspectFit
        $0.addTarget(self, action: #selector(reportButtonTapped), for: .touchUpInside)
    }
    
    private let latecomerLabel = UILabel().then {
        $0.text = "지각자 TOP 3"
        $0.setDynamicTextColor(darkModeColor: .white, lightModeColor: .black)
        $0.font = UIFont.suit(size: 18, weight: .semibold)
    }

    private lazy var moreLatecomerButton = UIButton().then {
        $0.backgroundColor = .color.surface.color
        $0.setTitle("더보기", for: .normal)
        $0.setTitleColor(.color.sub2.color, for: .normal)
        $0.titleLabel?.font = .suit(size: 13, weight: .regular)
        $0.layer.cornerRadius = 4
        $0.layer.masksToBounds = true
        $0.addTarget(self, action: #selector(moreLatecomerButtonTapped), for: .touchUpInside)
    }

    let lateNilView = LateNilView()
    private let outingView = UIView()

    lazy var latecomerCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init()).then {
        $0.isScrollEnabled = false
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = true
        $0.backgroundColor = .clear
    }

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

    private let tabBar = TabBar()
    private let mapContainerView = UIView()
    private let mapVC = MapViewController()
    private let profileContainerView = UIView()
    private let profileVC = AdminProfileViewController()
    
    private lazy var qrButton = AdminQRButton(
        frame: CGRect(x: 0, y: 0, width: 64, height: 64),
        backgroundColor: .color.admin.color,
        icon: .image.adminprofile.image
    ).then {
        $0.addTarget(self, action: #selector(qrButtonTapped), for: .touchUpInside)
    }

    private lazy var codeButton = AdminQRButton(
        frame: CGRect(x: 0, y: 0, width: 64, height: 64),
        backgroundColor: .color.admin.color,
        icon: .image.qrIcon.image
    ).then {
        $0.addTarget(self, action: #selector(codeButtonTapped), for: .touchUpInside)
    }

    private func setupNavigationBar() {
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationItem.hidesBackButton = true
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    private var isVisible: Bool = false

    // MARK: - Life Cycle
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isVisible = true
        isClockOn = UserDefaults.standard.bool(forKey: "isClockOn")
        syncRoleAndFetch()
        setupNavigationBar()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isVisible = false
        refreshControl.endRefreshing()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        configureRefreshControl()
        refreshControl.beginRefreshing()
        bindTabBar()
        setupMapContainer()
        setupProfileContainer()

        mapContainerView.isHidden = true
        profileContainerView.isHidden = true

        [mapContainerView, profileContainerView, tabBar, qrButton, codeButton].forEach { view.bringSubviewToFront($0) }
    }

    func configureRefreshControl() {
        scrollView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        refreshControl.tintColor = .color.admin.color
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

        authViewModel.signIn { [weak self] statusCode, _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                guard self.isVisible else { self.refreshControl.endRefreshing(); return }
                if statusCode == 200 {
                    self.profileViewModel.loadProfileInfo { success, _ in
                        DispatchQueue.main.async {
                            guard self.isVisible else {
                                self.refreshControl.endRefreshing()
                                return
                            }
                            if success {
                                if let authority = self.profileViewModel.profileInfo?.authority {
                                    let currentVC = self.navigationController?.viewControllers.last
                                    switch authority {
                                    case "ROLE_STUDENT":
                                        if !(currentVC is MainViewController) {
                                            let mainVC = MainViewController()
                                            self.navigationController?.setViewControllers([mainVC], animated: false)
                                        }
                                    case "ROLE_STUDENT_COUNCIL":
                                        if !(currentVC is AdminMainViewController) {
                                            let adminVC = AdminMainViewController()
                                            self.navigationController?.setViewControllers([adminVC], animated: false)
                                        }
                                    default:
                                        print("권한이 없습니다.")
                                    }
                                }
                            }
                            self.refreshControl.endRefreshing()
                        }
                    }
                } else {
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }

    /// 앱 재진입 또는 화면 진입 시 최신 role을 서버에서 확인해 화면을 전환한다.
    /// 1. reissue로 토큰을 갱신 (새 JWT에 최신 role 포함)
    /// 2. /member/myrole로 현재 role 확인
    /// 3. role이 ROLE_STUDENT로 바뀌었으면 MainViewController로 전환
    private func syncRoleAndFetch() {
        viewModel.gomsRefreshToken.tokenReissuance { [weak self] success in
            guard let self else { return }
            if success {
                self.viewModel.getProfile { [weak self] authority in
                    guard let self else { return }
                    DispatchQueue.main.async {
                        guard self.isVisible else { return }
                        if authority == "ROLE_STUDENT" {
                            let mainVC = MainViewController()
                            self.navigationController?.setViewControllers([mainVC], animated: false)
                            return
                        }
                        self.fetchData()
                    }
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    guard let self, self.isVisible else { return }
                    self.fetchData()
                }
            }
        }
    }

    private func fetchData() {
        let group = DispatchGroup()
        
        group.enter()
        viewModel.getLateList { group.leave() }
        
        group.enter()
        viewModel.getProfile { _ in group.leave() }
        
        group.enter()
        profileViewModel.loadProfileInfo { _, _ in group.leave() }
        
        group.enter()
        viewModel.getOutingList { group.leave() }

        group.notify(queue: .main) { [weak self] in
            guard let self = self, self.isVisible else { self?.refreshControl.endRefreshing(); return }
            self.setupViewComponents()
            self.refreshControl.endRefreshing()
        }
    }

    private func setupViewComponents() {
        self.setup()
        self.setupProfileView()
        self.latecomerCollectionView.reloadData()
        self.outingStatusCollectionView.reloadData()
        self.view.layoutIfNeeded()
    }

    func setup() {
        let isLateEmpty = self.viewModel.lateListDatas.isEmpty
        updateLateView(hasLateStudents: !isLateEmpty)
        
        // 외출 현황은 데이터 유무와 관계없이 항상 표시 (isHidden 로직 제거)
        outingView.isHidden = false

        self.setCollectionView()
        self.setupCountLable()
    }

    private func setCollectionView() {
        outingStatusCollectionView.dataSource = self
        outingStatusCollectionView.delegate = self
        outingStatusCollectionView.register(OutingStatusCollectionViewCell.self, forCellWithReuseIdentifier: OutingStatusCollectionViewCell.identifier)

        latecomerCollectionView.dataSource = self
        latecomerCollectionView.delegate = self
        latecomerCollectionView.register(LateCell.self, forCellWithReuseIdentifier: LateCell.identifier)
    }

    func setupCountLable() {
        let count = viewModel.outingListDatas.count
        // 0명일 때도 레이블을 숨기지 않고 0명임을 표시하거나, 필요에 따라 레이블만 비움
        outingCountLabel.isHidden = false
        let attributedString = NSMutableAttributedString(string: "\(count)명이 외출 중")
        let range = (attributedString.string as NSString).range(of: "\(count)")
        attributedString.addAttribute(.foregroundColor, value: UIColor.color.admin.color, range: range)
        attributedString.addAttribute(.font, value: UIFont.suit(size: 14, weight: .medium), range: range)
        self.outingCountLabel.attributedText = attributedString
    }

    func setupProfileView() {
        guard let profile = viewModel.profileData else { return }
        let grade = profile.grade ?? 0
        let name = profile.name ?? "이름 없음"
        let department = profile.department ?? ""
        
        let urlString = profileViewModel.profileInfo?.profileImageUrl
        let url = URL(string: urlString ?? "")
        let placeholder = UIImage.image.profile.image
        
        [basicsProfileView.profileImageView, profileView.profileImageView].forEach {
            $0.kf.setImage(with: url, placeholder: placeholder)
        }

        profileView.isAdmin = true
        profileView.nameLabel.text = name
        profileView.profileStatus.text = "관리자"
        profileView.profileStatus.textColor = .color.admin.color
        profileView.lateCountLabel.isHidden = true

        basicsProfileView.nameLabel.text = name

        let majorText = (department == Major.sw.rawValue) ? "SW" : (department == Major.iot.rawValue) ? "IoT" : (department == Major.ai.rawValue) ? "AI" : ""
        let studentInfoText = "\(grade)기 | \(majorText)"
        
        basicsProfileView.studentInformationLabel.text = studentInfoText
        profileView.studentInformationLabel.text = studentInfoText

        basicsProfileView.configure(name: name, studentInfo: studentInfoText, lateCount: 0, outingStatus: "관리자", isAdmin: true, profileImageUrl: urlString)
    }

    private func bindTabBar() {
        tabBar.onTabSelected = { [weak self] tab in
            guard let self = self else { return }
            self.tabBar.updateSelectedTab(tab)
            let isHome = (tab == .home)
            self.mapContainerView.isHidden = (tab != .map)
            self.profileContainerView.isHidden = (tab != .profile)
            self.scrollView.isHidden = !isHome
            [self.qrButton, self.codeButton].forEach { $0.isHidden = !isHome }
        }
    }

    private func setupMapContainer() {
        addChild(mapVC)
        mapContainerView.addSubview(mapVC.view)

        mapVC.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        mapVC.didMove(toParent: self)
    }

    private func setupProfileContainer() {
        addChild(profileVC)
        profileContainerView.addSubview(profileVC.view)
        profileVC.view.frame = profileContainerView.bounds
        profileVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        profileVC.didMove(toParent: self)
    }

    @objc func moreLatecomerButtonTapped() {
        navigationController?.pushViewController(LatecomerListViewController(), animated: true)
    }

    @objc func moreOutingStatusButtonTapped() {
        navigationController?.pushViewController(AdminOutingViewController(), animated: true)
    }

    @objc public func qrButtonTapped() {
        qrButton.isUserInteractionEnabled = false
        let studentManagementVC = StudentManagementViewController()
        navigationController?.pushViewController(studentManagementVC, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            self.qrButton.isUserInteractionEnabled = true
        }
    }

    @objc public func codeButtonTapped() {
        codeButton.isUserInteractionEnabled = false
        let adminQRVC = AdminQRViewController()
        self.navigationController?.pushViewController(adminQRVC, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.codeButton.isUserInteractionEnabled = true
        }
    }
    
    @objc func reportButtonTapped() {
        reportButton.isUserInteractionEnabled = false
        let reportListVC = ReportListViewController()
        self.navigationController?.pushViewController(reportListVC, animated: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.reportButton.isUserInteractionEnabled = true
        }
    }

    @objc func adminMenuButtonTapped() {
        adminMenuButton.isUserInteractionEnabled = false
        let adminMenuVC = AdminMenuViewController()
        self.navigationController?.pushViewController(adminMenuVC, animated: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            self.adminMenuButton.isUserInteractionEnabled = true
        }
    }

    public override func configureUI() {
        [qrButton, codeButton].forEach {
            $0.layer.cornerRadius = 32
            $0.layer.shadowColor = UIColor.color.admin.color.cgColor
            $0.layer.shadowOpacity = 0.8
            $0.layer.shadowRadius = 13
            $0.layer.shadowOffset = CGSize(width: 0.81, height: 0.81)
        }
    }

    public override func addView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        [outingStatusLabel, moreOutingStatusButton, outingCountLabel, outingStatusCollectionView].forEach { outingView.addSubview($0) }
        [logo, profileView, basicsProfileView, latecomerLabel, moreLatecomerButton, latecomerCollectionView, lateNilView, outingView, reportButton].forEach { contentView.addSubview($0) }
        [mapContainerView, profileContainerView, tabBar, qrButton, codeButton].forEach { view.addSubview($0) }
    }

    public override func setLayout() {
        scrollView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(tabBar.snp.top)
        }

        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
            $0.bottom.equalTo(outingView.snp.bottom).offset(40)
        }

        tabBar.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(100)
        }

        codeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(100)
            $0.size.equalTo(64)
        }

        qrButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(codeButton.snp.top).offset(-12)
            $0.size.equalTo(64)
        }

        logo.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalToSuperview()
            $0.height.equalTo(56)
            $0.width.equalTo(135)
        }

        reportButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(28)
            $0.centerY.equalTo(logo)
            $0.size.equalTo(26)
        }

        updateLayout()
        
        mapContainerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(tabBar.snp.top)
        }

        profileContainerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(tabBar.snp.top)
        }
    }

    func updateLayout() {
        profileView.snp.remakeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(84)
            $0.top.equalTo(logo.snp.bottom).offset(20)
        }

        basicsProfileView.snp.remakeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(84)
            $0.top.equalTo(logo.snp.bottom).offset(20)
        }

        latecomerLabel.snp.remakeConstraints {
            $0.top.equalTo(isClockOn ? profileView.snp.bottom : basicsProfileView.snp.bottom).offset(24)
            $0.leading.equalToSuperview().inset(20)
            $0.height.equalTo(32)
        }

        moreLatecomerButton.snp.makeConstraints {
            $0.centerY.equalTo(latecomerLabel)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.equalTo(48)
            $0.height.equalTo(24)
        }

        profileView.isHidden = !isClockOn
        basicsProfileView.isHidden = isClockOn
        
        updateLateView(hasLateStudents: !viewModel.lateListDatas.isEmpty)
        view.layoutIfNeeded()
    }

    func updateLateView(hasLateStudents: Bool) {
        if hasLateStudents {
            lateNilView.isHidden = true
            latecomerCollectionView.isHidden = false
            
            latecomerCollectionView.snp.remakeConstraints {
                $0.top.equalTo(latecomerLabel.snp.bottom).offset(12)
                $0.leading.trailing.equalToSuperview().inset(20)
                $0.height.equalTo(136)
            }
            
            outingView.snp.remakeConstraints {
                $0.top.equalTo(latecomerCollectionView.snp.bottom).offset(24)
                $0.leading.trailing.equalToSuperview()
                $0.bottom.equalToSuperview().offset(-100)
            }
        } else {
            lateNilView.isHidden = false
            latecomerCollectionView.isHidden = true
            
            lateNilView.snp.remakeConstraints {
                $0.top.equalTo(latecomerLabel.snp.bottom).offset(12)
                $0.leading.trailing.equalToSuperview().inset(20)
                $0.height.equalTo(20)
            }
            
            outingView.snp.remakeConstraints {
                $0.top.equalTo(lateNilView.snp.bottom).offset(24)
                $0.leading.trailing.equalToSuperview()
                $0.bottom.equalToSuperview().offset(-100)
            }
        }
        
        outingStatusLabel.snp.remakeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalToSuperview()
            $0.height.equalTo(32)
        }
        
        outingCountLabel.snp.remakeConstraints {
            $0.centerY.equalTo(outingStatusLabel)
            $0.leading.equalTo(outingStatusLabel.snp.trailing).offset(8)
        }
        
        moreOutingStatusButton.snp.remakeConstraints {
            $0.centerY.equalTo(outingStatusLabel)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.equalTo(48)
            $0.height.equalTo(24)
        }
        
        outingStatusCollectionView.snp.remakeConstraints {
            $0.top.equalTo(outingStatusLabel.snp.bottom).offset(17)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview()
            // 데이터가 0개여도 헤더 섹션은 유지되도록 최소 높이 확보 또는 계산 로직 유지
            let collectionHeight = max(0, viewModel.outingListDatas.count * 48 + 20)
            $0.height.equalTo(collectionHeight).priority(.low)
        }
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (collectionView == latecomerCollectionView) ? viewModel.lateListDatas.count : viewModel.outingListDatas.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == latecomerCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LateCell.identifier, for: indexPath) as? LateCell else { return UICollectionViewCell() }
            let data = viewModel.lateListDatas[indexPath.row]
            cell.configure(with: data)
            if let urlString = data.profileImageURL, let url = URL(string: urlString) {
                cell.profileImageView.kf.setImage(with: url, placeholder: UIImage.image.profile.image)
            } else {
                cell.profileImageView.image = UIImage.image.profile.image
            }
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OutingStatusCollectionViewCell.identifier, for: indexPath) as? OutingStatusCollectionViewCell else { return UICollectionViewCell() }
            let data = viewModel.outingListDatas[indexPath.row]
            cell.configure(with: data)
            if let urlString = data.profileImageURL, let url = URL(string: urlString) {
                cell.profileImageView.kf.setImage(with: url, placeholder: UIImage.image.profile.image)
            } else {
                cell.profileImageView.image = UIImage.image.profile.image
            }
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension AdminMainViewController {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == latecomerCollectionView {
            let width = (view.bounds.width - 60) / 3
            return CGSize(width: width, height: 136)
        } else {
            return CGSize(width: collectionView.bounds.width, height: 44)
        }
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return (collectionView == latecomerCollectionView) ? 10 : 4
    }
}
