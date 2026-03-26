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

class CustomSwitch: UIControl {
    private let toggleThumb = UIView().then {
        $0.backgroundColor = UIColor.color.gomsLine.color
        $0.layer.cornerRadius = 14
        $0.isUserInteractionEnabled = false
    }
    
    var isOn: Bool = false {
        didSet { setupState() }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        self.snp.makeConstraints {
            $0.width.equalTo(52)
            $0.height.equalTo(32)
        }
        self.layer.cornerRadius = 16
        self.backgroundColor = UIColor.color.gomsSwitchBg.color
        
        addSubview(toggleThumb)
        toggleThumb.snp.makeConstraints {
            $0.size.equalTo(28)
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(2)
        }
        self.addTarget(self, action: #selector(toggle), for: .touchUpInside)
    }
    
    @objc private func toggle() {
        isOn.toggle()
        sendActions(for: .valueChanged)
    }
    
    private func setupState() {
        let color = isOn ? UIColor.color.admin.color : UIColor.color.gomsSwitchBg.color
        let xPosition = isOn ? 20 : 0
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
            self.backgroundColor = color
            self.toggleThumb.transform = CGAffineTransform(translationX: CGFloat(xPosition), y: 0)
        }
    }
}

public final class AuthorityBottomSheetVC: BaseViewController {

    private let viewModel = StudentManagementViewModel()
    var studentManagementVC: StudentManagementViewController
    
    var userData: UserData? {
        didSet { if isViewLoaded { setupData() } }
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

    private let outingTitleLabel = UILabel().then {
        $0.textColor = UIColor.color.mainText.color
        $0.font = .suit(size: 18, weight: .semibold)
    }
    private let outingDescLabel = UILabel().then {
        $0.textColor = UIColor.color.sub2.color
        $0.font = .suit(size: 14, weight: .regular)
    }
    private lazy var outingButton = UIButton().then {
        $0.contentVerticalAlignment = .fill
        $0.contentHorizontalAlignment = .fill
        $0.addTarget(self, action: #selector(outingButtonTapped), for: .touchUpInside)
    }

    private let forceOutingContainer = UIView()
    private let blackListContainer = UIView()
    private let adminContainer = UIView()
    private let blackListSwitch = CustomSwitch()
    private let adminSwitch = CustomSwitch()

    init(studentManagementVC: StudentManagementViewController) {
        self.studentManagementVC = studentManagementVC
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
    }

    required init?(coder: NSCoder) { fatalError() }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupActions()
        setupData()
    }

    private func setupData() {
        guard let data = userData else { return }
        
        if data.isOuting {
            outingTitleLabel.text = "강제외출 복귀"
            outingDescLabel.text = "학생을 강제외출 복귀 시켜요"
        } else {
            outingTitleLabel.text = "강제외출"
            outingDescLabel.text = "학생을 강제외출 시켜요"
        }
        outingButton.setImage(UIImage.image.outing.image, for: .normal)

        blackListSwitch.isOn = data.isBlackList
        adminSwitch.isOn = (data.authority == "ROLE_ADMIN")

        forceOutingContainer.isHidden = data.authority == "ROLE_ADMIN" || data.isBlackList
        blackListContainer.isHidden = data.authority == "ROLE_ADMIN"
        
        updateLayoutForState()
    }

    @objc private func outingButtonTapped() {
        guard let data = userData else { return }
        let isOut = data.isOuting
        
        GOMSAlert.show(
            in: self,
            title: isOut ? "강제외출 복귀" : "강제외출",
            message: isOut ? "학생을 복귀 상태로 변경하시겠습니까?" : "이 학생을 외출 상태로 변경하시겠습니까?",
            actionTitle: isOut ? "복귀" : "외출",
            isNegative: !isOut,
            action: { [weak self] in
                self?.viewModel.forceOutingStudent(user: data) {
                    self?.studentManagementVC.userList = $0
                    self?.dismiss(animated: true)
                }
            }
        )
    }

    @objc private func blackListSwitchChanged() {
        guard let data = userData else { return }
        let isOn = blackListSwitch.isOn
        
        GOMSAlert.show(
            in: self,
            title: "외출금지",
            message: isOn ? "이 학생을 외출 금지 시겠습니까?" : "이 학생을 외출 금지 해제 시키겠습니까?",
            actionTitle: isOn ? "외출 금지" : "외출 해제",
            isNegative: true,
            action: { [weak self] in
                if isOn {
                    self?.viewModel.blackList(user: data) { self?.studentManagementVC.userList = $0 }
                } else {
                    self?.viewModel.cancelBlackList(user: data) { self?.studentManagementVC.userList = $0 }
                }
            },
            cancelAction: { [weak self] in
                self?.blackListSwitch.isOn = data.isBlackList
            }
        )
    }

    @objc private func adminSwitchChanged() {
        guard let data = userData else { return }
        let currentIsAdmin = (data.authority == "ROLE_ADMIN")
        
        GOMSAlert.show(
            in: self,
            title: "권한 부여",
            message: "학생에게 권한을 부여하시겠습니까?",
            actionTitle: "확인",
            action: { [weak self] in
                self?.viewModel.changeAuthority(user: data) { self?.studentManagementVC.userList = $0 }
            },
            cancelAction: { [weak self] in
                self?.adminSwitch.isOn = currentIsAdmin
            }
        )
    }

    private func updateLayoutForState() {
        let visibleViews = [forceOutingContainer, blackListContainer, adminContainer].filter { !$0.isHidden }
        
        forceOutingContainer.snp.updateConstraints {
            $0.height.equalTo(forceOutingContainer.isHidden ? 0 : 72)
        }
        
        blackListContainer.snp.updateConstraints {
            $0.height.equalTo(blackListContainer.isHidden ? 0 : 72)
            $0.top.equalTo(titleLabel.snp.bottom).offset(forceOutingContainer.isHidden ? 28 : 104)
        }
        
        let adminOffset: CGFloat = forceOutingContainer.isHidden && blackListContainer.isHidden ? 28 : (forceOutingContainer.isHidden || blackListContainer.isHidden ? 104 : 180)
        adminContainer.snp.updateConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(adminOffset)
        }
        
        let dynamicHeight = 110 + (visibleViews.count * 76)
        bottomSheetView.snp.updateConstraints {
            $0.height.equalTo(dynamicHeight)
        }
        
        view.layoutIfNeeded()
    }

    private func setupActions() {
        blackListSwitch.addTarget(self, action: #selector(blackListSwitchChanged), for: .valueChanged)
        adminSwitch.addTarget(self, action: #selector(adminSwitchChanged), for: .valueChanged)
    }

    @objc private func closeButtonTapped() { dismiss(animated: true) }

    public override func addView() {
        view.addSubview(bottomSheetView)
        [titleLabel, closeButton, forceOutingContainer, blackListContainer, adminContainer].forEach {
            bottomSheetView.addSubview($0)
        }
        
        let outingStack = UIStackView(arrangedSubviews: [outingTitleLabel, outingDescLabel]).then {
            $0.axis = .vertical
            $0.spacing = 6
        }
        forceOutingContainer.addSubview(outingStack)
        forceOutingContainer.addSubview(outingButton)
        
        outingStack.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
        }
        outingButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview().offset(-4)
            $0.size.equalTo(32)
        }
        
        let bStack = createOptionStack(title: "외출금지", description: "이 학생은 외출을 할 수 없어요")
        blackListContainer.addSubview(bStack)
        blackListContainer.addSubview(blackListSwitch)
        bStack.snp.makeConstraints { $0.leading.centerY.equalToSuperview() }
        blackListSwitch.snp.makeConstraints { $0.trailing.centerY.equalToSuperview() }
        
        let aStack = createOptionStack(title: "학생회 권한 부여", description: "이 학생은 학생회 권한을 가지게 돼요")
        adminContainer.addSubview(aStack)
        adminContainer.addSubview(adminSwitch)
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
        bottomSheetView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(390)
        }
        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(24)
        }
        closeButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(24)
            $0.size.equalTo(28)
        }
        forceOutingContainer.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(28)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(72)
        }
        blackListContainer.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(104)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(72)
        }
        adminContainer.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(180)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(72)
        }
    }
}
