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
        $0.image = UIImage(
            named: "graylogo",
            in: Bundle.module,
            compatibleWith: nil
        )
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

        fetchData()
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationItem.hidesBackButton = true
        self.navigationController?.setNavigationBarHidden(true, animated: false)
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

        navigationItem.setHidesBackButton(true, animated: false)
        navigationController?.navigationBar.topItem?.hidesBackButton = true
        navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationItem.backButtonTitle = ""
        self.navigationItem.hidesBackButton = true

        self.latecomerCollectionView.reloadData()
        self.outingStatusCollectionView.reloadData()
        configureRefreshControl()
        refreshControl.beginRefreshing()
        bindTabBar()
        setupMapContainer()
        setupProfileContainer()

        mapContainerView.isHidden = true
        profileContainerView.isHidden = true

        view.bringSubviewToFront(mapContainerView)
        view.bringSubviewToFront(profileContainerView)
        view.bringSubviewToFront(tabBar)
        view.bringSubviewToFront(qrButton)
        view.bringSubviewToFront(codeButton)
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
        viewModel.getLateList { [weak self] in group.leave() }

        group.enter()
        viewModel.getProfile { [weak self] _ in group.leave() }

        group.enter()
        profileViewModel.loadProfileInfo { _, _ in
            group.leave()
        }

        group.enter()
        viewModel.getOutingList { [weak self] in group.leave() }

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
        print("late:", viewModel.lateListDatas.count, "outing:", viewModel.outingListDatas.count)
        let isLateEmpty = self.viewModel.lateListDatas.isEmpty
        let isOutingEmpty = self.viewModel.outingListDatas.isEmpty

        lateNilView.isHidden = !isLateEmpty
        latecomerCollectionView.isHidden = isLateEmpty

        outingView.isHidden = isOutingEmpty

        self.setCollectionView()
        self.setupCountLable()
    }

    private func setCollectionView() {
        self.outingStatusCollectionView.dataSource = self
        self.outingStatusCollectionView.delegate = self

        outingStatusCollectionView.register(OutingStatusCollectionViewCell.self, forCellWithReuseIdentifier: OutingStatusCollectionViewCell.identifier)

        self.latecomerCollectionView.dataSource = self
        self.latecomerCollectionView.delegate = self

        latecomerCollectionView.register(LateCell.self, forCellWithReuseIdentifier: LateCell.identifier)
    }

    func setupCountLable() {
        let count = viewModel.outingListDatas.count

        
        if count == 0 {
            outingCountLabel.isHidden = true
            return
        } else {
            outingCountLabel.isHidden = false
        }

        let attributedString = NSMutableAttributedString(string: "\(count)명이 외출 중")
        let range = (attributedString.string as NSString).range(of: "\(count)")

        attributedString.addAttribute(.foregroundColor, value: UIColor.color.admin.color, range: range)
        attributedString.addAttribute(.font, value: UIFont.suit(size: 14, weight: .medium), range: range)

        self.outingCountLabel.attributedText = attributedString
    }

    func setupProfileView() {
        let profile = viewModel.profileData

        let grade = profile?.grade ?? 0
        let name = profile?.name ?? "이름 없음"
        let department = profile?.department ?? "정보 없음"

        // ✅ 프로필 이미지 (User랑 동일하게 ProfileViewModel 사용)
        if let urlString = profileViewModel.profileInfo?.profileImageUrl,
           let url = URL(string: urlString) {
            basicsProfileView.profileImageView.kf.setImage(
                with: url,
                placeholder: UIImage.image.profile.image,
                options: [.forceRefresh]
            )
            
            profileView.profileImageView.kf.setImage(
                with: url,
                placeholder: UIImage.image.profile.image,
                options: [.forceRefresh]
            )
        } else {
            basicsProfileView.profileImageView.image = .image.profile.image
            profileView.profileImageView.image = .image.profile.image
        }

        // 이름
        basicsProfileView.nameLabel.text = name
        profileView.nameLabel.text = name

        // 학과
        let majorText: String
        if department == Major.sw.rawValue {
            majorText = "SW"
        } else if department == Major.iot.rawValue {
            majorText = "IoT"
        } else {
            majorText = "AI"
        }

        basicsProfileView.studentInformationLabel.text = "\(grade)기 | \(majorText)"
        profileView.studentInformationLabel.text = "\(grade)기 | \(majorText)"

        // 관리자 상태 (기존 디자인 유지)
        profileView.profileStatus.text = "관리자"
        profileView.profileStatus.textColor = .color.admin.color

        profileView.lateCountLabel.isHidden = true
        profileView.lateCountLabel.text = ""

        basicsProfileView.configure(
            name: name,
            studentInfo: "\(grade)기 | \(majorText)",
            lateCount: 0,
            outingStatus: "관리자",
            isAdmin: true,
            profileImageUrl: profileViewModel.profileInfo?.profileImageUrl
        )

        profileView.isClockOn = isClockOn
    }


    private func bindTabBar() {
        tabBar.onTabSelected = { [weak self] tab in
            guard let self = self else { return }

            self.tabBar.updateSelectedTab(tab)

            switch tab {
            case .home:
                self.mapContainerView.isHidden = true
                self.profileContainerView.isHidden = true
                self.scrollView.isHidden = false
                self.qrButton.isHidden = false
                self.codeButton.isHidden = false
            case .map:
                self.mapContainerView.isHidden = false
                self.profileContainerView.isHidden = true
                self.scrollView.isHidden = true
                self.qrButton.isHidden = true
                self.codeButton.isHidden = true
            case .profile:
                self.mapContainerView.isHidden = true
                self.profileContainerView.isHidden = false
                self.scrollView.isHidden = true
                self.qrButton.isHidden = true
                self.codeButton.isHidden = true
            }
        }
    }

    private func setupMapContainer() {
        addChild(mapVC)
        mapContainerView.addSubview(mapVC.view)
        mapVC.view.frame = mapContainerView.bounds
        mapVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapVC.didMove(toParent: self)
    }

    private func setupProfileContainer() {
        addChild(profileVC)
        profileContainerView.addSubview(profileVC.view)
        profileVC.view.frame = profileContainerView.bounds
        profileVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        profileVC.didMove(toParent: self)
    }
    // MARK: - Selector
    @objc func moreOutingStatusButtonTapped() {
        let outingVC = AdminOutingViewController()
        navigationController?.pushViewController(outingVC, animated: true)
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
        navigationController?.pushViewController(adminQRVC, animated: true)

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


    // MARK: - Configure UI
    public override func configureUI() {
        qrButton.layer.cornerRadius = qrButton.frame.size.width / 2
        qrButton.clipsToBounds = false

        qrButton.layer.shadowColor = UIColor.color.admin.color.cgColor
        qrButton.layer.shadowOpacity = 0.8
        qrButton.layer.shadowRadius = 13
        qrButton.layer.shadowOffset = CGSize(width: 0.81, height: 0.81)

        codeButton.layer.cornerRadius = codeButton.frame.size.width / 2
        codeButton.clipsToBounds = false

        codeButton.layer.shadowColor = UIColor.color.admin.color.cgColor
        codeButton.layer.shadowOpacity = 0.8
        codeButton.layer.shadowRadius = 13
        codeButton.layer.shadowOffset = CGSize(width: 0.81, height: 0.81)
    }

    // MARK: - Add View
    public override func addView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        [outingStatusLabel, moreOutingStatusButton, outingCountLabel, outingStatusCollectionView].forEach { self.outingView.addSubview($0) }
        [logo, profileView, basicsProfileView, latecomerLabel, latecomerCollectionView, lateNilView, outingView, reportButton].forEach { self.contentView.addSubview($0) }
        
        view.addSubview(mapContainerView)
        view.addSubview(profileContainerView)
        view.addSubview(tabBar)
        view.addSubview(qrButton)
        view.addSubview(codeButton)
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

        codeButton.snp.remakeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(100)
            $0.size.equalTo(64)
        }

        qrButton.snp.remakeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(codeButton.snp.top).offset(-12)
            $0.size.equalTo(64)
        }

        tabBar.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(100)
        }

        logo.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalTo(contentView.snp.top)
            $0.height.equalTo(56)
            $0.width.equalTo(135)
        }


        updateLayout()

        lateNilView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(20)
            $0.top.equalTo(latecomerLabel.snp.bottom)
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

        mapContainerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(tabBar.snp.top)
        }

        profileContainerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(tabBar.snp.top)
        }
        
        reportButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(28)
            $0.top.equalTo(contentView.snp.top).offset(14)
            $0.size.equalTo(26)
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
            $0.height.equalTo(84)
            $0.top.equalTo(logo.snp.bottom).offset(20)
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

        basicsProfileView.isClockOn = isClockOn
        profileView.isClockOn = isClockOn
        view.layoutIfNeeded()
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == latecomerCollectionView {
            return viewModel.lateListDatas.isEmpty ? 3 : viewModel.lateListDatas.count
        } else if collectionView == outingStatusCollectionView {
            return viewModel.outingListDatas.isEmpty ? 5 : viewModel.outingListDatas.count
        }
        return 0
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == latecomerCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LateCell.identifier, for: indexPath) as? LateCell else { return UICollectionViewCell() }

            if viewModel.lateListDatas.isEmpty {
                cell.configureDummy()
            } else {
                let data = viewModel.lateListDatas[indexPath.row]
                cell.configure(with: data)
                if let urlString = data.profileImageURL,
                   let url = URL(string: urlString) {
                    cell.profileImageView.kf.setImage(
                        with: url,
                        placeholder: UIImage.image.profile.image
                    )
                } else {
                    cell.profileImageView.image = UIImage.image.profile.image
                }
            }

            return cell
        } else if collectionView == outingStatusCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OutingStatusCollectionViewCell.identifier, for: indexPath) as? OutingStatusCollectionViewCell else { return UICollectionViewCell() }

            if viewModel.outingListDatas.isEmpty {
                cell.configureDummy()
            } else {
                let data = viewModel.outingListDatas[indexPath.row]
                cell.configure(with: data)

                if let urlString = data.profileImageURL,
                   let url = URL(string: urlString) {
                    cell.profileImageView.kf.setImage(
                        with: url,
                        placeholder: UIImage.image.profile.image
                    )
                } else {
                    cell.profileImageView.image = UIImage.image.profile.image
                }
            }

            return cell
        }
        return UICollectionViewCell()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension AdminMainViewController {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == latecomerCollectionView {
            let width = view.bounds.width * 0.27
            let height: CGFloat = 136
            return CGSize(width: width, height: height)
        } else if collectionView == outingStatusCollectionView {
            let width = collectionView.bounds.width
            let height: CGFloat = 44
            return CGSize(width: width, height: height)
        }
        return CGSize(width: 0, height: 0)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == latecomerCollectionView {
            return view.bounds.width * 0.03
        } else if collectionView == outingStatusCollectionView {
            return 0
        }
        return 0
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        if collectionView == outingStatusCollectionView {
            return 4
        }
        return 10
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        if collectionView == outingStatusCollectionView {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
        }
        return .zero
    }
}
