//
//  AuthorityBottomSheetVC.swift
//  Feature
//
//  Created by 김민선 on 3/23/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit
import Then

public final class AuthorityBottomSheetVC: BaseViewController {

    // MARK: - Properties
    private let viewModel = StudentManagementViewModel()
    var userData: UserData?
    var userDataIndex: Int?
    var studentManagementVC: StudentManagementViewController

    // MARK: - UI Components
    private let dimmedView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    }

    private let bottomSheetView = UIView().then {
        $0.backgroundColor = UIColor.color.surface.color 
        $0.layer.cornerRadius = 20
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.clipsToBounds = true
    }

    private let titleLabel = UILabel().then {
        $0.text = "유저 권한 변경"
        $0.textColor = UIColor.color.mainText.color
        $0.font = .suit(size: 20, weight: .bold)
    }

    private lazy var closeButton = UIButton().then {
        $0.setImage(UIImage.image.cancelButton.image, for: .normal)
        $0.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }

    private func createOptionStack(title: String, description: String) -> UIStackView {
        let titleLabel = UILabel().then {
            $0.text = title
            $0.textColor = UIColor.color.mainText.color
            $0.font = .suit(size: 16, weight: .semibold)
        }
        let descLabel = UILabel().then {
            $0.text = description
            $0.textColor = UIColor.color.sub2.color
            $0.font = .suit(size: 12, weight: .regular)
        }
        let stack = UIStackView(arrangedSubviews: [titleLabel, descLabel]).then {
            $0.axis = .vertical
            $0.spacing = 4
        }
        return stack
    }

    private lazy var forceOutingStack = createOptionStack(title: "강제외출", description: "이 학생은 현재 외출중이에요")
    private lazy var blackListStack = createOptionStack(title: "외출금지", description: "이 학생은 외출을 할 수 없어요")
    private lazy var adminStack = createOptionStack(title: "학생회 권한 부여", description: "이 학생은 학생회에요")

    private lazy var forceOutingButton = UIButton().then {
        $0.setImage(UIImage.image.outing.image, for: .normal)
        $0.addTarget(self, action: #selector(forceOutingTapped), for: .touchUpInside)
    }

    private lazy var blackListSwitch = UISwitch().then {
        $0.onTintColor = UIColor.color.mainText.color
        $0.addTarget(self, action: #selector(blackListSwitchValueChanged), for: .valueChanged)
    }

    private lazy var adminSwitch = UISwitch().then {
        $0.onTintColor = UIColor.color.admin.color
        $0.addTarget(self, action: #selector(adminSwitchValueChanged), for: .valueChanged)
    }

    // MARK: - Init
    init(studentManagementVC: StudentManagementViewController) {
        self.studentManagementVC = studentManagementVC
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Life Cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupData()
    }

    private func setupData() {
        guard let data = userData else { return }
        blackListSwitch.isOn = data.isBlackList
        adminSwitch.isOn = (data.authority == "ROLE_ADMIN")
        
        // 외출 중인 학생은 강제외출 버튼 숨기기 처리 등 시안 로직 적용 가능
        forceOutingButton.isHidden = data.isOuting
    }

    // MARK: - Actions
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }

    @objc private func forceOutingTapped() {
        guard let data = userData else { return }
        viewModel.forceOutingStudent(user: data) { newList in
            self.studentManagementVC.userList = newList
            self.dismiss(animated: true)
        }
    }

    @objc private func blackListSwitchValueChanged(_ sender: UISwitch) {
        guard let data = userData else { return }
        if sender.isOn {
            viewModel.blackList(user: data) { self.studentManagementVC.userList = $0 }
        } else {
            viewModel.cancelBlackList(user: data) { self.studentManagementVC.userList = $0 }
        }
    }

    @objc private func adminSwitchValueChanged(_ sender: UISwitch) {
        guard let data = userData else { return }
        viewModel.changeAuthority(user: data) { self.studentManagementVC.userList = $0 }
    }

    // MARK: - UI Layout
    public override func addView() {
        view.addSubview(dimmedView)
        dimmedView.addSubview(bottomSheetView)
        [titleLabel, closeButton, forceOutingStack, forceOutingButton, blackListStack, blackListSwitch, adminStack, adminSwitch].forEach {
            bottomSheetView.addSubview($0)
        }
    }

    public override func setLayout() {
        dimmedView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        bottomSheetView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(380) // 시안에 맞춰 고정 높이 혹은 비율 조절
        }

        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(24)
        }

        closeButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(24)
            $0.size.equalTo(24)
        }

        // 강제외출 섹션
        forceOutingStack.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(32)
            $0.leading.equalToSuperview().inset(24)
        }
        forceOutingButton.snp.makeConstraints {
            $0.centerY.equalTo(forceOutingStack)
            $0.trailing.equalToSuperview().inset(24)
        }

        // 외출금지 섹션
        blackListStack.snp.makeConstraints {
            $0.top.equalTo(forceOutingStack.snp.bottom).offset(24)
            $0.leading.equalToSuperview().inset(24)
        }
        blackListSwitch.snp.makeConstraints {
            $0.centerY.equalTo(blackListStack)
            $0.trailing.equalToSuperview().inset(24)
        }

        // 권한 섹션
        adminStack.snp.makeConstraints {
            $0.top.equalTo(blackListStack.snp.bottom).offset(24)
            $0.leading.equalToSuperview().inset(24)
        }
        adminSwitch.snp.makeConstraints {
            $0.centerY.equalTo(adminStack)
            $0.trailing.equalToSuperview().inset(24)
        }
    }
}
