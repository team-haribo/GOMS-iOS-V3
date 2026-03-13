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

        authCodeButton.isEnabled = shouldEnableAuthCodeButton()
    }

    @objc private func genderButtonTapped() {
        view.endEditing(true)

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let menAction = UIAlertAction(title: "남성", style: .default) { _ in
            self.genderTextField.setTitle("남성", for: .normal)
            self.genderTextField.setTitleColor(.color.mainText.color, for: .normal)
            self.viewModel.setupGender(gender: Gender.man.rawValue)
            self.authCodeButton.isEnabled = self.shouldEnableAuthCodeButton()
        }

        let womanAction = UIAlertAction(title: "여성", style: .default) { _ in
            self.genderTextField.setTitle("여성", for: .normal)
            self.genderTextField.setTitleColor(.color.mainText.color, for: .normal)
            self.viewModel.setupGender(gender: Gender.man.rawValue)
            self.authCodeButton.isEnabled = self.shouldEnableAuthCodeButton()
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
            self.authCodeButton.isEnabled = self.shouldEnableAuthCodeButton()
        }

        let iotAction = UIAlertAction(title: "스마트IoT과", style: .default) { _ in
            self.majorTextField.setTitle("스마트IoT과", for: .normal)
            self.majorTextField.setTitleColor(.color.mainText.color, for: .normal)
            self.viewModel.setupMajor(major: Major.iot.rawValue)
            self.authCodeButton.isEnabled = self.shouldEnableAuthCodeButton()
        }

        let aiAction = UIAlertAction(title: "AI개발과", style: .default) { _ in
            self.majorTextField.setTitle("AI개발과", for: .normal)
            self.majorTextField.setTitleColor(.color.mainText.color, for: .normal)
            self.viewModel.setupMajor(major: Major.ai.rawValue)
            self.authCodeButton.isEnabled = self.shouldEnableAuthCodeButton()
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

        DispatchQueue.main.async {
            self.present(self.loader, animated: true)
        }

        viewModel.setupEmail(email: emailTextField.text ?? "")
        viewModel.setupName(name: nameTextField.text ?? "")
        viewModel.setupEmailStatus(emailStatus: "BEFORE_SIGNUP")

        viewModel.sendAuthCode { [weak self] success, statusCode in
            guard let self = self else { return }

            DispatchQueue.main.async {

                if success {
                    switch statusCode {
                    case 200:
                        let authCodeVC = AuthCodeViewController(
                            viewModel: self.viewModel,
                            previousViewController: self,
                            email: self.emailTextField.text ?? ""
                        )
                        self.navigationController?.pushViewController(authCodeVC, animated: true)
                        self.loader.dismiss(animated: true)

                    default:
                        let alert = UIAlertController(title: "서버오류",
                                                      message: "GOMS 서버  운영팀에게 문의주세요.",
                                                      preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "확인", style: .cancel))
                        self.present(alert, animated: true)
                        self.loader.dismiss(animated: true)
                    }
                } else {
                    switch statusCode {
                    case 429:
                        let alert = UIAlertController(
                            title: "이메일 요청 초과",
                            message: "이메일 요청 한도인 5번을 초과했습니다.\n5분 후에 재시도해 주세요.",
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(title: "확인", style: .cancel))
                        self.present(alert, animated: true)
                        self.loader.dismiss(animated: true)

                    default:
                        let alert = UIAlertController(
                            title: "인증코드 발송 실패",
                            message: "인증코드 발송에 실패했습니다.\n다시 시도해 주세요.",
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(title: "확인", style: .cancel))
                        self.present(alert, animated: true)
                        self.loader.dismiss(animated: true)
                    }
                }
            }
        }
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

    private func shouldEnableAuthCodeButton() -> Bool {
        let nameValid = !(nameTextField.text ?? "").isEmpty
        let emailValid = (emailTextField.text ?? "").count == 6
        let majorValid = ["SW개발과", "스마트IoT과", "AI개발과"]
            .contains(majorTextField.title(for: .normal) ?? "")
        let genderValid = ["남성", "여성"]
            .contains(genderTextField.title(for: .normal) ?? "")

        return nameValid && emailValid && majorValid && genderValid
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

        authCodeButton.isEnabled = shouldEnableAuthCodeButton()
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
