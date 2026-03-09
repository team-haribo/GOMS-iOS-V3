//
//  FindPasswordViewController.swift
//  Feature
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit

public final class FindPasswordViewController: BaseViewController {

    private var viewModel: AuthViewModel
    
    private let pageTitleLabel = UILabel().then {
        $0.text = "비밀번호 찾기"
        $0.font = .suit(size: 24, weight: .bold)
        $0.textColor = .color.mainText.color
    }

    private let emailTextField = GOMSTextField(
        frame: .zero,
        placeholder: "이메일을 입력해주세요"
    )

    private let defaultDomain = UILabel().then {
        $0.text = "@gsm.hs.kr"
        $0.font = .suit(size: 16, weight: .medium)
        $0.textColor = .color.sub2.color
    }

    let emailErrorLabel = UILabel().then {
        $0.text = "잘못된 형식의 이메일입니다"
        $0.textColor = .color.gomsNegative.color
        $0.font = .suit(size: 15, weight: .medium)
        $0.textAlignment = .right
        $0.isHidden = true
    }

    private lazy var authCodeButton = GOMSButton(
        frame: .zero,
        title: "인증번호 받기"
    ).then {
        $0.addTarget(self,
                     action: #selector(authCodeButtonTapped),
                     for: .touchUpInside)
    }

    init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        emailTextField.addTarget(self,
                                 action: #selector(emailEditingChanged(_:)),
                                 for: .editingChanged)
    }

    @objc private func emailEditingChanged(_ textField: UITextField) {
        textFieldDidChange(textField)
    }

    @objc private func authCodeButtonTapped() {

        let email = emailTextField.text ?? ""

        if email.isEmpty {
            emailErrorLabel.text = "이메일을 입력해주세요."
            showEmailError()
            return
        }

        let emailRegex = "^s[0-9]{5}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)

        if !emailPredicate.evaluate(with: email) {
            emailErrorLabel.text = "올바른 이메일 형식이 아닙니다."
            showEmailError()
            return
        }

        viewModel.setupEmail(email: email)
        viewModel.setupEmailStatus(emailStatus: "AFTER_SIGNUP")

        viewModel.sendAuthCode { success, statusCode in

            if statusCode == 204 {
                self.successUI()
                let authCodeVC = AuthCodeViewController(
                    viewModel: self.viewModel,
                    previousViewController: self,
                    email: self.emailTextField.text ?? ""
                )
                self.navigationController?.pushViewController(authCodeVC,
                                                              animated: true)

            } else if statusCode == 404 {
                self.nonExistentUser()

            } else {
                self.emailErrorUI()
            }
        }
    }

    private func emailBlankValue() {
        emailTextField.setPlaceholderColor(.color.gomsNegative.color)
        defaultDomain.textColor = .color.gomsNegative.color
        emailErrorLabel.text = "유효한 이메일을 입력해주세요."
        emailErrorLabel.isHidden = false
        emailTextField.layer.borderColor = UIColor.systemRed.cgColor
        emailTextField.layer.borderWidth = 1
    }

    private func nonExistentUser() {
        emailTextField.setPlaceholderColor(.color.gomsNegative.color)
        defaultDomain.textColor = .color.gomsNegative.color
        emailErrorLabel.text = "존재하지 않는 사용자입니다."
        emailErrorLabel.isHidden = false
        emailTextField.layer.borderColor = UIColor.systemRed.cgColor
        emailTextField.layer.borderWidth = 1
    }

    private func successUI() {
        emailTextField.setPlaceholderColor(.color.sub2.color)
        defaultDomain.textColor = .color.sub2.color
        emailErrorLabel.isHidden = true
        emailTextField.layer.borderColor = UIColor.clear.cgColor
        emailTextField.layer.borderWidth = 0

        emailErrorLabel.snp.updateConstraints {
            $0.height.equalTo(0)
        }
        view.layoutIfNeeded()
    }

    private func emailErrorUI() {
        emailTextField.setPlaceholderColor(.color.gomsNegative.color)
        defaultDomain.textColor = .color.gomsNegative.color
        emailErrorLabel.isHidden = false
        emailTextField.layer.borderColor = UIColor.systemRed.cgColor
        emailTextField.layer.borderWidth = 1
    }

    private func showEmailError() {
        emailTextField.setPlaceholderColor(.color.gomsNegative.color)
        defaultDomain.textColor = .color.gomsNegative.color
        emailErrorLabel.isHidden = false
        emailErrorLabel.snp.updateConstraints {
            $0.height.equalTo(19)
        }
        emailTextField.layer.borderColor = UIColor.systemRed.cgColor
        emailTextField.layer.borderWidth = 1

        view.layoutIfNeeded()
    }

    @objc public override func keyboardWillShow(_ sender: Notification) {
        guard
            let userInfo = sender.userInfo,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }

        let keyboardHeight = keyboardFrame.height - view.safeAreaInsets.bottom

        authCodeButton.snp.updateConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-(keyboardHeight + 24))
        }

        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }

    @objc public override func keyboardWillHide(_ sender: Notification) {
        guard
            let userInfo = sender.userInfo,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }

        authCodeButton.snp.updateConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
        }

        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }


    public override func addView() {
        emailTextField.addSubview(defaultDomain)

        [ pageTitleLabel,
            emailTextField,
            emailErrorLabel,
            authCodeButton
        ].forEach { view.addSubview($0) }
    }

    public override func setLayout() {
        
        pageTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(90 + 26)
            $0.leading.equalTo(24)
        }

        defaultDomain.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(28)
            $0.centerY.equalToSuperview()
        }

        emailTextField.snp.makeConstraints {
            $0.leading.equalTo(bounds.width * 0.05)
            $0.trailing.equalTo(-bounds.width * 0.05)
            $0.height.equalTo(56)
            $0.top.equalTo(bounds.height * 0.21)
        }

        emailErrorLabel.snp.makeConstraints {
            $0.leading.equalTo(emailTextField.snp.leading)
            $0.trailing.equalTo(emailTextField.snp.trailing)
            $0.top.equalTo(emailTextField.snp.bottom).offset(8)
            $0.height.equalTo(0)
        }

        authCodeButton.snp.makeConstraints {
            $0.leading.equalTo(bounds.width * 0.05)
            $0.trailing.equalTo(-bounds.width * 0.05)
            $0.height.equalTo(48)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
        }
    }
}

// MARK: - Extension

extension FindPasswordViewController: UITextFieldDelegate {

    public func textFieldDidChange(_ textField: UITextField) {
        if textField == emailTextField {

            let email = textField.text ?? ""
            viewModel.setupEmail(email: email)

            let emailRegex = "^s[0-9]{5}$"
            let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)

            if email.isEmpty {
                emailErrorLabel.isHidden = true
                emailTextField.layer.borderWidth = 0

                emailErrorLabel.snp.updateConstraints {
                    $0.height.equalTo(0)
                }
                view.layoutIfNeeded()

            } else if !emailPredicate.evaluate(with: email) {
                emailErrorLabel.text = "올바른 이메일 형식이 아닙니다."
                showEmailError()

            } else {
                successUI()
            }
        }
    }

    public func textField(_ textField: UITextField,
                          shouldChangeCharactersIn range: NSRange,
                          replacementString string: String) -> Bool {

        if textField == emailTextField {
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else {
                return false
            }
            let updatedText = currentText.replacingCharacters(in: stringRange,
                                                             with: string)
            return updatedText.count <= 6
        }
        return true
    }
}
