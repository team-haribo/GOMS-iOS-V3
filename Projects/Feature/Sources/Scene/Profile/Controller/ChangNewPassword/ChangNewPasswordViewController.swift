//
//  ChangNewPasswordViewController.swift
//  Feature
//
//  Created by 김준표 on 2/25/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit

public final class ChangNewPasswordViewController: BaseViewController {

    // MARK: - Properties
    private let viewModel = AuthViewModel()
    
    private let textFieldStackView = UIStackView().then {
        $0.spacing = 16
        $0.axis = .vertical
        $0.distribution = .fillEqually
        $0.alignment = .fill
    }
    
    let navigationTitle = UILabel().then {
        $0.text = "비밀번호 재설정"
        $0.textColor = .color.mainText.color
        $0.font = .suit(size: 29, weight: .bold)
        $0.textAlignment = .right
    }
    
    let passwordErrorLabel = UILabel().then {
        $0.text = "비밀번호가 일치하지 않습니다."
        $0.textColor = .color.gomsNegative.color
        $0.font = .suit(size: 16, weight: .medium)
        $0.isHidden = true
        $0.textAlignment = .right
    }
    
    let passwordWrongRegularExpression = UILabel().then {
        $0.text = "잘못된 비밀번호입니다."
        $0.textColor = .color.gomsNegative.color
        $0.font = .suit(size: 16, weight: .medium)
        $0.isHidden = true
        $0.textAlignment = .right
    }
    
    let passwordOverlapErrorLabel = UILabel().then {
        $0.text = "이미 사용중인 비밀번호입니다."
        $0.textColor = .color.gomsNegative.color
        $0.font = .suit(size: 16, weight: .medium)
        $0.isHidden = true
        $0.textAlignment = .right
    }
    
    lazy var passwordTextField = GOMSTextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0), placeholder: "비밀번호").then {
        $0.isSecureTextEntry = true
        $0.rightView = onPasswordButton
        $0.rightViewMode = .always
    }
    
    lazy var onPasswordButton = UIButton().then {
        $0.setImage(.image.on.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = .color.sub2.color
        $0.adjustsImageWhenHighlighted = false
        $0.addTarget(self, action: #selector(onPasswordButtonTapped), for: .touchUpInside)
        $0.isEnabled = true
    }
    
    private let checkPasswordTextField = GOMSTextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0), placeholder: "비밀번호 확인").then {
        $0.isSecureTextEntry = true
    }
    
    private let conditionsLabel = UILabel().then {
        $0.text = "대/소문자, 특수문자 포함 6~15자"
        $0.font = .suit(size: 15, weight: .regular)
        $0.textColor = .color.sub2.color
    }
    
    lazy var doneButton = GOMSButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0), title: "완료").then {
        $0.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Life Cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordTextField.delegate = self
        checkPasswordTextField.delegate = self
        addView()
        setLayout()
    }
    
    // MARK: - Selectors
    @objc func doneButtonTapped() {

        let isValidPassword = self.validatePassword()

        if passwordTextField.text != checkPasswordTextField.text {
            self.passwordErrorUI()
            conditionsLabel.isHidden = true
            return
        }

        if !isValidPassword {
            self.passwordWrongRegularExpressionUI()
            return
        }

        let alert = UIAlertController(
            title: "재설정 완료",
            message: "비밀번호가 재설정되었습니다.",
            preferredStyle: .alert
        )

        let done = UIAlertAction(title: "완료", style: .default) { _ in
            let introVC = IntroViewController()
            let nav = UINavigationController(rootViewController: introVC)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController = nav
                window.makeKeyAndVisible()
            }
        }

        alert.addAction(done)
        self.present(alert, animated: true)
    }

    @objc private func validatePassword() -> Bool {
        guard let password = passwordTextField.text else { return false }
        
        let regexPattern = "^(?=.*[a-z])(?=.*\\d)(?=.*[\\W_])[A-Za-z\\d\\W_]{6,16}$"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", regexPattern)
        let isValid = passwordTest.evaluate(with: password)
        
        if isValid {
            print("정규식에 알맞는 비밀번호입니다.")
        } else {
            print("정규식에 맞지 않는 비밀번호입니다.")
        }
        return isValid
    }
    
    func passwordErrorUI() {
        checkPasswordTextField.setPlaceholderColor(.color.gomsNegative.color)
        passwordErrorLabel.isHidden = false
        checkPasswordTextField.layer.borderColor = UIColor.systemRed.cgColor
        checkPasswordTextField.layer.borderWidth = 1
        
        passwordOverlapErrorLabel.isHidden = true
        passwordWrongRegularExpression.isHidden = true
        passwordTextField.layer.borderWidth = 0
        passwordTextField.setPlaceholderColor(.color.sub2.color)
    }
    
    func passwordOverlapErrorUI() {
        passwordTextField.setPlaceholderColor(.color.gomsNegative.color)
        passwordOverlapErrorLabel.isHidden = false
        passwordTextField.layer.borderColor = UIColor.systemRed.cgColor
        passwordTextField.layer.borderWidth = 1
        
        passwordWrongRegularExpression.isHidden = true
        passwordErrorLabel.isHidden = true
        checkPasswordTextField.layer.borderWidth = 0
        checkPasswordTextField.setPlaceholderColor(.color.sub2.color)
    }
    
    func passwordWrongRegularExpressionUI() {
        passwordTextField.setPlaceholderColor(.color.gomsNegative.color)
        passwordWrongRegularExpression.isHidden = false
        passwordTextField.layer.borderColor = UIColor.systemRed.cgColor
        passwordTextField.layer.borderWidth = 1
        
        passwordOverlapErrorLabel.isHidden = true
        passwordErrorLabel.isHidden = true
        checkPasswordTextField.layer.borderWidth = 0
        checkPasswordTextField.setPlaceholderColor(.color.sub2.color)
    }
    
    @objc func onPasswordButtonTapped() {
        passwordTextField.isSecureTextEntry.toggle()
        onPasswordButton.isSelected.toggle()
        
        if onPasswordButton.isSelected {
            onPasswordButton.setImage(.image.off.image.withRenderingMode(.alwaysTemplate), for: .normal)
        } else {
            onPasswordButton.setImage(.image.on.image.withRenderingMode(.alwaysTemplate), for: .normal)
        }
        
        onPasswordButton.tintColor = .color.sub2.color
    }
    
    @objc public override func keyboardWillShow(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
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

    @objc public override func keyboardWillHide(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }

        doneButton.snp.updateConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
        }

        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    func passswordError() {
        passwordTextField.setBorderColorMode(lightModeColor: .color.gomsNegative.color, darkModeColor: .color.gomsNegative.color)
        passwordTextField.setPlaceholderColor(.color.gomsNegative.color)
        passwordErrorLabel.isHidden = false
    }

    // MARK: - Navigation
    public override func configNavigation() {
        super.configNavigation()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "비밀번호 재설정"
    }
    
    // MARK: - Add View
    public override func addView() {
     
        [passwordTextField, checkPasswordTextField].forEach {
            textFieldStackView.addArrangedSubview($0)
        }

        [navigationTitle, textFieldStackView, conditionsLabel, doneButton, passwordErrorLabel, passwordOverlapErrorLabel, passwordWrongRegularExpression].forEach {
            view.addSubview($0)
        }
    }
    
    // MARK: - Layout
    public override func setLayout() {
        navigationTitle.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.top.equalToSuperview().inset(100)
            $0.leading.equalToSuperview().inset(bounds.width * 0.05)
            $0.trailing.lessThanOrEqualToSuperview().inset(24)
        }
        
        passwordTextField.snp.makeConstraints {
            $0.height.equalTo(56)
        }
        
        checkPasswordTextField.snp.makeConstraints {
            $0.height.equalTo(56)
        }
        
        passwordErrorLabel.snp.makeConstraints {
            $0.trailing.equalTo(checkPasswordTextField.snp.trailing)
            $0.height.equalTo(48)
            $0.top.equalTo(checkPasswordTextField.snp.bottom).inset(5)
            $0.trailing.equalTo(-bounds.width * 0.07)
        }
        
        passwordOverlapErrorLabel.snp.makeConstraints {
            $0.trailing.equalTo(checkPasswordTextField.snp.trailing)
            $0.height.equalTo(48)
            $0.top.equalTo(passwordTextField.snp.bottom).inset(5)
            $0.trailing.equalTo(-bounds.width * 0.07)
        }
        
        passwordWrongRegularExpression.snp.makeConstraints {
            $0.trailing.equalTo(checkPasswordTextField.snp.trailing)
            $0.height.equalTo(48)
            $0.top.equalTo(passwordTextField.snp.bottom).inset(5)
            $0.trailing.equalTo(-bounds.width * 0.07)
        }

        
        textFieldStackView.snp.makeConstraints {
            $0.leading.equalTo(bounds.width * 0.05)
            $0.trailing.equalTo(-bounds.width * 0.05)
            $0.top.equalTo(navigationTitle.snp.bottom).offset(32)
        }
        
        conditionsLabel.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.top.equalTo(textFieldStackView.snp.bottom)
            $0.leading.equalTo(bounds.width * 0.07)
        }
        
        doneButton.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(24)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).offset(-24)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
        }
    }
}

// MARK: - Extension
extension ChangNewPasswordViewController: UITextFieldDelegate {
    public func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == passwordTextField {
            viewModel.setupNewPassword(newPassword: passwordTextField.text ?? "", checkPassword: checkPasswordTextField.text ?? "")
        }
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text ?? "") as NSString
        let updatedText = currentText.replacingCharacters(in: range, with: string)
        
        if updatedText.rangeOfCharacter(from: .whitespaces) != nil { return false }
        
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
