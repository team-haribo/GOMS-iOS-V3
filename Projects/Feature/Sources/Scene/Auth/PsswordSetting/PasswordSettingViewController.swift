//
//  PasswordSettingViewController.swift
//  Feature
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit

public final class PasswordSettingViewController: BaseViewController {

    private var viewModel: AuthViewModel
    private let loader = LoaderViewController()

    private let textFieldStackView = UIStackView().then {
        $0.spacing = 32
        $0.axis = .vertical
        $0.distribution = .fillEqually
        $0.alignment = .fill
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

    private let passwordError = UILabel().then {
        $0.text = "비밀번호가 일치하지 않습니다."
        $0.textColor = .color.gomsNegative.color
        $0.font = .suit(size: 16, weight: .medium)
        $0.isHidden = true
    }

    private lazy var signUpButton = GOMSButton(frame: .zero, title: "회원가입").then {
        $0.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
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
        passwordTextField.delegate = self
        checkPasswordTextField.delegate = self
    }

    @objc private func signUpButtonTapped() {

        viewModel.setupNewPassword(
            newPassword: passwordTextField.text ?? "",
            checkPassword: checkPasswordTextField.text ?? ""
        )

        DispatchQueue.main.async {
            self.present(self.loader, animated: true)
        }

        viewModel.signUp { success in

            if success {

                self.signUpSuccessUI()
                let signInVC = SignInViewController(viewModel: self.viewModel)
                self.navigationController?.pushViewController(signInVC, animated: true)
                self.loader.dismiss(animated: true)

            } else {

                self.passwordErrorUI()
                self.loader.dismiss(animated: true)
            }
        }
    }

    private func signUpSuccessUI() {
        checkPasswordTextField.setPlaceholderColor(.color.mainText.color)
        passwordError.isHidden = true
        checkPasswordTextField.layer.borderColor = UIColor.clear.cgColor
        checkPasswordTextField.layer.borderWidth = 0
        conditionsLabel.isHidden = false
    }

    private func passwordErrorUI() {
        checkPasswordTextField.setPlaceholderColor(.color.gomsNegative.color)
        passwordError.isHidden = false
        checkPasswordTextField.layer.borderColor = UIColor.systemRed.cgColor
        checkPasswordTextField.layer.borderWidth = 1
        conditionsLabel.isHidden = true
    }

    @objc private func onPasswordButtonTapped() {
        passwordTextField.isSecureTextEntry.toggle()
        passwordTextField.isSelected.toggle()

        if passwordTextField.isSelected {
            onPasswordButton.setImage(.image.off.image, for: .normal)
        } else {
            onPasswordButton.setImage(.image.on.image, for: .normal)
        }
    }

    @objc public override func keyboardWillShow(_ sender: Notification) {
        signUpButton.snp.remakeConstraints {
            $0.leading.equalTo(bounds.width * 0.05)
            $0.trailing.equalTo(-bounds.width * 0.05)
            $0.bottom.equalTo(-bounds.height * 0.42)
            $0.height.equalTo(48)
        }
    }

    @objc public override func keyboardWillHide(_ sender: Notification) {
        signUpButton.snp.remakeConstraints {
            $0.leading.equalTo(bounds.width * 0.05)
            $0.trailing.equalTo(-bounds.width * 0.05)
            $0.bottom.equalTo(-bounds.height * 0.16)
            $0.height.equalTo(48)
        }
    }

    public override func configNavigation() {
        super.configNavigation()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "비밀번호 설정"
    }

    public override func addView() {

        [passwordTextField, checkPasswordTextField]
            .forEach { textFieldStackView.addArrangedSubview($0) }

        [
            textFieldStackView,
            conditionsLabel,
            passwordError,
            signUpButton
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

        passwordError.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.top.equalTo(textFieldStackView.snp.bottom)
            $0.leading.equalTo(bounds.width * 0.07)
        }

        signUpButton.snp.makeConstraints {
            $0.leading.equalTo(bounds.width * 0.05)
            $0.trailing.equalTo(-bounds.width * 0.05)
            $0.bottom.equalTo(-bounds.height * 0.16)
            $0.height.equalTo(48)
        }
    }
}

extension PasswordSettingViewController: UITextFieldDelegate {

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

    public func textFieldDidChange(_ textField: UITextField) {
        if textField == passwordTextField {
            viewModel.setupNewPassword(
                newPassword: textField.text ?? "",
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
}
