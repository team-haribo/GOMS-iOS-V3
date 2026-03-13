//
//  WithdrawalViewController.swift
//  Feature
//
//  Created by 김준표 on 2/25/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit

public class WithdrawalViewController: BaseViewController {

    // MARK: - Properties
    private let viewModel = ProfileViewModel()
    
    let navigationTitle = UILabel().then {
        $0.text = "회원탈퇴"
        $0.textColor = .color.mainText.color
        $0.font = .suit(size: 29, weight: .bold)
    }
    
    let passwordTextField = GOMSTextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0), placeholder: "비밀번호").then {
        $0.isSecureTextEntry = true
    }
    
    lazy var onPasswordButton = UIButton().then {
        $0.setImage(.image.on.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = .color.sub2.color
        $0.adjustsImageWhenHighlighted = false
        $0.addTarget(self, action: #selector(onPasswordButtonTapped), for: .touchUpInside)
    }
    
    private lazy var withdrawalButton = GOMSButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0), title: "회원 탈퇴하기").then {
        $0.addTarget(self, action: #selector(withdrawalButtonTapped), for: .touchUpInside)
    }
    
    
    let passwordErrorLabel = UILabel().then {
        $0.text = "잘못된 비밀번호입니다."
        $0.textColor = .color.gomsNegative.color
        $0.font = .suit(size: 16, weight: .medium)
        $0.textAlignment = .right
        $0.isHidden = true
    }
    
    // MARK: - Life Cycel
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordTextField.delegate = self
        passwordTextField.rightView = onPasswordButton
        passwordTextField.rightViewMode = .always
    }
    
    // MARK: - Selectors
    @objc func withdrawalButtonTapped() {
        let inputPassword = passwordTextField.text ?? ""

        if inputPassword == "1234" {
            passwordErrorLabel.isHidden = true
            passwordTextField.layer.borderWidth = 0
            passwordTextField.setPlaceholderColor(.color.sub2.color)

            let alert = UIAlertController(title: "회원 탈퇴 완료", message: "그동안 GOMS를 이용해주셔서 감사합니다.\n안녕히 가세요!", preferredStyle: .alert)

            let ok = UIAlertAction(title: "완료", style: .default) { _ in
                let introVC = IntroViewController()
                let nav = UINavigationController(rootViewController: introVC)

                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = scene.windows.first {
                    window.rootViewController = nav
                    window.makeKeyAndVisible()
                }
            }
            alert.addAction(ok)
            self.present(alert, animated: true)
        } else {
            print("탈퇴하기 실패")
            self.passwordErrorUI()
        }
    }
    
    func passwordErrorUI() {
        passwordTextField.setPlaceholderColor(.color.gomsNegative.color)
        passwordErrorLabel.isHidden = false
        passwordTextField.layer.borderColor = UIColor.systemRed.cgColor
        passwordTextField.layer.borderWidth = 1
    }
    
    @objc func onPasswordButtonTapped() {
        passwordTextField.isSecureTextEntry.toggle()
        passwordTextField.isSelected.toggle()
        
        if passwordTextField.isSelected {
            onPasswordButton.setImage(.image.off.image.withRenderingMode(.alwaysTemplate), for: .normal)
        } else {
            onPasswordButton.setImage(.image.on.image.withRenderingMode(.alwaysTemplate), for: .normal)
        }
    }
    
    @objc public override func keyboardWillShow(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }

        let keyboardHeight = keyboardFrame.height - view.safeAreaInsets.bottom

        withdrawalButton.snp.updateConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-(keyboardHeight + 24))
        }

        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }

    public override func keyboardWillHide(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }

        withdrawalButton.snp.updateConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
        }

        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Configure Navigation
    public override func configNavigation() {
        super.configNavigation()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .color.admin.color
        navigationItem.title = "회원탈퇴"
    }
    
    // MARK: - Add View
    public override func addView() {
        [
            navigationTitle,
            passwordTextField,
            withdrawalButton,
            passwordErrorLabel
        ].forEach {
            view.addSubview($0)
        }
    }
    
    // MARK: - Layout
    public override func setLayout() {

        navigationTitle.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.width.equalTo(183)
            $0.top.equalToSuperview().inset(100)
            $0.leading.equalToSuperview().inset(bounds.width * 0.05)
        }

        passwordTextField.snp.makeConstraints {
            $0.height.equalTo(64)
            $0.width.equalTo(335)
            $0.bottom.equalTo(navigationTitle.snp.bottom).offset(90)
            $0.leading.equalToSuperview().inset(bounds.width * 0.05)
            $0.trailing.equalToSuperview().inset(bounds.width * 0.05)
        }

        passwordErrorLabel.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.top.equalTo(passwordTextField.snp.bottom)
            $0.leading.equalTo(bounds.width * 0.07)
            $0.trailing.equalTo(-bounds.width * 0.07)
        }


        withdrawalButton.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(24)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).offset(-24)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
        }
    }
}

// MARK: - Extension
extension WithdrawalViewController: UITextFieldDelegate {
    public func textFieldDidChange(_ textField: UITextField) {
        if textField == passwordTextField {
            viewModel.setupPassword(password: textField.text ?? "")
        }
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text ?? "") as NSString
        let updatedText = currentText.replacingCharacters(in: range, with: string)
        
        if updatedText.rangeOfCharacter(from: .whitespaces) != nil { return false }
        
        return true
    }
}
