//
//  ProfileChangRePasswordViewController.swift
//  Feature
//
//  Created by 김준표 on 2/25/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import Combine
import Moya
import SnapKit
import Service

public class ProfileChangRePasswordViewController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private let viewModel = ProfileViewModel()
    
    let navigationTitle = UILabel().then {
        $0.text = "비밀번호 재설정"
        $0.textColor = .color.mainText.color
        $0.font = .suit(size: 29, weight: .bold)
    }
    
    let passwordErrorLabel = UILabel().then {
        $0.text = "잘못된 비밀번호입니다."
        $0.textColor = .color.gomsNegative.color
        $0.font = .suit(size: 16, weight: .medium)
        $0.isHidden = true
    }
    
    lazy var passwordTextField = GOMSTextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0), placeholder: "현재 비밀번호").then {
        $0.isSecureTextEntry = true
        $0.rightView = visiblePasswordButton
        $0.rightViewMode = .always
    }
    
    lazy var visiblePasswordButton = UIButton().then {
        $0.setImage(.image.on.image, for: .normal)
        $0.addTarget(self, action: #selector(visiblePasswordButtonTapped), for: .touchUpInside)
        $0.isEnabled = true
    }
    
    private lazy var doneButton = GOMSButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0), title: "다음으로").then {
        $0.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
    }
    
    private var doneButtonBottomConstraint: Constraint?
    private var textFieldBottomConstraint: Constraint?
    
    @objc func doneButtonTapped() {
        let defaults = UserDefaults.standard
        let localPassword = defaults.string(forKey: "localPass")
        if localPassword == passwordTextField.text {
            let newPasswordVC = ChangNewPasswordViewController()
            navigationController?.pushViewController(newPasswordVC, animated: true)
        } else {
            print("비밀번호가 틀렸습니다.")
            self.passwordErrorUI()
        }
    }
    
    func passwordErrorUI() {
        passwordTextField.setPlaceholderColor(.color.gomsNegative.color)
        passwordErrorLabel.isHidden = false
        passwordTextField.layer.borderColor = UIColor.systemRed.cgColor
        passwordTextField.layer.borderWidth = 1
    }
    
    @objc func visiblePasswordButtonTapped() {
        passwordTextField.isSecureTextEntry.toggle()
        passwordTextField.isSelected.toggle()
        
        if passwordTextField.isSelected {
            visiblePasswordButton.setImage(.image.off.image, for: .normal)
        } else {
            visiblePasswordButton.setImage(.image.on.image, for: .normal)
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordTextField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    public override func configNavigation() {
        navigationController?.navigationBar.tintColor = .color.admin.color
    }
    
    public override func addView() {
        [
            navigationTitle,
            passwordTextField,
            doneButton,
            passwordErrorLabel
        ].forEach {
            view.addSubview($0)
        }
    }
    
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
        }
        
        doneButton.snp.makeConstraints {
            doneButtonBottomConstraint = $0.bottom.equalToSuperview().inset(bounds.height * 0.19).constraint
            $0.height.equalTo(48)
            $0.width.equalTo(335)
            $0.leading.equalToSuperview().inset(bounds.width * 0.05)
            $0.trailing.equalToSuperview().inset(bounds.width * 0.05)
        }
    }
    
    public override func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        let keyboardHeight = keyboardFrame.height
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.doneButtonBottomConstraint?.update(inset: keyboardHeight + 13)
            self.textFieldBottomConstraint?.update(inset: keyboardHeight + (self.bounds.height * 0.2))
            
            self.view.layoutIfNeeded()
        }
    }
    
    public override func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.doneButtonBottomConstraint?.update(inset: self.bounds.height * 0.19)
            self.textFieldBottomConstraint?.update(inset: self.bounds.height * 0.45)
            
            self.view.layoutIfNeeded()
        }
    }
}

extension ProfileChangRePasswordViewController: UITextFieldDelegate {
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text ?? "") as NSString
        let updatedText = currentText.replacingCharacters(in: range, with: string)
        
        if updatedText.rangeOfCharacter(from: .whitespaces) != nil { return false }
        
        return true
    }
}


