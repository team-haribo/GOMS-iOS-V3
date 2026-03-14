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

    private let pageTitleLabel = UILabel().then {
        $0.text = "새 비밀번호 설정"
        $0.font = .suit(size: 28, weight: .bold)
        $0.textColor = .color.mainText.color
    }

    private let textFieldStackView = UIStackView().then {
        $0.spacing = 16
        $0.axis = .vertical
        $0.distribution = .fill
        $0.alignment = .fill
    }

    lazy var passwordTextField = GOMSTextField(frame: .zero, placeholder: "비밀번호를 입력해주세요").then {
        $0.isSecureTextEntry = true
        $0.rightView = onPasswordButton
        $0.rightViewMode = .always
    }

    private let checkPasswordTextField = GOMSTextField(frame: .zero, placeholder: "비밀번호를 다시 입력해주세요").then {
        $0.isSecureTextEntry = true
    }

    lazy var onPasswordButton = UIButton().then {
        $0.setImage(.image.on.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = .color.sub2.color
        $0.adjustsImageWhenHighlighted = false
        $0.addTarget(self, action: #selector(onPasswordButtonTapped), for: .touchUpInside)
    }

    private let passwordFormatError = UILabel().then {
        $0.text = "잘못된 형식의 비밀번호입니다"
        $0.textColor = .color.gomsNegative.color
        $0.font = .suit(size: 16, weight: .medium)
        $0.textAlignment = .right
        $0.numberOfLines = 0
        $0.isHidden = true
    }

    private let passwordMatchError = UILabel().then {
        $0.text = "비밀번호가 일치하지 않습니다"
        $0.textColor = .color.gomsNegative.color
        $0.font = .suit(size: 16, weight: .medium)
        $0.textAlignment = .right
        $0.numberOfLines = 0
        $0.isHidden = true
    }

    private let conditionsLabel = UILabel().then {
        $0.text = "비밀번호는 6자 이상이, 대/소문자, 숫자, 특수문자를 포함해 주세요"
        $0.font = .suit(size: 16, weight: .regular)
        $0.textColor = .color.sub2.color
        $0.numberOfLines = 0
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

        passwordTextField.addTarget(self, action: #selector(passwordEditingChanged), for: .editingChanged)
        checkPasswordTextField.addTarget(self, action: #selector(checkPasswordEditingChanged), for: .editingChanged)
    }

    @objc private func passwordEditingChanged() {

        let password = passwordTextField.text ?? ""

        if password.isEmpty {
            passwordFormatError.isHidden = true
            passwordTextField.setPlaceholderColor(.color.sub2.color)
            passwordTextField.layer.borderColor = UIColor.clear.cgColor
            passwordTextField.layer.borderWidth = 0
            return
        }

        let passwordRegex = "^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[^A-Za-z0-9]).{6,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)

        if !passwordPredicate.evaluate(with: password) {
            passwordFormatError.isHidden = false
            passwordFormatError.text = "잘못된 형식의 비밀번호입니다"
            passwordTextField.layer.borderColor = UIColor.systemRed.cgColor
            passwordTextField.layer.borderWidth = 1
        } else {
            passwordFormatError.isHidden = true
            passwordTextField.layer.borderColor = UIColor.clear.cgColor
            passwordTextField.layer.borderWidth = 0
        }

        let confirm = checkPasswordTextField.text ?? ""

        if confirm.isEmpty {
            passwordMatchError.isHidden = true
            checkPasswordTextField.layer.borderColor = UIColor.clear.cgColor
            checkPasswordTextField.layer.borderWidth = 0
        } else if password == confirm {
            passwordMatchError.isHidden = true
            checkPasswordTextField.layer.borderColor = UIColor.clear.cgColor
            checkPasswordTextField.layer.borderWidth = 0
        } else {
            passwordMatchError.isHidden = false
            checkPasswordTextField.layer.borderColor = UIColor.systemRed.cgColor
            checkPasswordTextField.layer.borderWidth = 1
        }
    }

    @objc private func checkPasswordEditingChanged() {

        let password = passwordTextField.text ?? ""
        let confirm = checkPasswordTextField.text ?? ""

        if confirm.isEmpty {
            passwordMatchError.isHidden = true
            checkPasswordTextField.setPlaceholderColor(.color.sub2.color)
            checkPasswordTextField.layer.borderColor = UIColor.clear.cgColor
            checkPasswordTextField.layer.borderWidth = 0
            return
        }

        if password == confirm {
            passwordMatchError.isHidden = true
            checkPasswordTextField.layer.borderColor = UIColor.clear.cgColor
            checkPasswordTextField.layer.borderWidth = 0
            return
        }

        passwordMatchError.isHidden = false
        checkPasswordTextField.layer.borderColor = UIColor.systemRed.cgColor
        checkPasswordTextField.layer.borderWidth = 1
    }

    @objc private func doneButtonTapped() {

        if passwordTextField.text?.isEmpty == true {

            passwordTextField.setPlaceholderColor(.color.gomsNegative.color)
            passwordTextField.layer.borderColor = UIColor.systemRed.cgColor
            passwordTextField.layer.borderWidth = 1

            passwordFormatError.isHidden = false
            passwordFormatError.text = "비밀번호를 입력해주세요"

            return
        }

        let password = passwordTextField.text ?? ""
        let passwordRegex = "^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[^A-Za-z0-9]).{6,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)

        if !passwordPredicate.evaluate(with: password) {

            passwordTextField.layer.borderColor = UIColor.systemRed.cgColor
            passwordTextField.layer.borderWidth = 1

            passwordFormatError.isHidden = false
            passwordFormatError.text = "잘못된 형식의 비밀번호입니다"

            return
        }

        if passwordTextField.text != checkPasswordTextField.text {

            passwordMatchError.isHidden = false

            checkPasswordTextField.layer.borderColor = UIColor.systemRed.cgColor
            checkPasswordTextField.layer.borderWidth = 1

            return
        }

        let alert = UIAlertController(
            title: "재설정 완료",
            message: "비밀번호가 재설정되었습니다.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in

            let introVC = IntroViewController()
            let nav = UINavigationController(rootViewController: introVC)

            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController = nav
                window.makeKeyAndVisible()
            }
        })

        self.present(alert, animated: true)
    }

    @objc private func onPasswordButtonTapped() {
        passwordTextField.isSecureTextEntry.toggle()
        passwordTextField.isSelected.toggle()

        if passwordTextField.isSelected {
            onPasswordButton.setImage(.image.off.image.withRenderingMode(.alwaysTemplate), for: .normal)
        } else {
            onPasswordButton.setImage(.image.on.image.withRenderingMode(.alwaysTemplate), for: .normal)
        }
    }

    @objc public override func keyboardWillShow(_ sender: Notification) {
        guard
            let userInfo = sender.userInfo,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }

        let keyboardHeight = keyboardFrame.height - view.safeAreaInsets.bottom

        doneButton.snp.updateConstraints {
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

        doneButton.snp.updateConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
        }

        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }

    public override func addView() {

        textFieldStackView.addArrangedSubview(passwordTextField)
        textFieldStackView.addArrangedSubview(passwordFormatError)
        textFieldStackView.addArrangedSubview(checkPasswordTextField)
        textFieldStackView.addArrangedSubview(passwordMatchError)

        [
            pageTitleLabel,
            textFieldStackView,
            conditionsLabel,
            doneButton
        ].forEach { view.addSubview($0) }
    }

    public override func setLayout() {

        pageTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(124)
            $0.leading.equalTo(20)
        }

        passwordTextField.snp.makeConstraints { $0.height.equalTo(56) }
        checkPasswordTextField.snp.makeConstraints { $0.height.equalTo(56) }

        textFieldStackView.snp.makeConstraints {
            $0.leading.equalTo(bounds.width * 0.05)
            $0.trailing.equalTo(-bounds.width * 0.05)
            $0.top.equalTo(pageTitleLabel.snp.bottom).offset(24)
        }

        conditionsLabel.snp.makeConstraints {
            $0.top.equalTo(textFieldStackView.snp.bottom).offset(12)
            $0.leading.equalTo(bounds.width * 0.07)
            $0.trailing.equalTo(-bounds.width * 0.05)
        }

        doneButton.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(24)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).offset(-24)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
        }
    }
}

extension NewPasswordViewController: UITextFieldDelegate {

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

