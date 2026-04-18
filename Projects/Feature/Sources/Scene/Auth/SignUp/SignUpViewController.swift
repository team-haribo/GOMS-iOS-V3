//
//  SignUpViewController.swift
//  Feature
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import Service
import SnapKit
import Then

public final class SignUpViewController: BaseViewController {

    private let viewModel = AuthViewModel()
    private let loader = LoaderViewController()

    // MARK: - UI Components
    
    private lazy var customBackButton = UIButton().then {
        let backImage = UIImage(named: "Back", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        $0.setImage(backImage, for: .normal)
        $0.setTitle(" 돌아가기", for: .normal)
        $0.setTitleColor(.color.gomsPrimary.color, for: .normal)
        $0.tintColor = .color.gomsPrimary.color
        $0.titleLabel?.font = .suit(size: 18, weight: .medium)
        $0.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }

    private let pageTitleLabel = UILabel().then {
        $0.text = "회원가입 하기"
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
    
    private let privacyCheckbox = UIButton().then {
        $0.setImage(UIImage(systemName: "square"), for: .normal)
        $0.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        $0.tintColor = .color.sub2.color
        $0.addTarget(self, action: #selector(privacyCheckboxTapped), for: .touchUpInside)
    }

    private let privacyLabel = UILabel().then {
        $0.text = "개인정보 수집 및 처리방침"
        $0.font = .suit(size: 15, weight: .semibold )
        $0.textColor = .color.gomsPrimary.color
        $0.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(presentPrivacyPolicy))
        $0.addGestureRecognizer(tapGesture)
    }

    lazy var genderTextField = GOMSTextFieldButton(frame: .zero, title: "성별을 선택해주세요").then {
        $0.addTarget(self, action: #selector(genderButtonTapped), for: .touchUpInside)
    }

    lazy var majorTextField = GOMSTextFieldButton(frame: .zero, title: "과를 선택해주세요").then {
        $0.addTarget(self, action: #selector(departmentButtonTapped), for: .touchUpInside)
    }

    lazy var gradeTextField = GOMSTextFieldButton(frame: .zero, title: "기수를 선택해주세요").then {
        $0.addTarget(self, action: #selector(gradeButtonTapped), for: .touchUpInside)
    }

    private lazy var authCodeButton = GOMSButton(frame: .zero, title: "인증번호 받기").then {
        $0.addTarget(self, action: #selector(authCodeButtonTapped), for: .touchUpInside)
        $0.isEnabled = false
        $0.backgroundColor = .color.button.color
        $0.setTitleColor(.color.sub2.color, for: .normal)
    }

    // MARK: - Life Cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)

        nameTextField.delegate = self
        emailTextField.delegate = self
        nameTextField.addTarget(self, action: #selector(nameEditingChanged(_:)), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(emailEditingChanged(_:)), for: .editingChanged)

        validateFields()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.subviews.forEach {
            if $0 != customBackButton && $0 != pageTitleLabel && $0.frame.height == 100 {
                $0.isHidden = true
                $0.removeFromSuperview()
            }
        }
    }

    // MARK: - Logic
    private func validateFields() {
        let name = nameTextField.text ?? ""
        let email = emailTextField.text ?? ""
        
        let emailRegex = "^s[0-9]{5}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        let isEmailValid = emailPredicate.evaluate(with: email)
        
        let isGenderSelected = genderTextField.title(for: .normal) != "성별을 선택해주세요"
        let isMajorSelected = majorTextField.title(for: .normal) != "과를 선택해주세요"
        let isGradeSelected = gradeTextField.title(for: .normal) != "기수를 선택해주세요"
        let isPrivacyAgreed = privacyCheckbox.isSelected
        
        let isAllValid = !name.isEmpty && isEmailValid && isGenderSelected && isMajorSelected && isGradeSelected && isPrivacyAgreed
        
        updateAuthCodeButtonState(isEnabled: isAllValid)
    }

    private func updateAuthCodeButtonState(isEnabled: Bool) {
        authCodeButton.isEnabled = isEnabled
        
        if isEnabled {
            privacyCheckbox.tintColor = .color.gomsPrimary.color
            authCodeButton.backgroundColor = .color.gomsPrimary.color
            authCodeButton.setTitleColor(.white, for: .normal)
        } else {
            privacyCheckbox.tintColor = .color.sub2.color
            authCodeButton.backgroundColor = .color.button.color
            authCodeButton.setTitleColor(.color.sub2.color, for: .normal)
        }
    }

    // MARK: - Selectors
    @objc private func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func gradeButtonTapped() {
        view.endEditing(true)
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let tenAction = UIAlertAction(title: "10기", style: .default) { _ in
            self.gradeTextField.setTitle("10기", for: .normal)
            self.gradeTextField.setTitleColor(.color.mainText.color, for: .normal)
            self.gradeTextField.layer.borderWidth = 0
            self.viewModel.setupGrade(grade: 10)
            self.validateFields()
        }
        let nineAction = UIAlertAction(title: "9기", style: .default) { _ in
            self.gradeTextField.setTitle("9기", for: .normal)
            self.gradeTextField.setTitleColor(.color.mainText.color, for: .normal)
            self.gradeTextField.layer.borderWidth = 0
            self.viewModel.setupGrade(grade: 9)
            self.validateFields()
        }
        let eightAction = UIAlertAction(title: "8기", style: .default) { _ in
            self.gradeTextField.setTitle("8기", for: .normal)
            self.gradeTextField.setTitleColor(.color.mainText.color, for: .normal)
            self.gradeTextField.layer.borderWidth = 0
            self.viewModel.setupGrade(grade: 8)
            self.validateFields()
        }
        [tenAction, nineAction, eightAction].forEach { alert.addAction($0) }
        present(alert, animated: true)
    }

    @objc private func genderButtonTapped() {
        view.endEditing(true)
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let menAction = UIAlertAction(title: "남성", style: .default) { _ in
            self.genderTextField.setTitle("남성", for: .normal)
            self.genderTextField.setTitleColor(.color.mainText.color, for: .normal)
            self.viewModel.setupGender(gender: .male)
            self.genderTextField.layer.borderWidth = 0
            self.validateFields()
        }
        let womanAction = UIAlertAction(title: "여성", style: .default) { _ in
            self.genderTextField.setTitle("여성", for: .normal)
            self.genderTextField.setTitleColor(.color.mainText.color, for: .normal)
            self.viewModel.setupGender(gender: .female)
            self.genderTextField.layer.borderWidth = 0
            self.validateFields()
        }
        [menAction, womanAction].forEach { alert.addAction($0) }
        present(alert, animated: true)
    }
    
    @objc private func privacyCheckboxTapped() {
        if privacyCheckbox.isSelected {
            privacyCheckbox.isSelected = false
            validateFields()
        } else {
            presentPrivacyPolicy()
        }
    }

    @objc private func presentPrivacyPolicy() {
        let privacyVC = PrivacyPolicyViewController()
        privacyVC.onAgreeCompletion = { [weak self] in
            self?.privacyCheckbox.isSelected = true
            self?.validateFields()
        }
        privacyVC.modalPresentationStyle = .fullScreen
        self.present(privacyVC, animated: true)
    }
    
    @objc private func departmentButtonTapped() {
        view.endEditing(true)
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let swAction = UIAlertAction(title: "SW개발과", style: .default) { _ in
            self.majorTextField.setTitle("SW개발과", for: .normal)
            self.majorTextField.setTitleColor(.color.mainText.color, for: .normal)
            self.viewModel.setupMajor(major: .sw)
            self.majorTextField.layer.borderWidth = 0
            self.validateFields()
        }
        let iotAction = UIAlertAction(title: "스마트IoT과", style: .default) { _ in
            self.majorTextField.setTitle("스마트IoT과", for: .normal)
            self.majorTextField.setTitleColor(.color.mainText.color, for: .normal)
            self.viewModel.setupMajor(major: .iot)
            self.majorTextField.layer.borderWidth = 0
            self.validateFields()
        }
        let aiAction = UIAlertAction(title: "AI개발과", style: .default) { _ in
            self.majorTextField.setTitle("AI개발과", for: .normal)
            self.majorTextField.setTitleColor(.color.mainText.color, for: .normal)
            self.viewModel.setupMajor(major: .ai)
            self.majorTextField.layer.borderWidth = 0
            self.validateFields()
        }
        [swAction, iotAction, aiAction].forEach { alert.addAction($0) }
        present(alert, animated: true)
    }

    @objc private func authCodeButtonTapped() {
        let email = emailTextField.text ?? ""
        viewModel.setupEmail(email: email)
        viewModel.setupEmailStatus(status: "SIGNUP")

        loader.modalPresentationStyle = .overFullScreen
        present(loader, animated: false)

        viewModel.sendAuthCode { [weak self] success, statusCode in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.loader.dismiss(animated: false)
                if success {
                    let authCodeVC = AuthCodeViewController(viewModel: self.viewModel, previousViewController: self, email: email + "@gsm.hs.kr")
                    self.navigationController?.pushViewController(authCodeVC, animated: true)
                } else {
                    print("인증번호 요청 실패: \(statusCode)")
                }
            }
        }
    }

    // MARK: - Add View
    public override func addView() {
        emailTextField.addSubview(defaultDomain)
        [customBackButton, pageTitleLabel, nameTextField, nameErrorLabel, emailTextField, emailErrorLabel, gradeTextField, genderTextField, majorTextField, privacyCheckbox, privacyLabel, authCodeButton].forEach { view.addSubview($0) }
        view.bringSubviewToFront(customBackButton)
    }

    // MARK: - Layout
    public override func setLayout() {
        customBackButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.equalToSuperview().offset(20)
        }

        pageTitleLabel.snp.makeConstraints {
            $0.top.equalTo(customBackButton.snp.bottom).offset(16)
            $0.leading.equalTo(20)
        }

        nameTextField.snp.makeConstraints {
            $0.leading.equalTo(20)
            $0.trailing.equalTo(-20)
            $0.top.equalTo(pageTitleLabel.snp.bottom).offset(24)
            $0.height.equalTo(56)
        }

        nameErrorLabel.snp.makeConstraints {
            $0.trailing.equalTo(nameTextField.snp.trailing)
            $0.top.equalTo(nameTextField.snp.bottom).offset(4)
            $0.height.equalTo(0)
        }

        emailTextField.snp.makeConstraints {
            $0.leading.equalTo(20)
            $0.trailing.equalTo(-20)
            $0.top.equalTo(nameErrorLabel.snp.bottom).offset(12)
            $0.height.equalTo(56)
        }

        emailErrorLabel.snp.makeConstraints {
            $0.trailing.equalTo(emailTextField.snp.trailing)
            $0.top.equalTo(emailTextField.snp.bottom).offset(4)
            $0.height.equalTo(0)
        }

        gradeTextField.snp.makeConstraints {
            $0.leading.equalTo(20)
            $0.trailing.equalTo(-20)
            $0.top.equalTo(emailErrorLabel.snp.bottom).offset(12)
            $0.height.equalTo(56)
        }

        genderTextField.snp.makeConstraints {
            $0.leading.equalTo(20)
            $0.trailing.equalTo(-20)
            $0.top.equalTo(gradeTextField.snp.bottom).offset(16)
            $0.height.equalTo(56)
        }

        majorTextField.snp.makeConstraints {
            $0.leading.equalTo(20)
            $0.trailing.equalTo(-20)
            $0.top.equalTo(genderTextField.snp.bottom).offset(16)
            $0.height.equalTo(56)
        }

        defaultDomain.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(28)
            $0.centerY.equalToSuperview()
        }

        privacyLabel.snp.makeConstraints {
            $0.top.equalTo(majorTextField.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(20)
        }

        privacyCheckbox.snp.makeConstraints {
            $0.centerY.equalTo(privacyLabel)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.height.equalTo(24)
        }

        authCodeButton.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
        }
    }

    // MARK: - Actions
    @objc private func nameEditingChanged(_ textField: UITextField) {
        let name = textField.text ?? ""
        nameTextField.layer.borderWidth = 0
        nameErrorLabel.isHidden = true
        nameErrorLabel.snp.updateConstraints { $0.height.equalTo(0) }
        viewModel.setupName(name: name)
        validateFields()
        view.layoutIfNeeded()
    }

    @objc private func emailEditingChanged(_ textField: UITextField) {
        let email = textField.text ?? ""
        emailTextField.layer.borderWidth = 0
        defaultDomain.textColor = .color.sub2.color
        
        let emailRegex = "^s[0-9]{5}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)

        if email.isEmpty {
            emailErrorLabel.isHidden = true
            emailErrorLabel.snp.updateConstraints { $0.height.equalTo(0) }
        } else if !emailPredicate.evaluate(with: email) && email.count == 6 {
            emailErrorLabel.isHidden = false
            emailErrorLabel.text = "올바른 이메일 형식이 아닙니다."
            emailErrorLabel.snp.updateConstraints { $0.height.equalTo(19) }
        } else {
            emailErrorLabel.isHidden = true
            emailErrorLabel.snp.updateConstraints { $0.height.equalTo(0) }
        }

        viewModel.setupEmail(email: email)
        validateFields()
        view.layoutIfNeeded()
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc public override func keyboardWillShow(_ sender: Notification) {
        guard let userInfo = sender.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        let keyboardHeight = keyboardFrame.height - view.safeAreaInsets.bottom
        authCodeButton.snp.updateConstraints { $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-(keyboardHeight + 24)) }
        UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
    }

    @objc public override func keyboardWillHide(_ sender: Notification) {
        guard let userInfo = sender.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        authCodeButton.snp.updateConstraints { $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24) }
        UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
    }
}

extension SignUpViewController: UITextFieldDelegate {
    public func textFieldDidChange(_ textField: UITextField) {
        if textField == nameTextField {
            viewModel.setupName(name: nameTextField.text ?? "")
        } else if textField == emailTextField {
            viewModel.setupEmail(email: emailTextField.text ?? "")
        }
        validateFields()
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == emailTextField {
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            return updatedText.count <= 6
        }
        return true
    }
}
