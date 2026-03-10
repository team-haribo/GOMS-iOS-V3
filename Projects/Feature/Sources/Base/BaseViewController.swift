//
//  BaseViewController.swift
//  Feature
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit
import Then

public class BaseViewController: UIViewController {
    
    

    // MARK: - Properties
    let bounds = UIScreen.main.bounds

    // MARK: - Custom Navigation
    private let customNavView = UIView()
    private let backButton = UIButton(type: .system)

    // MARK: - Life Cycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.setDynamicBackgroundColor(
            darkModeColor: .color.background.color,
            lightModeColor: .color.background.color
        )

        navigationController?.navigationBar.isHidden = true
        setupKeyboardEvent()
        setupCustomNavigation()
        configureUI()
        addView()
        setLayout()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.navigationBar.isHidden = true

        if navigationController?.viewControllers.first === self {
            customNavView.isHidden = true
        } else {
            customNavView.isHidden = false
        }

        configNavigation()
    }

    func configNavigation() { }

    // MARK: Navigation Setup

    private func setupCustomNavigation() {
        customNavView.backgroundColor = .color.background.color
        view.addSubview(customNavView)

        customNavView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(100)
        }

        let backImage = UIImage(
            named: "Back",
            in: Bundle.module,
            compatibleWith: nil
        )

        let backImageView = UIImageView(image: backImage)
        backImageView.contentMode = .scaleAspectFit

        let backLabel = UILabel()
        backLabel.text = "돌아가기"
        backLabel.font = .suit(size: 16, weight: .medium)
        backLabel.textColor = .color.gomsPrimary.color

        let backStack = UIStackView(arrangedSubviews: [backImageView, backLabel])
        backStack.axis = .horizontal
        backStack.alignment = .center
        backStack.spacing = 4

        customNavView.addSubview(backStack)

        backStack.snp.makeConstraints {
            $0.leading.equalTo(31)
            $0.bottom.equalTo(-12)
        }

        backStack.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backTapped))
        backStack.addGestureRecognizer(tapGesture)
    }


    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Keyboard

    @objc func keyboardWillShow(_ sender: Notification) { }
    @objc func keyboardWillHide(_ sender: Notification) { }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    func setupKeyboardEvent() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    // MARK: - Layout Hooks
    func configureUI() {}
    func addView() {}
    func setLayout() {}
}
