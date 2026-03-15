//
//  AdminMainViewController.swift
//  Feature
//
//  Created by 김준표 on 2/25/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit

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

    private let logo = UIImageView(image: .image.gomsLightGrayLogo.image)

    private lazy var adminMenuButton = ExpandableButton().then {
        $0.setBackgroundImage(.image.adminMenu.image, for: .normal)
        $0.addTarget(self, action: #selector(adminMenuButtonTapped), for: .touchUpInside)
        $0.expandedTouchArea = 30
    }

    private let latecomerLabel = UILabel().then {
        $0.text = "지각자 TOP 3"
        $0.setDynamicTextColor(darkModeColor: .white, lightModeColor: .black)
        $0.font = UIFont.suit(size: 19, weight: .bold)
    }

    private lazy var moreLateButton = UIButton().then {
        $0.backgroundColor = .color.mainText.color.withAlphaComponent(0.1)
        $0.setTitle("더보기", for: .normal)
        $0.setTitleColor(.color.gomsSecondary.color, for: .normal)
        $0.titleLabel?.font = .suit(size: 12, weight: .regular)
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
        $0.addTarget(self, action: #selector(moreLateButtonTapped), for: .touchUpInside)
    }

    let lateNilView = LateNilView()

    lazy var latecomerCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init()).then {
        $0.isScrollEnabled = false
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = true
        $0.backgroundColor = .clear
    }

    private let outingStatusLabel = UILabel().then {
        $0.text = "외출현황"
        $0.setDynamicTextColor(darkModeColor: .white, lightModeColor: .black)
        $0.font = UIFont.suit(size: 19, weight: .bold)
    }

    private lazy var moreOutingStatusButton = UIButton().then {
        $0.backgroundColor = .color.mainText.color.withAlphaComponent(0.1)
        $0.setTitle("더보기", for: .normal)
        $0.setTitleColor(.color.gomsSecondary.color, for: .normal)
        $0.titleLabel?.font = .suit(size: 12, weight: .regular)
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
        $0.addTarget(self, action: #selector(moreOutingStatusButtonTapped), for: .touchUpInside)
    }

    let outingCountLabel = UILabel().then {
        $0.textColor = .color.sub2.color
        $0.font = UIFont.suit(size: 12, weight: .regular)
    }

    lazy var outingStatusCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init()).then {
        $0.isScrollEnabled = true
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = true
        $0.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        $0.backgroundColor = .clear
    }

    private lazy var qrButton = AdminQRButton(frame: CGRect(x: 0, y: 0, width: 64, height: 64), backgroundColor: .color.admin.color).then {
        $0.addTarget(self, action: #selector(qrButtonTapped), for: .touchUpInside)
    }

    private func setupNavigationBar() {
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.isHidden = true
    }

    private var isVisible: Bool = false

    // MARK: - Life Cycle
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isVisible = true
        fetchData()
        setupNavigationBar()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isVisible = false
        refreshControl.endRefreshing()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.latecomerCollectionView.reloadData()
        self.outingStatusCollectionView.reloadData()
        handleRefreshControl()
        configureRefreshControl()
        setupScrollView()
        refreshControl.beginRefreshing()
    }

    func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        contentView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(view.snp.height).priority(.low)
        }

        addView()
    }

    func configureRefreshControl() {
        scrollView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        refreshControl.tintColor = .color.admin.color
    }

    @objc func handleRefreshControl() {
      
        let adminVC = AdminMainViewController()
        if !(self.navigationController?.topViewController is AdminMainViewController) {
            self.navigationController?.setViewControllers([adminVC], animated: false)
        }
        self.refreshControl.endRefreshing()
        return
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
        if self.viewModel.lateListDatas.count >= 1 {
            lateNilView.isHidden = true
        } else {
            lateNilView.isHidden = false
        }

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
        let attributedString = NSMutableAttributedString(string: "\(self.viewModel.outingListDatas.count)명이 외출 중")
        let range = (attributedString.string as NSString).range(of: "\(self.viewModel.outingListDatas.count)")

        attributedString.addAttribute(.foregroundColor, value: UIColor.color.admin.color, range: range)
        attributedString.addAttribute(.font, value: UIFont.suit(size: 12, weight: .semibold), range: range)

        self.outingCountLabel.attributedText = attributedString
    }

    func setupProfileView() {
        guard let grade = viewModel.profileData?.grade else { return }

        if let imageURL = viewModel.profileData?.profileUrl, let url = URL(string: imageURL) {
            basicsProfileView.profileImageView.kf.setImage(with: url, placeholder: UIImage(systemName: "person.crop.circle.fill"))
            basicsProfileView.profileImageView.layer.cornerRadius = basicsProfileView.profileImageView.frame.width / 2
        } else {
            basicsProfileView.profileImageView.image = .image.profile.image
        }

        profileView.nameLabel.text = viewModel.profileData?.name
        basicsProfileView.nameLabel.text = viewModel.profileData?.name

        if viewModel.profileData?.major == Major.sw.rawValue {
            profileView.studentInformationLabel.text = "\(grade)기 | SW개발"
            basicsProfileView.studentInformationLabel.text = "\(grade)기 | SW개발"
        } else if viewModel.profileData?.major == Major.iot.rawValue {
            profileView.studentInformationLabel.text = "\(grade)기 | IoT"
            basicsProfileView.studentInformationLabel.text = "\(grade)기 | IoT"
        } else {
            profileView.studentInformationLabel.text = "\(grade)기 | AI"
            basicsProfileView.studentInformationLabel.text = "\(grade)기 | AI"
        }

        if let authority = viewModel.profileData?.authority {
            if authority == "ROLE_STUDENT_COUNCIL" {
                profileView.profileStatus.text = "학생회"
                basicsProfileView.myOutingStatusLabel.text = "학생회"
            }
        }
    }

    // MARK: - Selector
    @objc func moreOutingStatusButtonTapped() {
        let outingVC = AdminOutingViewController()
        navigationController?.pushViewController(outingVC, animated: true)
    }

    @objc public func qrButtonTapped() {
        qrButton.isUserInteractionEnabled = false
        let adminQRVC = AdminQRViewController()
        navigationController?.pushViewController(adminQRVC, animated: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            self.qrButton.isUserInteractionEnabled = true
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

    @objc func moreLateButtonTapped() {
        let lateVC = LatecomerListViewController()
        navigationController?.pushViewController(lateVC, animated: true)
    }

    // MARK: - Configure UI
    public override func configureUI() {
        qrButton.layer.cornerRadius = qrButton.frame.size.width / 2
        qrButton.clipsToBounds = true
    }

    // MARK: - Add View
    public  override func addView() {
        [profileView, basicsProfileView, latecomerLabel, moreLateButton, lateNilView, latecomerCollectionView, outingStatusLabel, moreOutingStatusButton, outingCountLabel, outingStatusCollectionView, qrButton].forEach { self.contentView.addSubview($0) }
        [logo, adminMenuButton, content].forEach { self.contentView.addSubview($0) }
        contentView.bringSubviewToFront(qrButton)
        contentView.bringSubviewToFront(moreOutingStatusButton)
        contentView.bringSubviewToFront(moreLateButton)
    }

    // MARK: - Layout
    public  override func setLayout() {
        logo.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalToSuperview().inset(20)
            $0.height.equalTo(24)
            $0.width.equalTo(87)
        }

        adminMenuButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(18)
            $0.width.equalTo(20)
        }

        content.snp.makeConstraints {
            $0.top.equalTo(logo.snp.bottom).offset(40)
            $0.leading.equalTo(bounds.width * 0.05)
            $0.trailing.equalTo(-(bounds.width * 0.05))
            $0.bottom.equalToSuperview()
        }

        updateLayout()

        lateNilView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(40)
            $0.top.equalTo(latecomerLabel.snp.bottom).offset(8)
        }

        latecomerCollectionView.snp.makeConstraints {
            $0.top.equalTo(latecomerLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(136)
        }

        outingStatusLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.height.equalTo(32)
            $0.top.equalTo(latecomerCollectionView.snp.bottom).offset(24)
        }

        outingCountLabel.snp.makeConstraints {
            $0.top.equalTo(latecomerCollectionView.snp.bottom).offset(24)
            $0.leading.equalTo(outingStatusLabel.snp.trailing).offset(8)
            $0.height.equalTo(32)
        }

        moreOutingStatusButton.snp.makeConstraints {
            $0.top.equalTo(latecomerCollectionView.snp.bottom).offset(28)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.equalTo(48)
            $0.height.equalTo(24)
        }

        outingStatusCollectionView.snp.makeConstraints {
            $0.top.equalTo(outingStatusLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }

        qrButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(130)
            $0.height.width.equalTo(64)
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

        moreLateButton.snp.makeConstraints {
            $0.top.equalTo(profileView.snp.bottom).offset(24)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.equalTo(48)
            $0.height.equalTo(24)
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

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == latecomerCollectionView {
            return viewModel.lateListDatas.count
        } else if collectionView == outingStatusCollectionView {
            return viewModel.outingListDatas.count
        }
        return 0
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == latecomerCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LateCell.identifier, for: indexPath) as? LateCell else { return UICollectionViewCell() }
            let data = viewModel.lateListDatas[indexPath.row]
            cell.configure(with: data)
            return cell
        } else if collectionView == outingStatusCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OutingStatusCollectionViewCell.identifier, for: indexPath) as? OutingStatusCollectionViewCell else { return UICollectionViewCell() }
            let data = viewModel.outingListDatas[indexPath.row]
            cell.configure(with: data)
            return cell
        }
        return UICollectionViewCell()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension AdminMainViewController {
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
