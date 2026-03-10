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

open class BaseViewController: UIViewController {

    // MARK: - Properties
    
    public let screenBounds: CGRect = UIScreen.main.bounds

    // MARK: - Lifecycle
    open override func viewDidLoad() {
        super.viewDidLoad()

        addKeyboardObservers()

        configureUI()
        addView()
        setLayout()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        applyDynamicBackground()
        applyNavigationAppearance()
    }

    deinit {
        removeKeyboardObservers()
    }

    // MARK: - Touch
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }

    // MARK: - Keyboard Observers
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

 
    @objc open func keyboardWillShow(_ notification: Notification) { }
    @objc open func keyboardWillHide(_ notification: Notification) { }

    // MARK: - Background
    private func applyDynamicBackground() {
        view.backgroundColor = .color.background.color
    }

    // MARK: - Navigation
    private func applyNavigationAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .clear

        navigationController?.navigationBar.tintColor = .systemBlue
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()

        let backBarButtonItem = UIBarButtonItem(
            title: "돌아가기",
            style: .plain,
            target: nil,
            action: nil
        )
        navigationItem.backBarButtonItem = backBarButtonItem

        navigationController?.navigationBar.clipsToBounds = true
        navigationController?.navigationBar.isHidden = false
    }

    // MARK: - Template Methods
   
    open func configureUI() { }
    open func addView() { }
    open func setLayout() { }
}
