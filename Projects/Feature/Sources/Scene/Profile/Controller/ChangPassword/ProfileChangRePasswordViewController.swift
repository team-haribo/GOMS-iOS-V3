//
//  ProfileChangRePasswordViewController.swift
//  Feature
//
//  Created by 김준표 on 2/25/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit
import Then
import Service

public final class ProfileChangRePasswordViewController: BaseViewController {
    
    private let viewModel = AuthViewModel()
    private var email: String?

    private var limitTime = 300
    private var resendCooldown = 60
    private var resendTimer: Timer?
    private var isRequestingAuthCode = false

    // MARK: - UI Components
    
    private lazy var customBackButton = UIButton().then {
        let backImage = UIImage(named: "Back", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        $0.setImage(backImage, for: .normal)
        $0.setTitle(" 돌아가기", for: .normal)
        $0.setTitleColor(.color.gomsPrimary.color, for: .normal)
        $0.tintColor = .color.gomsPrimary.color
        $0.titleLabel?.font = .suit(size: 18, weight: .medium)
        $0.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }

    private let pageTitleLabel = UILabel().then {
        $0.text = "인증번호"
        $0.font = .suit(size: 28, weight: .bold)
        $0.textColor = .color.mainText.color
    }

    private let authCodeTextField = GOMSTextField().then {
        $0.keyboardType = .numberPad
        $0.placeholder = "인증번호 입력"
    }

    private let timeLabel = UILabel().then {
        $0.font = .suit(size: 15, weight: .medium)
        $0.textColor = .color.sub2.color
    }

    private lazy var resendButton = UIButton().then {
        $0.setTitle("재발송", for: .normal)
        $0.backgroundColor = .clear
        $0.titleLabel?.font = UIFont.suit(size: 15, weight: .medium)
        $0.setTitleColor(.color.gomsPrimary.color, for: .normal)
        $0.addTarget(self, action: #selector(resendButtonTapped), for: .touchUpInside)
    }

    private let authErrorLabel = UILabel().then {
        $0.text = "잘못된 인증번호입니다"
        $0.textColor = .color.gomsNegative.color
        $0.font = .suit(size: 15, weight: .medium)
        $0.textAlignment = .right
        $0.isHidden = true
    }

    private lazy var doneButton = GOMSButton(frame: .zero, title: "인증").then {
        $0.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
    }

    // MARK: - Life Cycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        email = UserDefaults.standard.string(forKey: "localEmail")
        viewModel.setupEmailStatus(status: "PASSWORD_CHANGE")
        authCodeTextField.delegate = self
        authCodeTextField.addTarget(self, action: #selector(authCodeEditingChanged(_:)), for: .editingChanged)
        getSetTime()
        startResendCooldown()
        requestInitialAuthCode()
    }

    public override func shouldShowCustomNavigation() -> Bool {
        return false
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    public override func configNavigation() {
        super.configNavigation()
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = nil
        navigationItem.titleView = nil
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    public override func addView() {
        [customBackButton, pageTitleLabel, authCodeTextField, timeLabel, resendButton, authErrorLabel, doneButton]
            .forEach { view.addSubview($0) }
        
        view.bringSubviewToFront(customBackButton)
        view.bringSubviewToFront(doneButton)
    }

    public override func setLayout() {
        customBackButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.equalToSuperview().offset(20)
        }

        pageTitleLabel.snp.makeConstraints {
            $0.top.equalTo(customBackButton.snp.bottom).offset(20)
            $0.leading.equalTo(20)
        }

        authCodeTextField.snp.makeConstraints {
            $0.height.equalTo(56)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(pageTitleLabel.snp.bottom).offset(24)
        }

        authErrorLabel.snp.makeConstraints {
            $0.trailing.equalTo(authCodeTextField.snp.trailing)
            $0.top.equalTo(authCodeTextField.snp.bottom).offset(8)
            $0.height.equalTo(0)
        }

        timeLabel.snp.makeConstraints {
            $0.leading.equalTo(24)
            $0.top.equalTo(authCodeTextField.snp.bottom).offset(12)
        }

        resendButton.snp.makeConstraints {
            $0.top.equalTo(authCodeTextField.snp.bottom).offset(12)
            $0.trailing.equalTo(-24)
        }

        doneButton.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
        }
    }

    // MARK: - Actions
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    private func requestInitialAuthCode() {
        guard let email else { return }
        viewModel.setupEmail(email: email)
        viewModel.setupEmailStatus(status: "PASSWORD_CHANGE")
        viewModel.sendAuthCode { [weak self] success, _ in
            guard let self else { return }
            DispatchQueue.main.async {
                if !success {
                    // 요청 실패 처리
                }
            }
        }
    }

    @objc private func getSetTime() {
        secToTime(sec: limitTime)
        if limitTime > 0 { limitTime -= 1 }
    }

    @objc private func authCodeEditingChanged(_ textField: UITextField) {
        let text = textField.text ?? ""
        if text.isEmpty {
            authCodeTextField.layer.borderWidth = 0
            authCodeSuccess()
        } else {
            authCodeSuccess()
        }
        viewModel.setupAuthCode(authCode: text)
    }

    @objc private func resendButtonTapped() {
        if isRequestingAuthCode { return }
        isRequestingAuthCode = true
        resendButton.isEnabled = false

        guard let email else {
            isRequestingAuthCode = false
            resendButton.isEnabled = true
            return
        }

        viewModel.setupEmail(email: email)
        viewModel.setupEmailStatus(status: "PASSWORD_CHANGE")
        viewModel.sendAuthCode { [weak self] success, statusCode in
            guard let self else { return }
            DispatchQueue.main.async {
                if statusCode == 429 {
                    self.startResendCooldown()
                    self.isRequestingAuthCode = false
                    self.showAlert(title: "재발송 완료", message: "잠시 후 인증번호가 도착할 수 있습니다.")
                } else if success {
                    self.startResendCooldown()
                    self.limitTime = 300
                    self.isRequestingAuthCode = false
                    self.getSetTime()
                    self.showAlert(title: "재발송 완료", message: "인증번호를 다시 보냈습니다.")
                } else {
                    self.isRequestingAuthCode = false
                    self.resendButton.isEnabled = true
                    self.showAlert(title: "오류", message: "재발송에 실패했습니다.")
                }
            }
        }
    }

    @objc private func doneButtonTapped() {
        let code = authCodeTextField.text ?? ""
        viewModel.setupAuthCode(authCode: code)
        viewModel.setupEmailStatus(status: "PASSWORD_CHANGE")

        if code.isEmpty {
            authCodeTextField.layer.borderWidth = 1
            authCodeTextField.layer.borderColor = UIColor.systemRed.cgColor
            authCodeError()
            return
        }

        viewModel.verifyAuthCode { [weak self] success in
            guard let self else { return }
            DispatchQueue.main.async {
                if success {
                    self.authCodeTextField.layer.borderWidth = 0
                    self.authCodeSuccess()

                    GOMSAlert.show(
                        in: self,
                        title: "인증번호 확인",
                        message: "인증이 완료되었습니다.",
                        actionTitle: "확인",
                        cancelTitle: "",
                        action: { [weak self] in
                            guard let self else { return }
                            let newPasswordVC = ChangNewPasswordViewController()
                            newPasswordVC.email = self.email ?? ""
                            newPasswordVC.verifiedToken = UserDefaults.standard.string(forKey: "verifiedToken") ?? ""
                            
                            if let nav = self.navigationController {
                                nav.pushViewController(newPasswordVC, animated: true)
                            }
                        }
                    )
                } else {
                    self.authCodeTextField.layer.borderWidth = 1
                    self.authCodeTextField.layer.borderColor = UIColor.systemRed.cgColor
                    self.authCodeError()
                }
            }
        }
    }

    private func showAlert(title: String, message: String) {
        GOMSAlert.show(in: self, title: title, message: message, actionTitle: "확인", cancelTitle: "")
    }

    private func startResendCooldown() {
        resendButton.isEnabled = false
        resendCooldown = 60
        resendButton.setTitleColor(.color.sub2.color, for: .normal)
        resendTimer?.invalidate()
        resendTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self else { return }
            self.resendCooldown -= 1
            if self.resendCooldown <= 0 {
                timer.invalidate()
                self.resendButton.isEnabled = true
                self.resendButton.setTitleColor(.color.gomsPrimary.color, for: .normal)
            }
        }
    }

    private func secToTime(sec: Int) {
        let minute = (sec % 3600) / 60
        let second = (sec % 3600) % 60
        timeLabel.text = second < 10 ? "\(minute):0\(second)" : "\(minute):\(second)"
        if limitTime > 0 {
            perform(#selector(getSetTime), with: nil, afterDelay: 1.0)
        } else {
            timeLabel.text = "00:00"
        }
    }

    private func authCodeError() {
        authErrorLabel.isHidden = false
        authErrorLabel.snp.updateConstraints { $0.height.equalTo(19) }
        timeLabel.snp.remakeConstraints {
            $0.leading.equalTo(24)
            $0.top.equalTo(authErrorLabel.snp.bottom).offset(12)
        }
        resendButton.snp.remakeConstraints {
            $0.top.equalTo(authErrorLabel.snp.bottom).offset(12)
            $0.trailing.equalTo(-24)
        }
        view.layoutIfNeeded()
    }

    private func authCodeSuccess() {
        authCodeTextField.layer.borderWidth = 0
        authErrorLabel.isHidden = true
        authErrorLabel.snp.updateConstraints { $0.height.equalTo(0) }
        timeLabel.snp.remakeConstraints {
            $0.leading.equalTo(24)
            $0.top.equalTo(authCodeTextField.snp.bottom).offset(12)
        }
        resendButton.snp.remakeConstraints {
            $0.top.equalTo(authCodeTextField.snp.bottom).offset(12)
            $0.trailing.equalTo(-24)
        }
        view.layoutIfNeeded()
    }

    @objc public override func keyboardWillShow(_ sender: Notification) {
        guard let userInfo = sender.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        let keyboardHeight = keyboardFrame.height - view.safeAreaInsets.bottom
        doneButton.snp.updateConstraints { $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-(keyboardHeight + 24)) }
        UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
    }

    @objc public override func keyboardWillHide(_ sender: Notification) {
        guard let userInfo = sender.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        doneButton.snp.updateConstraints { $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24) }
        UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
    }
}

extension ProfileChangRePasswordViewController: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == authCodeTextField {
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            return updatedText.count <= 6
        }
        return true
    }
}
