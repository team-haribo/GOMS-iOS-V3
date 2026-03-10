//
//  NewPasswordViewController.swift
//  Feature
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit

public final class NewPasswordViewController: BaseViewController {

    private var viewModel: AuthViewModel
    var email: String

    private let textFieldStackView = UIStackView().then {
        $0.spacing = 32
        $0.axis = .vertical
        $0.distribution = .fillEqually
        $0.alignment = .fill
    }

    let passwordErrorLabel = UILabel().then {
        $0.text = "비밀번호가 일치하지 않습니다."
        $0.textColor = .color.gomsNegative.color
        $0.font = .suit(size: 16, weight: .medium)
        $0.isHidden = true
    }

    let passwordWrongRegularExpression = UILabel().then {
        $0.text = "잘못된 비밀번호입니다."
        $0.textColor = .color.gomsNegative.color
        $0.font = .suit(size: 16, weight: .medium)
        $0.isHidden = true
    }

    let passwordOverlapErrorLabel = UILabel().then {
        $0.text = "이미 사용중인 비밀번호입니다."
        $0.textColor = .color.gomsNegative.color
        $0.font = .suit(size: 16, weight: .medium)
        $0.isHidden = true
    }

    lazy var passwordTextField = GOMSTextField(frame: .zero, placeholder: "비밀번호").then {
        $0.isSecureTextEntry = true
        $0.rightView = onPasswordButton
        $0.rightViewMode = .always
    }

    lazy var onPasswordButton = UIButton().then {
        $0.setImage(.image.on.image, for: .normal)
        $0.addTarget(self, action: #selector(onPasswordButtonTapped), for: .touchUpInside)
        $0.isEnabled = true
    }

    private let checkPasswordTextField = GOMSTextField(frame: .zero, placeholder: "비밀번호 확인").then {
        $0.isSecureTextEntry = true
    }

    private let conditionsLabel = UILabel().then {
        $0.text = "대/소문자, 숫자, 특수문자 포함 6자 이상"
        $0.font = .suit(size: 16, weight: .regular)
        $0.textColor = .color.sub2.color
    }

    private lazy var doneButton = GOMSButton(frame: .zero, title: "완료").then {
        $0.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
    }

    init(viewModel: AuthViewModel, email: String) {
        self.viewModel = viewModel
        self.email = email
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.delegate = self
        checkPasswordTextField.delegate = self
    }

    @objc private func doneButtonTapped() {

        let defaults = UserDefaults.standard
        let localPassword = defaults.string(forKey: "localPass")

        let isValidPassword = validatePassword()

        viewModel.setupEmail(email: email)
        viewModel.setupNewServePassword(
            newPassword: passwordTextField.text ?? "",
            checkPassword: checkPasswordTextField.text ?? ""
        )
        viewModel.setupPassword(password: localPassword ?? "")

        viewModel.newPassword { [self] success, statusCode in

            if !isValidPassword {
                self.passwordWrongRegularExpressionUI()

            } else if passwordTextField.text != checkPasswordTextField.text {
                self.passwordErrorUI()
                conditionsLabel.isHidden = true

            } else if passwordTextField.text == "" {
                self.passwordErrorUI()

            } else if !success {

                switch statusCode {
                case 400:
                    self.passwordOverlapErrorUI()
                    conditionsLabel.isHidden = false
                case 404:
                    print("404")
                default:
                    print("Error: \(statusCode)")
                }

            } else if success {

                UserDefaults.standard.set(
                    self.checkPasswordTextField.text,
                    forKey: "localPass"
                )

                let alert = UIAlertController(
                    title: "재설정 완료",
                    message: "비밀번호가 재설정되었습니다.\n로그인 화면으로 돌아갑니다.",
                    preferredStyle: .alert
                )

                let check = UIAlertAction(title: "확인", style: .default) { _ in
                    let loginVC = IntroViewController()
                    self.navigationController?.pushViewController(loginVC, animated: true)
                }

                passwordOverlapErrorLabel.isHidden = true
                passwordTextField.layer.borderWidth = 0
                passwordTextField.setPlaceholderColor(.color.sub2.color)

                passwordErrorLabel.isHidden = true
                checkPasswordTextField.layer.borderWidth = 0
                checkPasswordTextField.setPlaceholderColor(.color.sub2.color)

                alert.addAction(check)
                self.present(alert, animated: true)
            }
        }
    }

    @objc private func onPasswordButtonTapped() {
        passwordTextField.isSecureTextEntry.toggle()
        checkPasswordTextField.isSecureTextEntry.toggle()
        passwordTextField.isSelected.toggle()
        checkPasswordTextField.isSelected.toggle()

        if passwordTextField.isSelected {
            onPasswordButton.setImage(.image.off.image, for: .normal)
        } else {
            onPasswordButton.setImage(.image.on.image, for: .normal)
        }
    }

    @objc public override func keyboardWillShow(_ sender: Notification) {
        doneButton.snp.remakeConstraints {
            $0.leading.equalTo(bounds.width * 0.05)
            $0.trailing.equalTo(-bounds.width * 0.05)
            $0.height.equalTo(48)
            $0.bottom.equalTo(-bounds.height * 0.43)
        }
    }

    @objc public override func keyboardWillHide(_ sender: Notification) {
        doneButton.snp.remakeConstraints {
            $0.leading.equalTo(bounds.width * 0.05)
            $0.trailing.equalTo(-bounds.width * 0.05)
            $0.bottom.equalTo(-bounds.height * 0.16)
            $0.height.equalTo(48)
        }
    }

    private func validatePassword() -> Bool {
        guard let password = passwordTextField.text else { return false }

        let regexPattern = "^(?=.*[a-z])(?=.*\\d)(?=.*[\\W_])[A-Za-z\\d\\W_]{6,16}$"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", regexPattern)
        return passwordTest.evaluate(with: password)
    }

    private func passwordErrorUI() {
        checkPasswordTextField.setPlaceholderColor(.color.gomsNegative.color)
        passwordErrorLabel.isHidden = false
        checkPasswordTextField.layer.borderColor = UIColor.systemRed.cgColor
        checkPasswordTextField.layer.borderWidth = 1

        passwordOverlapErrorLabel.isHidden = true
        passwordWrongRegularExpression.isHidden = true
        passwordTextField.layer.borderWidth = 0
        passwordTextField.setPlaceholderColor(.color.sub2.color)
    }

    private func passwordOverlapErrorUI() {
        passwordTextField.setPlaceholderColor(.color.gomsNegative.color)
        passwordOverlapErrorLabel.isHidden = false
        passwordTextField.layer.borderColor = UIColor.systemRed.cgColor
        passwordTextField.layer.borderWidth = 1

        passwordWrongRegularExpression.isHidden = true
        passwordErrorLabel.isHidden = true
        checkPasswordTextField.layer.borderWidth = 0
        checkPasswordTextField.setPlaceholderColor(.color.sub2.color)
    }

    private func passwordWrongRegularExpressionUI() {
        passwordTextField.setPlaceholderColor(.color.gomsNegative.color)
        passwordWrongRegularExpression.isHidden = false
        passwordTextField.layer.borderColor = UIColor.systemRed.cgColor
        passwordTextField.layer.borderWidth = 1

        passwordOverlapErrorLabel.isHidden = true
        passwordErrorLabel.isHidden = true
        checkPasswordTextField.layer.borderWidth = 0
        checkPasswordTextField.setPlaceholderColor(.color.sub2.color)
    }

    public override func configNavigation() {
        super.configNavigation()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "비밀번호 재설정"
    }

    public override func addView() {
        [passwordTextField, checkPasswordTextField]
            .forEach { textFieldStackView.addArrangedSubview($0) }

        [
            textFieldStackView,
            conditionsLabel,
            doneButton,
            passwordErrorLabel,
            passwordOverlapErrorLabel,
            passwordWrongRegularExpression
        ].forEach { view.addSubview($0) }
    }

    public override func setLayout() {

        passwordTextField.snp.makeConstraints { $0.height.equalTo(56) }
        checkPasswordTextField.snp.makeConstraints { $0.height.equalTo(56) }

        textFieldStackView.snp.makeConstraints {
            $0.leading.equalTo(bounds.width * 0.05)
            $0.trailing.equalTo(-bounds.width * 0.05)
            $0.top.equalTo(bounds.height * 0.21)
        }

        conditionsLabel.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.top.equalTo(textFieldStackView.snp.bottom)
            $0.leading.equalTo(bounds.width * 0.07)
        }

        passwordErrorLabel.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.top.equalTo(checkPasswordTextField.snp.bottom).inset(5)
            $0.leading.equalTo(bounds.width * 0.07)
        }

        passwordOverlapErrorLabel.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.top.equalTo(passwordTextField.snp.bottom).inset(5)
            $0.leading.equalTo(bounds.width * 0.07)
        }

        passwordWrongRegularExpression.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.top.equalTo(passwordTextField.snp.bottom).inset(5)
            $0.leading.equalTo(bounds.width * 0.07)
        }

        doneButton.snp.makeConstraints {
            $0.leading.equalTo(bounds.width * 0.05)
            $0.trailing.equalTo(-bounds.width * 0.05)
            $0.bottom.equalTo(-bounds.height * 0.16)
            $0.height.equalTo(48)
        }
    }
}

extension NewPasswordViewController: UITextFieldDelegate {

    public func textFieldDidChange(_ textField: UITextField) {
        if textField == passwordTextField {
            viewModel.setupNewPassword(
                newPassword: passwordTextField.text ?? "",
                checkPassword: checkPasswordTextField.text ?? ""
            )
        }
    }

    public func textField(_ textField: UITextField,
                          shouldChangeCharactersIn range: NSRange,
                          replacementString string: String) -> Bool {

        let currentText = (textField.text ?? "") as NSString
        let updatedText = currentText.replacingCharacters(in: range, with: string)

        if updatedText.rangeOfCharacter(from: .whitespaces) != nil {
            return false
        }

        return true
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if passwordTextField.text != "", checkPasswordTextField.text != "" {
            checkPasswordTextField.resignFirstResponder()
            return true
        } else if passwordTextField.text != "" {
            checkPasswordTextField.becomeFirstResponder()
            return true
        }
        return false
    }
}
