//
//  SignInViewController.swift
//  Feature
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import Service
import SnapKit
import Then

public final class SignInViewController: BaseViewController {
    
    // MARK: - Properties
    private var viewModel = AuthViewModel()
    private var listModel : StudentListModel?
    private var profileModel = ProfileViewModel()
    private let notificationViewModel = NotificationViewModel()

    private let loader = LoaderViewController()
    
    // 커스텀 뒤로가기 버튼
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
        $0.text = "로그인"
        $0.font = .suit(size: 24, weight: .bold)
        $0.textColor = .color.mainText.color
    }
    
    init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    init(listModel: StudentListModel) {
        self.listModel = listModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var textFieldStackView = UIStackView().then {
        $0.spacing = 24
        $0.axis = .vertical
        $0.distribution = .fillEqually
        $0.alignment = .fill
    }
    
    private let emailTextField = GOMSTextField(frame: .zero, placeholder: "이메일을 입력해주세요")
    
    private let defaultDomain = UILabel().then {
        $0.text = "@gsm.hs.kr"
        $0.font = .suit(size: 16, weight: .medium)
        $0.textColor = .color.sub2.color
    }
    
    private let emailErrorLabel = UILabel().then {
        $0.text = "잘못된 형식의 이메일입니다"
        $0.textColor = .color.gomsNegative.color
        $0.font = .suit(size: 15, weight: .medium)
        $0.textAlignment = .right
        $0.isHidden = true
    }

    lazy var passwordTextField = GOMSTextField(frame: .zero, placeholder: "비밀번호를 입력해주세요").then {
        $0.isSecureTextEntry = true
        $0.rightView = showPasswordButton
        $0.rightViewMode = .always
    }
    
    lazy var showPasswordButton = UIButton().then {
        $0.setImage(.image.on.image, for: .normal)
        $0.tintColor = .color.sub2.color
        $0.adjustsImageWhenHighlighted = false
        $0.addTarget(self, action: #selector(showPasswordButtonTapped), for: .touchUpInside)
        $0.isEnabled = true
    }
    
    private lazy var findPasswordButton = UIButton().then {
        $0.setTitle("비밀번호 찾기", for: .normal)
        $0.backgroundColor = .clear
        $0.titleLabel?.font = UIFont.suit(size: 15, weight: .medium)
        $0.setTitleColor(.color.gomsPrimary.color, for: .normal)
        $0.addTarget(self, action: #selector(findPasswordButtonTapped), for: .touchUpInside)
    }
    
    private let passwordErrorLabel = UILabel().then {
        $0.text = "잘못된 비밀번호입니다."
        $0.textColor = .color.gomsNegative.color
        $0.font = .suit(size: 15, weight: .medium)
        $0.textAlignment = .right
        $0.isHidden = true
    }
    
    private lazy var signInButton = GOMSButton(frame: .zero, title: "로그인").then {
        $0.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Life Cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        emailTextField.addTarget(self, action: #selector(emailEditingChanged(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(passwordEditingChanged(_:)), for: .editingChanged)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 참고 코드 방식대로 애니메이션 없이 내비 바 숨김
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    // ⭐ 핵심: BaseViewController에서 강제로 추가한 높이 100짜리 뷰 등을 지워버림
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.subviews.forEach {
            if $0 != customBackButton && $0 != pageTitleLabel && $0.frame.height == 100 {
                $0.isHidden = true
                $0.removeFromSuperview()
            }
        }
    }
    
    // MARK: - Selectors
    @objc private func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc func findPasswordButtonTapped() {
        let findPasswordVC = FindPasswordViewController(viewModel: self.viewModel)
        navigationController?.pushViewController(findPasswordVC, animated: true)
    }
    
    @objc func signInButtonTapped() {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""

        emailErrorLabel.isHidden = true
        passwordErrorLabel.isHidden = true

        emailErrorLabel.snp.updateConstraints {
            $0.height.equalTo(0)
        }
        view.layoutIfNeeded()

        if email.isEmpty {
            emailErrorLabel.text = "이메일을 입력해주세요."
            showEmailError()
            return
        }

        let emailRegex = "^s[0-9]{5}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)

        if !emailPredicate.evaluate(with: email) {
            emailErrorLabel.text = "올바른 이메일 형식이 아닙니다."
            showEmailError()
            return
        }

        if password.isEmpty {
            passwordErrorLabel.text = "비밀번호를 입력해주세요."
            showPasswordError()
            return
        }

        viewModel.setupEmail(email: email)
        viewModel.setupPassword(password: password)

        viewModel.signIn { [weak self] statusCode, authority in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if (200..<300).contains(statusCode) {
                    UserDefaults.standard.set(email, forKey: "localEmail")
                    UserDefaults.standard.set(password, forKey: "localPass")
                    
                    if authority == "ROLE_STUDENT" {
                        let mainVC = MainViewController()
                        self.navigationController?.setViewControllers([mainVC], animated: true)
                    } else if authority == "ROLE_STUDENT_COUNCIL" {
                        let adminVC = AdminMainViewController()
                        self.navigationController?.setViewControllers([adminVC], animated: true)
                    } else {
                        self.passwordErrorLabel.text = "권한 정보를 확인할 수 없습니다."
                        self.showPasswordError()
                    }
                } else {
                    self.passwordErrorLabel.text = "이메일 또는 비밀번호를 확인해주세요."
                    self.showPasswordError()
                }
            }
        }
    }

    @objc func showPasswordButtonTapped() {
        passwordTextField.isSecureTextEntry.toggle()
        showPasswordButton.isSelected.toggle()
        
        if showPasswordButton.isSelected {
            showPasswordButton.setImage(.image.off.image, for: .normal)
        } else {
            showPasswordButton.setImage(.image.on.image, for: .normal)
        }
    }
    
    @objc public override func keyboardWillShow(_ sender: Notification) {
        guard
            let userInfo = sender.userInfo,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }

        let keyboardHeight = keyboardFrame.height - view.safeAreaInsets.bottom
        signInButton.snp.updateConstraints {
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

        signInButton.snp.updateConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
        }

        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func showDefaultState() {
        emailTextField.setPlaceholderColor(.color.sub2.color)
        defaultDomain.textColor = .color.sub2.color
        emailErrorLabel.isHidden = true
        emailTextField.layer.borderColor = UIColor.clear.cgColor
        emailTextField.layer.borderWidth = 0

        passwordErrorLabel.isHidden = true
        passwordTextField.layer.borderColor = UIColor.clear.cgColor
        passwordTextField.layer.borderWidth = 0

        emailErrorLabel.snp.updateConstraints { $0.height.equalTo(0) }
        passwordErrorLabel.snp.updateConstraints { $0.height.equalTo(0) }

        findPasswordButton.snp.remakeConstraints {
            $0.height.equalTo(48)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(passwordTextField.snp.bottom)
        }
        view.layoutIfNeeded()
    }
    
    private func showEmailError() {
        emailTextField.setPlaceholderColor(.color.gomsNegative.color)
        defaultDomain.textColor = .color.gomsNegative.color
        emailErrorLabel.isHidden = false
        emailTextField.layer.borderColor = UIColor.systemRed.cgColor
        emailTextField.layer.borderWidth = 1

        passwordErrorLabel.isHidden = true
        passwordTextField.layer.borderColor = UIColor.clear.cgColor
        passwordTextField.layer.borderWidth = 0

        emailErrorLabel.snp.updateConstraints { $0.height.equalTo(19) }
        view.layoutIfNeeded()
    }
    
    private func showPasswordError() {
        passwordTextField.setPlaceholderColor(.color.gomsNegative.color)
        passwordErrorLabel.isHidden = false
        passwordErrorLabel.snp.updateConstraints { $0.height.equalTo(19) }
        passwordTextField.layer.borderColor = UIColor.systemRed.cgColor
        passwordTextField.layer.borderWidth = 1

        emailErrorLabel.isHidden = true
        emailErrorLabel.snp.updateConstraints { $0.height.equalTo(0) }

        findPasswordButton.snp.remakeConstraints {
            $0.height.equalTo(48)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(passwordErrorLabel.snp.bottom).offset(0)
        }
        view.layoutIfNeeded()
    }
    
    // MARK: - Add View
    public override func addView() {
        emailTextField.addSubview(defaultDomain)
        [customBackButton, pageTitleLabel, emailTextField, emailErrorLabel, passwordTextField, passwordErrorLabel, findPasswordButton, signInButton].forEach { view.addSubview($0) }
        view.bringSubviewToFront(customBackButton) // 커스텀 버튼을 맨 앞으로
    }
    
    // MARK: - Layout
    public override func setLayout() {
        customBackButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.equalToSuperview().offset(20)
        }

        pageTitleLabel.snp.makeConstraints {
            $0.top.equalTo(customBackButton.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
        }

        defaultDomain.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(28)
            $0.centerY.equalToSuperview()
        }

        emailTextField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(pageTitleLabel.snp.bottom).offset(24)
            $0.height.equalTo(56)
        }

        emailErrorLabel.snp.makeConstraints {
            $0.trailing.equalTo(emailTextField.snp.trailing)
            $0.top.equalTo(emailTextField.snp.bottom).offset(8)
            $0.height.equalTo(0)
        }
      
        passwordTextField.snp.makeConstraints {
            $0.height.equalTo(56)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(emailErrorLabel.snp.bottom).offset(16)
        }

        passwordErrorLabel.snp.makeConstraints {
            $0.height.equalTo(0)
            $0.trailing.equalTo(passwordTextField.snp.trailing)
            $0.top.equalTo(passwordTextField.snp.bottom).offset(8)
        }

        findPasswordButton.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(passwordTextField.snp.bottom)
        }

        signInButton.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
        }
    }
    
    @objc private func emailEditingChanged(_ textField: UITextField) {
        textFieldDidChange(textField)
    }

    @objc private func passwordEditingChanged(_ textField: UITextField) {
        textFieldDidChange(textField)
    }
}

// MARK: - Extension
extension SignInViewController: UITextFieldDelegate {
    public func textFieldDidChange(_ textField: UITextField) {
        if textField == emailTextField {
            let email = textField.text ?? ""
            viewModel.setupEmail(email: email)
            let emailRegex = "^s[0-9]{5}$"
            let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
            
            if email.isEmpty {
                emailErrorLabel.isHidden = true
                emailTextField.layer.borderWidth = 0
                emailErrorLabel.snp.updateConstraints { $0.height.equalTo(0) }
                view.layoutIfNeeded()
            } else if !emailPredicate.evaluate(with: email) {
                emailErrorLabel.text = "올바른 이메일 형식이 아닙니다."
                showEmailError()
            } else {
                showDefaultState()
            }
        } else if textField == passwordTextField {
            viewModel.setupPassword(password: textField.text ?? "")
        }
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text ?? "") as NSString
        let updatedText = currentText.replacingCharacters(in: range, with: string)
        if textField == emailTextField {
            return updatedText.count <= 6 && updatedText.rangeOfCharacter(from: .whitespaces) == nil
        }
        if textField == passwordTextField {
            return updatedText.rangeOfCharacter(from: .whitespaces) == nil
        }
        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if emailTextField.text != "", passwordTextField.text != "" {
            passwordTextField.resignFirstResponder()
            return true
        } else if emailTextField.text != "" {
            passwordTextField.becomeFirstResponder()
            return true
        }
        return false
    }
}
