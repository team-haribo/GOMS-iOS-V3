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

    private let authCodeTextField = GOMSTextField().then {
        $0.keyboardType = .numberPad
    }

    private let timeLabel = UILabel().then {
        $0.font = .suit(size: 16, weight: .regular)
        $0.textColor = .color.sub2.color
    }

    private lazy var resendButton = UIButton().then {
        $0.setTitle("재발송", for: .normal)
        $0.backgroundColor = .clear
        $0.titleLabel?.font = UIFont.suit(size: 16, weight: .regular)
        $0.setTitleColor(.color.gomsInformation.color, for: .normal)
        $0.addTarget(self, action: #selector(resendButtonTapped), for: .touchUpInside)
    }

    private let authError = UILabel().then {
        $0.text = "잘못된 인증번호입니다"
        $0.textColor = .color.gomsNegative.color
        $0.font = .suit(size: 16, weight: .regular)
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
        getSetTime()
    }

    @objc private func getSetTime() {
        secToTime(sec: limitTime)
        limitTime -= 1
    }

    @objc private func resendButtonTapped() {
        viewModel.setupAuthCode(authCode: authCodeTextField.text ?? "")
        viewModel.sendAuthCode { success, statusCode in
            if success {
                let alert = UIAlertController(title: "재발송 완료",
                                              message: "인증코드 재발송이 완료되었습니다.\n이메일을 확인해주세요.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .cancel))
                self.present(alert, animated: true)
            } else {
                let alert = UIAlertController(title: "재발송 실패",
                                              message: "인증코드 재발송이 실패했습니다.\n다시시도 해주세요.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .cancel))
                self.present(alert, animated: true)
            }
        }
    }

    @objc private func authButtonTapped() {
        viewModel.setupAuthCode(authCode: authCodeTextField.text ?? "")
        viewModel.verifyAuthCode { success in
            if success {
                self.authCodeSuccess()

                if self.previousViewController is FindPasswordViewController {
                    let newPasswordVC = NewPasswordViewController(viewModel: self.viewModel,
                                                                 email: self.email ?? "")
                    self.navigationController?.pushViewController(newPasswordVC, animated: true)
                } else if self.previousViewController is SignUpViewController {
                    let passwordSettingVC = PasswordSettingViewController(viewModel: self.viewModel)
                    self.navigationController?.pushViewController(passwordSettingVC, animated: true)
                }
            } else {
                self.authCodeError()
            }
        }
    }

    public override func keyboardWillShow(_ sender: Notification) {
        authButton.snp.remakeConstraints {
            $0.leading.equalTo(bounds.width * 0.05)
            $0.trailing.equalTo(-bounds.width * 0.05)
            $0.bottom.equalTo(-bounds.height * 0.42)
            $0.height.equalTo(48)
        }
    }

    public override func keyboardWillHide(_ sender: Notification) {
        authButton.snp.remakeConstraints {
            $0.leading.equalTo(bounds.width * 0.05)
            $0.trailing.equalTo(-bounds.width * 0.05)
            $0.bottom.equalTo(-bounds.height * 0.16)
            $0.height.equalTo(48)
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
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "인증번호 입력"
    }

    public override func addView() {
        [authCodeTextField, timeLabel, resendButton, authError, authButton]
            .forEach { view.addSubview($0) }
    }

    public override func setLayout() {
        authCodeTextField.snp.makeConstraints {
            $0.height.equalTo(56)
            $0.leading.equalTo(bounds.width * 0.05)
            $0.trailing.equalTo(-bounds.width * 0.05)
            $0.top.equalTo(bounds.height * 0.21)
        }

        timeLabel.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.leading.equalTo(bounds.width * 0.07)
            $0.top.equalTo(authCodeTextField.snp.bottom)
        }

        resendButton.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.top.equalTo(authCodeTextField.snp.bottom)
            $0.trailing.equalTo(-bounds.width * 0.07)
        }

        authError.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.top.equalTo(authCodeTextField.snp.bottom)
            $0.leading.equalTo(bounds.width * 0.07)
        }

        authButton.snp.makeConstraints {
            $0.leading.equalTo(bounds.width * 0.05)
            $0.trailing.equalTo(-bounds.width * 0.05)
            $0.bottom.equalTo(-bounds.height * 0.16)
            $0.height.equalTo(48)
        }
    }

    private func authCodeError() {
        timeLabel.isHidden = true
        authError.isHidden = false
    }

    private func authCodeSuccess() {
        timeLabel.isHidden = false
        authError.isHidden = true
    }
}

extension AuthCodeViewController: UITextFieldDelegate {

    public func textFieldDidChange(_ textField: UITextField) {
        if textField == authCodeTextField {
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
