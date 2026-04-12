//
//  ChangNewPasswordViewController.swift
//  Feature
//
//  Created by 김준표 on 2/25/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit

public final class ChangNewPasswordViewController: BaseViewController {
    
    private var viewModel = AuthViewModel()
    var email: String = ""
    var verifiedToken: String = ""

    // MARK: - UI Components
    
    private let textFieldStackView = UIStackView().then {
        $0.spacing = 16
        $0.axis = .vertical
        $0.distribution = .fill
        $0.alignment = .fill
    }
    
    let navigationTitle = UILabel().then {
        $0.text = "비밀번호 재설정"
        $0.textColor = .color.mainText.color
        $0.font = .suit(size: 29, weight: .bold)
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
    
    lazy var passwordTextField = GOMSTextField(frame: .zero, placeholder: "비밀번호").then {
        $0.isSecureTextEntry = true
        $0.rightView = onPasswordButton
        $0.rightViewMode = .always
    }
    
    lazy var onPasswordButton = UIButton().then {
        $0.setImage(.image.on.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = .color.sub2.color
        $0.addTarget(self, action: #selector(onPasswordButtonTapped), for: .touchUpInside)
    }
    
    private let checkPasswordTextField = GOMSTextField(frame: .zero, placeholder: "비밀번호 확인").then {
        $0.isSecureTextEntry = true
    }
    
    private let conditionsLabel = UILabel().then {
        $0.text = "대/소문자, 숫자, 특수문자 포함 6~16자"
        $0.font = .suit(size: 15, weight: .regular)
        $0.textColor = .color.sub2.color
    }
    
    lazy var doneButton = GOMSButton(frame: .zero, title: "완료").then {
        $0.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
    }

    // MARK: - LifeCycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        if verifiedToken.isEmpty {
            verifiedToken = UserDefaults.standard.string(forKey: "verifiedToken") ?? ""
        }
        
        passwordTextField.delegate = self
        checkPasswordTextField.delegate = self
        
        addView()
        setLayout()
    }

    // MARK: - Actions
    
    @objc func doneButtonTapped() {

        // 비밀번호 불일치
        if passwordTextField.text != checkPasswordTextField.text {
            passwordErrorUI()
            return
        }

        // 정규식 검증 실패
        if !validatePassword() {
            passwordWrongRegularExpressionUI()
            return
        }

        guard let password = passwordTextField.text else { return }

        let token = verifiedToken.isEmpty
            ? UserDefaults.standard.string(forKey: "verifiedToken") ?? ""
            : verifiedToken

        guard !token.isEmpty else {
            let alert = UIAlertController(
                title: "오류",
                message: "인증 정보가 없어 비밀번호를 재설정할 수 없습니다.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "확인", style: .cancel))
            self.present(alert, animated: true)
            return
        }

        viewModel.setupEmail(email: email)
        viewModel.setupPassword(password: password)
        viewModel.setupVerifiedToken(verifiedToken: token)

        viewModel.resetPassword { [weak self] success, statusCode in
            guard let self = self else { return }

            DispatchQueue.main.async {
                if success {
                    let alert = UIAlertController(
                        title: "재설정 완료",
                        message: "비밀번호가 재설정되었습니다.",
                        preferredStyle: .alert
                    )

                    alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
                        UserDefaults.standard.removeObject(forKey: "verifiedToken")

                        let introViewController = IntroViewController()
                        let nav = UINavigationController(rootViewController: introViewController)

                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = windowScene.windows.first {
                            window.rootViewController = nav
                            window.makeKeyAndVisible()
                        }
                    })

                    self.present(alert, animated: true)
                } else {
                    let alert = UIAlertController(
                        title: "오류",
                        message: "비밀번호 재설정에 실패했습니다.",
                        preferredStyle: .alert
                    )

                    alert.addAction(UIAlertAction(title: "확인", style: .cancel))
                    self.present(alert, animated: true)
                }
            }
        }
    }

    // MARK: - Validation
    
    private func validatePassword() -> Bool {
        guard let password = passwordTextField.text else { return false }
        
        let regex = "^(?=.*[a-z])(?=.*\\d)(?=.*[\\W_]).{6,16}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: password)
    }

    // MARK: - UI State
    
    func passwordErrorUI() {
        passwordErrorLabel.isHidden = false
        passwordWrongRegularExpression.isHidden = true
        
        checkPasswordTextField.layer.borderWidth = 1
        checkPasswordTextField.layer.borderColor = UIColor.systemRed.cgColor
    }

    func passwordWrongRegularExpressionUI() {
        passwordWrongRegularExpression.isHidden = false
        passwordErrorLabel.isHidden = true
        
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.borderColor = UIColor.systemRed.cgColor
    }

    @objc func onPasswordButtonTapped() {
        passwordTextField.isSecureTextEntry.toggle()
        
        let image = passwordTextField.isSecureTextEntry
            ? UIImage.image.on.image
            : UIImage.image.off.image

        onPasswordButton.setImage(
            image.withRenderingMode(.alwaysTemplate),
            for: .normal
        )
    }

    // MARK: - Layout
    
    public override func addView() {

        textFieldStackView.addArrangedSubview(passwordTextField)
        textFieldStackView.addArrangedSubview(passwordWrongRegularExpression)
        textFieldStackView.addArrangedSubview(checkPasswordTextField)
        textFieldStackView.addArrangedSubview(passwordErrorLabel)

        [
            navigationTitle,
            textFieldStackView,
            conditionsLabel,
            doneButton
        ].forEach {
            view.addSubview($0)
        }
    }

    public override func setLayout() {
        
        navigationTitle.snp.makeConstraints {
            $0.top.equalToSuperview().offset(124)
            $0.leading.equalToSuperview().inset(20)
        }

        passwordTextField.snp.makeConstraints { $0.height.equalTo(56) }
        checkPasswordTextField.snp.makeConstraints { $0.height.equalTo(56) }

        textFieldStackView.snp.makeConstraints {
            $0.top.equalTo(navigationTitle.snp.bottom).offset(24)
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.equalToSuperview().inset(20)
        }

        conditionsLabel.snp.makeConstraints {
            $0.top.equalTo(textFieldStackView.snp.bottom).offset(12)
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.equalToSuperview().inset(20)
        }

        doneButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
            $0.leading.equalTo(view.safeAreaLayoutGuide).inset(24)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(24)
            $0.height.equalTo(48)
        }
    }
}

// MARK: - UITextFieldDelegate

extension ChangNewPasswordViewController: UITextFieldDelegate {

    public func textFieldDidChangeSelection(_ textField: UITextField) {
       
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
        } else {
            checkPasswordTextField.becomeFirstResponder()
        }
        return true
    }
}
