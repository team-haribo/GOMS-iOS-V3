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

    private var viewModel: StudentManagementViewModel
    var studentManagementVC: StudentManagementViewController
    
    var userData: UserData? {
        didSet { if isViewLoaded { setupData() } }
    }
    
    private let dimmedView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.4)
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
        $0.font = .suit(size: 22, weight: .bold)
    }

    private lazy var closeButton = UIButton().then {
        $0.setImage(UIImage.image.cancelButton.image, for: .normal)
        $0.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }

    private let contentStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 4
        $0.distribution = .fill
    }

    private let outingTitleLabel = UILabel().then {
        $0.text = "외출"
        $0.textColor = UIColor.color.mainText.color
        $0.font = .suit(size: 18, weight: .semibold)
    }
    private let outingDescLabel = UILabel().then {
        $0.text = "학생을 외출/복귀 시켜요"
        $0.textColor = UIColor.color.sub2.color
        $0.font = .suit(size: 14, weight: .regular)
    }
    
    private let outingSwitch = GOMSSwitch().then {
        $0.onTintColor = UIColor.color.admin.color
    }
    private let forceOutingContainer = UIView()
    private let blackListContainer = UIView()
    private let adminContainer = UIView()
    private let blackListSwitch = GOMSSwitch().then {
        $0.onTintColor = UIColor.color.admin.color
    }
    private let adminSwitch = GOMSSwitch().then {
        $0.onTintColor = UIColor.color.admin.color
    }

    init(studentManagementVC: StudentManagementViewController, viewModel: StudentManagementViewModel) {
        self.studentManagementVC = studentManagementVC
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) { fatalError() }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupActions()
        setupData()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeButtonTapped))
        dimmedView.addGestureRecognizer(tapGesture)
    }

    private func setupData() {
        guard let data = userData else { return }

        outingSwitch.isOn = data.isOuting
        blackListSwitch.isOn = data.isBlackList
        adminSwitch.isOn = (data.authority == "ROLE_STUDENT_COUNCIL")

        forceOutingContainer.isHidden = data.authority == "ROLE_STUDENT_COUNCIL" || data.isBlackList
        blackListContainer.isHidden = data.authority == "ROLE_STUDENT_COUNCIL"
        
        updateLayoutForState()
    }

    private func updateLayoutForState() {
        let visibleViewsCount = [forceOutingContainer, blackListContainer, adminContainer].filter { !$0.isHidden }.count
        
        let sheetHeight: CGFloat
        if visibleViewsCount == 3 {
            sheetHeight = 342
        } else if visibleViewsCount == 2 {
            sheetHeight = 266
        } else {
            sheetHeight = 190
        }

        bottomSheetView.snp.remakeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(sheetHeight)
        }
        
        self.view.layoutIfNeeded()
    }

    @objc private func outingSwitchChanged() {
        guard let data = userData else { return }
        let previousState = !outingSwitch.isOn
        let isOn = outingSwitch.isOn
        
        GOMSAlert.show(
            in: self,
            title: isOn ? "강제외출" : "강제외출 복귀",
            message: isOn ? "이 학생을 외출 상태로 변경하시겠습니까?" : "학생을 복귀 상태로 변경하시겠습니까?",
            actionTitle: isOn ? "외출" : "복귀",
            isNegative: true,
            highlightKeywords: [],
            action: { [weak self] in
                if isOn {
                    self?.viewModel.forceOutingStudent(user: data) { [weak self] in
                        guard let self = self else { return }
                        self.studentManagementVC.userList = self.viewModel.userListDatas
                    }
                } else {
                    self?.viewModel.deleteOutingStudent(user: data) { [weak self] in
                        guard let self = self else { return }
                        self.studentManagementVC.userList = self.viewModel.userListDatas
                    }
                }
            },
            cancelAction: { [weak self] in
                self?.outingSwitch.isOn = previousState
            }
        )
    }
    
    @objc private func blackListSwitchChanged() {
        guard let data = userData else { return }
        let previousState = !blackListSwitch.isOn
        let isOn = blackListSwitch.isOn
        
        GOMSAlert.show(
            in: self,
            title: "외출금지",
            message: isOn ? "이 학생을 외출 금지 시키겠습니까?" : "이 학생을 외출 금지 해제 시키겠습니까?",
            actionTitle: isOn ? "외출 금지" : "외출 해제",
            isNegative: true,
            highlightKeywords: isOn ? ["외출 금지"] : ["해제"],
            action: { [weak self] in
                if isOn {
                    self?.viewModel.blackList(user: data) { [weak self] in
                        guard let self = self else { return }
                        self.studentManagementVC.userList = self.viewModel.userListDatas
                    }
                } else {
                    self?.viewModel.cancelBlackList(user: data) { [weak self] in
                        guard let self = self else { return }
                        self.studentManagementVC.userList = self.viewModel.userListDatas
                    }
                }
            },
            cancelAction: { [weak self] in
                self?.blackListSwitch.isOn = previousState
            }
        )
    }

    @objc private func adminSwitchChanged() {
        guard let data = userData else { return }

        viewModel.changeAuthority(user: data) { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.studentManagementVC.userList = self.viewModel.userListDatas
                self.dismiss(animated: false)
            }
        }
    }

    private func setupActions() {
        outingSwitch.addTarget(self, action: #selector(outingSwitchChanged), for: .valueChanged)
        blackListSwitch.addTarget(self, action: #selector(blackListSwitchChanged), for: .valueChanged)
        adminSwitch.addTarget(self, action: #selector(adminSwitchChanged), for: .valueChanged)
    }

    @objc private func closeButtonTapped() { dismiss(animated: false) }

    public override func addView() {
        [dimmedView, bottomSheetView].forEach { view.addSubview($0) }
        [titleLabel, closeButton, contentStackView].forEach {
            bottomSheetView.addSubview($0)
        }
        
        [forceOutingContainer, blackListContainer, adminContainer].forEach {
            contentStackView.addArrangedSubview($0)
        }
        
        let outingStack = UIStackView(arrangedSubviews: [outingTitleLabel, outingDescLabel]).then {
            $0.axis = .vertical
            $0.spacing = 6
        }
        forceOutingContainer.addSubview(outingStack)
        forceOutingContainer.addSubview(outingSwitch)
        
        outingStack.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
        }
        outingSwitch.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
        }
        
        let bStack = createOptionStack(title: "외출금지", description: "이 학생은 외출을 할 수 없어요")
        blackListContainer.addSubview(bStack)
        blackListContainer.addSubview(blackListSwitch)
        bStack.snp.makeConstraints { $0.leading.centerY.equalToSuperview() }
        blackListSwitch.snp.makeConstraints { $0.trailing.centerY.equalToSuperview() }
        
        let aStack = createOptionStack(title: "학생회 권한 부여", description: "이 학생은 학생회 권한을 가지게 돼요")
        adminContainer.addSubview(adminSwitch)
        adminContainer.addSubview(aStack)
        aStack.snp.makeConstraints { $0.leading.centerY.equalToSuperview() }
        adminSwitch.snp.makeConstraints { $0.trailing.centerY.equalToSuperview() }
    }

    private func createOptionStack(title: String, description: String) -> UIStackView {
        let t = UILabel().then {
            $0.text = title
            $0.textColor = UIColor.color.mainText.color
            $0.font = .suit(size: 18, weight: .semibold)
        }
        let d = UILabel().then {
            $0.text = description
            $0.textColor = UIColor.color.sub2.color
            $0.font = .suit(size: 14, weight: .regular)
        }
        return UIStackView(arrangedSubviews: [t, d]).then {
            $0.axis = .vertical
            $0.spacing = 6
        }
    }

    public override func setLayout() {
        dimmedView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        bottomSheetView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(342)
        }
        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(24)
        }
        closeButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(24)
            $0.size.equalTo(28)
        }
        contentStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        [forceOutingContainer, blackListContainer, adminContainer].forEach {
            $0.snp.makeConstraints { $0.height.equalTo(72) }
        }
    }
}
