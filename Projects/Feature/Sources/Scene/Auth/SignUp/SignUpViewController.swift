//
//  SignUpViewController.swift
//  Feature
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit

public final class SignUpViewController: BaseViewController {

    private let viewModel = AuthViewModel()
    private let loader = LoaderViewController()

    private let pageTitleLabel = UILabel().then {
        $0.text = "회원가입"
        $0.font = .suit(size: 28, weight: .bold)
        $0.textColor = .color.mainText.color
    }

    private lazy var textFieldStackView = UIStackView().then {
        $0.spacing = 16
        $0.axis = .vertical
        $0.distribution = .fillEqually
        $0.alignment = .fill
    }

    let nameTextField = GOMSTextField(frame: .zero, placeholder: "이름을 입력해주세요")

    private let emailTextField = GOMSTextField(frame: .zero, placeholder: "이메일을 입력해주세요")

    private let defaultDomain = UILabel().then {
        $0.text = "@gsm.hs.kr"
        $0.font = .suit(size: 16, weight: .medium)
        $0.textColor = .color.sub2.color
    }

    let noneInputError = UILabel().then {
        $0.text = "입력되지 않았습니다."
        $0.textColor = .color.gomsNegative.color
        $0.font = .suit(size: 16, weight: .medium)
        $0.isHidden = true
    }

    private let nameErrorLabel = UILabel().then {
        $0.text = "이름을 입력해주세요."
        $0.textColor = .color.gomsNegative.color
        $0.font = .suit(size: 15, weight: .medium)
        $0.textAlignment = .right
        $0.isHidden = true
    }

    private let emailErrorLabel = UILabel().then {
        $0.text = "올바른 이메일 형식이 아닙니다."
        $0.textColor = .color.gomsNegative.color
        $0.font = .suit(size: 15, weight: .medium)
        $0.textAlignment = .right
        $0.isHidden = true
    }

    lazy var genderTextField = GOMSTextFieldButton(frame: .zero, title: "성별").then {
        $0.addTarget(self, action: #selector(genderButtonTapped), for: .touchUpInside)
    }

    lazy var majorTextField = GOMSTextFieldButton(frame: .zero, title: "과").then {
        $0.addTarget(self, action: #selector(departmentButtonTapped), for: .touchUpInside)
    }

    private lazy var authCodeButton = GOMSButton(frame: .zero, title: "인증번호 받기").then {
        $0.addTarget(self, action: #selector(authCodeButtonTapped), for: .touchUpInside)
        $0.isEnabled = false
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)

        nameTextField.delegate = self
        emailTextField.delegate = self
        nameTextField.addTarget(self, action: #selector(nameEditingChanged(_:)), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(emailEditingChanged(_:)), for: .editingChanged)

        authCodeButton.isEnabled = true
    }

    @objc private func genderButtonTapped() {
        view.endEditing(true)

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let menAction = UIAlertAction(title: "남성", style: .default) { _ in
            self.genderTextField.setTitle("남성", for: .normal)
            self.genderTextField.setTitleColor(.color.mainText.color, for: .normal)
            self.viewModel.setupGender(gender: Gender.man.rawValue)
            self.genderTextField.layer.borderWidth = 0
            self.genderTextField.layer.borderColor = UIColor.clear.cgColor
        }

        let womanAction = UIAlertAction(title: "여성", style: .default) { _ in
            self.genderTextField.setTitle("여성", for: .normal)
            self.genderTextField.setTitleColor(.color.mainText.color, for: .normal)
            self.viewModel.setupGender(gender: Gender.man.rawValue)
            self.genderTextField.layer.borderWidth = 0
            self.genderTextField.layer.borderColor = UIColor.clear.cgColor
        }

        [menAction, womanAction].forEach { alert.addAction($0) }
        present(alert, animated: true)
    }

    @objc private func departmentButtonTapped() {
        view.endEditing(true)

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let swAction = UIAlertAction(title: "SW개발과", style: .default) { _ in
            self.majorTextField.setTitle("SW개발과", for: .normal)
            self.majorTextField.setTitleColor(.color.mainText.color, for: .normal)
            self.viewModel.setupMajor(major: Major.sw.rawValue)
            self.majorTextField.layer.borderWidth = 0
            self.majorTextField.layer.borderColor = UIColor.clear.cgColor
        }

        let iotAction = UIAlertAction(title: "스마트IoT과", style: .default) { _ in
            self.majorTextField.setTitle("스마트IoT과", for: .normal)
            self.majorTextField.setTitleColor(.color.mainText.color, for: .normal)
            self.viewModel.setupMajor(major: Major.iot.rawValue)
            self.majorTextField.layer.borderWidth = 0
            self.majorTextField.layer.borderColor = UIColor.clear.cgColor
        }

        let aiAction = UIAlertAction(title: "AI개발과", style: .default) { _ in
            self.majorTextField.setTitle("AI개발과", for: .normal)
            self.majorTextField.setTitleColor(.color.mainText.color, for: .normal)
            self.viewModel.setupMajor(major: Major.ai.rawValue)
            self.majorTextField.layer.borderWidth = 0
            self.majorTextField.layer.borderColor = UIColor.clear.cgColor
        }

        [swAction, iotAction, aiAction].forEach { alert.addAction($0) }
        present(alert, animated: true)
    }

    @objc private func authCodeButtonTapped() {
        let name = nameTextField.text ?? ""
        let email = emailTextField.text ?? ""

        nameErrorLabel.isHidden = true
        emailErrorLabel.isHidden = true

        nameErrorLabel.snp.updateConstraints { $0.height.equalTo(0) }
        emailErrorLabel.snp.updateConstraints { $0.height.equalTo(0) }

        if name.isEmpty {
            nameErrorLabel.isHidden = false
            nameErrorLabel.text = "이름을 입력해주세요."
            nameErrorLabel.snp.updateConstraints { $0.height.equalTo(19) }

            nameTextField.layer.borderWidth = 1
            nameTextField.layer.borderColor = UIColor.color.gomsNegative.color.cgColor
            nameTextField.attributedPlaceholder = NSAttributedString(
                string: "이름을 입력해주세요",
                attributes: [
                    .foregroundColor: UIColor.color.gomsNegative.color
                ]
            )

            view.layoutIfNeeded()
            return
        }

        if email.isEmpty {
            emailErrorLabel.isHidden = false
            emailErrorLabel.text = "이메일을 입력해주세요."
            emailErrorLabel.snp.updateConstraints { $0.height.equalTo(19) }

            emailTextField.layer.borderWidth = 1
            emailTextField.layer.borderColor = UIColor.color.gomsNegative.color.cgColor
            emailTextField.attributedPlaceholder = NSAttributedString(
                string: "이메일을 입력해주세요",
                attributes: [
                    .foregroundColor: UIColor.color.gomsNegative.color
                ]
            )

            view.layoutIfNeeded()
            return
        }

        let emailRegex = "^s[0-9]{5}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)

        if !emailPredicate.evaluate(with: email) {
            emailErrorLabel.isHidden = false
            emailErrorLabel.text = "올바른 이메일 형식이 아닙니다."
            emailErrorLabel.snp.updateConstraints { $0.height.equalTo(19) }
            view.layoutIfNeeded()
            return
        }

        
        let gender = genderTextField.title(for: .normal) ?? ""
        let major = majorTextField.title(for: .normal) ?? ""

        if gender == "성별" {
            genderTextField.layer.borderWidth = 1
            genderTextField.layer.borderColor = UIColor.color.gomsNegative.color.cgColor
            return
        }

        if major == "과" {
            majorTextField.layer.borderWidth = 1
            majorTextField.layer.borderColor = UIColor.color.gomsNegative.color.cgColor
            return
        }

        let authCodeVC = AuthCodeViewController(
            viewModel: self.viewModel,
            previousViewController: self,
            email: email
        )

        self.navigationController?.pushViewController(authCodeVC, animated: true)
    }



    public override func addView() {
        emailTextField.addSubview(defaultDomain)

        [pageTitleLabel,
         nameTextField,
         nameErrorLabel,
         emailTextField,
         emailErrorLabel,
         genderTextField,
         majorTextField,
         authCodeButton]
            .forEach { view.addSubview($0) }
    }

    public override func setLayout() {

        pageTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(124)
            $0.leading.equalTo(20)
        }

        nameTextField.snp.makeConstraints {
            $0.leading.equalTo(bounds.width * 0.05)
            $0.trailing.equalTo(-bounds.width * 0.05)
            $0.top.equalTo(pageTitleLabel.snp.bottom).offset(24)
            $0.height.equalTo(56)
        }

        nameErrorLabel.snp.makeConstraints {
            $0.trailing.equalTo(nameTextField.snp.trailing)
            $0.top.equalTo(nameTextField.snp.bottom).offset(8)
            $0.height.equalTo(0)
        }

        emailTextField.snp.makeConstraints {
            $0.leading.equalTo(bounds.width * 0.05)
            $0.trailing.equalTo(-bounds.width * 0.05)
            $0.top.equalTo(nameErrorLabel.snp.bottom).offset(16)
            $0.height.equalTo(56)
        }

        emailErrorLabel.snp.makeConstraints {
            $0.trailing.equalTo(emailTextField.snp.trailing)
            $0.top.equalTo(emailTextField.snp.bottom).offset(8)
            $0.height.equalTo(0)
        }

        genderTextField.snp.makeConstraints {
            $0.leading.equalTo(bounds.width * 0.05)
            $0.trailing.equalTo(-bounds.width * 0.05)
            $0.top.equalTo(emailErrorLabel.snp.bottom).offset(16)
            $0.height.equalTo(56)
        }

        majorTextField.snp.makeConstraints {
            $0.leading.equalTo(bounds.width * 0.05)
            $0.trailing.equalTo(-bounds.width * 0.05)
            $0.top.equalTo(genderTextField.snp.bottom).offset(16)
            $0.height.equalTo(56)
        }

        defaultDomain.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(28)
            $0.centerY.equalToSuperview()
        }

        authCodeButton.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(24)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).offset(-24)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
        }
    }

    @objc private func nameEditingChanged(_ textField: UITextField) {
        let name = textField.text ?? ""

        nameTextField.layer.borderWidth = 0
        nameTextField.layer.borderColor = UIColor.clear.cgColor
        nameTextField.attributedPlaceholder = NSAttributedString(
            string: "이름을 입력해주세요",
            attributes: [
                .foregroundColor: UIColor.color.sub2.color
            ]
        )

        if name.isEmpty {
            nameErrorLabel.isHidden = true
            nameErrorLabel.snp.updateConstraints { $0.height.equalTo(0) }
        } else {
            nameErrorLabel.isHidden = true
            nameErrorLabel.snp.updateConstraints { $0.height.equalTo(0) }
        }

        viewModel.setupName(name: name)
        view.layoutIfNeeded()
    }

    @objc private func emailEditingChanged(_ textField: UITextField) {
        let email = textField.text ?? ""

        emailTextField.layer.borderWidth = 0
        emailTextField.layer.borderColor = UIColor.clear.cgColor
        emailTextField.attributedPlaceholder = NSAttributedString(
            string: "이메일을 입력해주세요",
            attributes: [
                .foregroundColor: UIColor.color.sub2.color
            ]
        )

        let emailRegex = "^s[0-9]{5}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)

        if email.isEmpty {
            emailErrorLabel.isHidden = true
            emailErrorLabel.snp.updateConstraints { $0.height.equalTo(0) }
        } else if !emailPredicate.evaluate(with: email) {
            emailErrorLabel.isHidden = false
            emailErrorLabel.text = "올바른 이메일 형식이 아닙니다."
            emailErrorLabel.snp.updateConstraints { $0.height.equalTo(19) }
        } else {
            emailErrorLabel.isHidden = true
            emailErrorLabel.snp.updateConstraints { $0.height.equalTo(0) }
        }

        viewModel.setupEmail(email: email)
        view.layoutIfNeeded()
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
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
}

extension SignUpViewController: UITextFieldDelegate {

    public func textFieldDidChange(_ textField: UITextField) {

        if textField == nameTextField {
            viewModel.setupName(name: nameTextField.text ?? "")
        } else if textField == emailTextField {
            viewModel.setupEmail(email: emailTextField.text ?? "")
        }
    }

    public func textField(_ textField: UITextField,
                          shouldChangeCharactersIn range: NSRange,
                          replacementString string: String) -> Bool {

        if textField == emailTextField {
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            return updatedText.count <= 6
        }

        return true
    }
}
