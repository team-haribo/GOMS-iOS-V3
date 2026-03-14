//
//  AuthCodeViewController.swift
//  Feature
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit

public final class AuthCodeViewController: BaseViewController {

    private var viewModel: AuthViewModel
    private var previousViewController: UIViewController?
    var email: String?

    private var limitTime = 300

    private let pageTitleLabel = UILabel().then {
        $0.text = "인증 번호"
        $0.font = .suit(size: 28, weight: .bold)
        $0.textColor = .color.mainText.color
    }

    private let authCodeTextField = GOMSTextField().then {
        $0.keyboardType = .numberPad
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

    private let authError = UILabel().then {
        $0.text = "잘못된 인증번호입니다"
        $0.textColor = .color.gomsNegative.color
        $0.font = .suit(size: 15, weight: .medium)
        $0.textAlignment = .right
        $0.isHidden = true
    }

    private lazy var authButton = GOMSButton(frame: .zero, title: "인증").then {
        $0.addTarget(self, action: #selector(authButtonTapped), for: .touchUpInside)
    }

    init(viewModel: AuthViewModel, previousViewController: UIViewController?, email: String) {
        self.viewModel = viewModel
        self.previousViewController = previousViewController
        self.email = email
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        authCodeTextField.delegate = self
        authCodeTextField.addTarget(self, action: #selector(authCodeEditingChanged(_:)), for: .editingChanged)
        getSetTime()
    }

    @objc private func getSetTime() {
        secToTime(sec: limitTime)
        limitTime -= 1
    }

    @objc private func authCodeEditingChanged(_ textField: UITextField) {
        let text = textField.text ?? ""

        if text.isEmpty {
            
            authCodeTextField.layer.borderWidth = 0
            authCodeTextField.attributedPlaceholder = NSAttributedString(
                string: "인증번호를 입력해주세요",
                attributes: [
                    .foregroundColor: UIColor.color.sub2.color
                ]
            )
            authCodeSuccess()
        } else {
            authCodeSuccess()
        }

        viewModel.setupAuthCode(authCode: text)
    }

    @objc private func resendButtonTapped() {
        let alert = UIAlertController(
            title: "재발송 완료",
            message:  "인증번호를 다시 보냈습니다.\n이메일을 확인해주세요.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .cancel))
        self.present(alert, animated: true)
    }

    @objc private func authButtonTapped() {
        let code = authCodeTextField.text ?? ""
        viewModel.setupAuthCode(authCode: code)

        if code.isEmpty {
            authCodeTextField.layer.borderWidth = 1
            authCodeTextField.layer.borderColor = UIColor.systemRed.cgColor
            authCodeTextField.attributedPlaceholder = NSAttributedString(
                string: "인증번호를 입력해주세요",
                attributes: [
                    .foregroundColor: UIColor.color.gomsNegative.color
                ]
            )
            authCodeError()
            return
        }

     
        if code == "1234" {
            authCodeTextField.layer.borderWidth = 0
            self.authCodeSuccess()

            if self.previousViewController is FindPasswordViewController {
                let newPasswordVC = NewPasswordViewController(
                    viewModel: self.viewModel,
                    email: self.email ?? ""
                )
                self.navigationController?.pushViewController(newPasswordVC, animated: true)

            } else if self.previousViewController is SignUpViewController {
                let passwordSettingVC = PasswordSettingViewController(viewModel: self.viewModel)
                self.navigationController?.pushViewController(passwordSettingVC, animated: true)
            }

        } else {
            authCodeTextField.layer.borderWidth = 1
            authCodeTextField.layer.borderColor = UIColor.systemRed.cgColor
            authCodeError()
        }
    }

    public override func keyboardWillShow(_ sender: Notification) {
        guard
            let userInfo = sender.userInfo,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }

        let keyboardHeight = keyboardFrame.height - view.safeAreaInsets.bottom

        authButton.snp.updateConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-(keyboardHeight + 24))
        }

        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }

    public override func keyboardWillHide(_ sender: Notification) {
        guard
            let userInfo = sender.userInfo,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }

        authButton.snp.updateConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
        }

        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }

    private func secToTime(sec: Int) {
        let minute = (sec % 3600) / 60
        let second = (sec % 3600) % 60

        timeLabel.text = second < 10
        ? "\(minute):0\(second)"
        : "\(minute):\(second)"

        if limitTime != 0 {
            perform(#selector(getSetTime), with: nil, afterDelay: 1.0)
        } else {
            timeLabel.text = "00:00"
        }
    }

    public override func configNavigation() {
        super.configNavigation()
    }

    public override func addView() {
        [pageTitleLabel, authCodeTextField, timeLabel, resendButton, authError, authButton]
            .forEach { view.addSubview($0) }
    }

    public override func setLayout() {
        pageTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(124)
            $0.leading.equalTo(20)
        }

        authCodeTextField.snp.makeConstraints {
            $0.height.equalTo(56)
            $0.leading.equalTo(bounds.width * 0.05)
            $0.trailing.equalTo(-bounds.width * 0.05)
            $0.top.equalTo(pageTitleLabel.snp.bottom).offset(24)
        }

        authError.snp.makeConstraints {
            $0.trailing.equalTo(authCodeTextField.snp.trailing)
            $0.top.equalTo(authCodeTextField.snp.bottom).offset(8)
            $0.height.equalTo(0)
        }

        timeLabel.snp.makeConstraints {
            $0.leading.equalTo(bounds.width * 0.07)
            $0.top.equalTo(authCodeTextField.snp.bottom).offset(12)
        }

        resendButton.snp.makeConstraints {
            $0.top.equalTo(authCodeTextField.snp.bottom).offset(12)
            $0.trailing.equalTo(-bounds.width * 0.07)
        }

        authButton.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(24)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).offset(-24)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
        }
    }

    private func authCodeError() {
        authError.isHidden = false
        authError.snp.updateConstraints {
            $0.height.equalTo(19)
        }
        timeLabel.snp.remakeConstraints {
            $0.leading.equalTo(bounds.width * 0.07)
            $0.top.equalTo(authError.snp.bottom).offset(12)
        }
        resendButton.snp.remakeConstraints {
            $0.top.equalTo(authError.snp.bottom).offset(12)
            $0.trailing.equalTo(-bounds.width * 0.07)
        }
        timeLabel.isHidden = false
        view.layoutIfNeeded()
    }

    private func authCodeSuccess() {
        authCodeTextField.layer.borderWidth = 0
        authError.isHidden = true
        authError.snp.updateConstraints {
            $0.height.equalTo(0)
        }
        timeLabel.snp.remakeConstraints {
            $0.leading.equalTo(bounds.width * 0.07)
            $0.top.equalTo(authCodeTextField.snp.bottom).offset(12)
        }
        resendButton.snp.remakeConstraints {
            $0.top.equalTo(authCodeTextField.snp.bottom).offset(12)
            $0.trailing.equalTo(-bounds.width * 0.07)
        }
        timeLabel.isHidden = false
        view.layoutIfNeeded()
    }
}

extension AuthCodeViewController: UITextFieldDelegate {

    public func textFieldDidChange(_ textField: UITextField) {
        if textField == authCodeTextField {
            authCodeSuccess()
            viewModel.setupAuthCode(authCode: textField.text ?? "")
        }
    }

    public func textField(_ textField: UITextField,
                          shouldChangeCharactersIn range: NSRange,
                          replacementString string: String) -> Bool {

        if textField == authCodeTextField {
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            return updatedText.count <= 4
        }
        return true
    }
}
