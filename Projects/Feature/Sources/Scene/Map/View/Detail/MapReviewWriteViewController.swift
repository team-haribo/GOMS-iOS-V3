//
//  MapReviewWriteViewController.swift
//  Feature
//
//  Created by 김민선 on 3/15/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit

public final class MapReviewWriteViewController: UIViewController {
    
    private let mainView = MapReviewWriteView()
    private let viewModel = MapReviewWriteViewModel()
    private var isHeartSelected = false
    
    public override func loadView() {
        self.view = mainView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        setupDelegate()
        setupActions()
        bindViewModel()
    }
    
    private func setupDelegate() {
        mainView.textView.delegate = self
    }
    
    private func setupActions() {
        mainView.backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        mainView.heartButton.addTarget(self, action: #selector(didTapHeart), for: .touchUpInside)
        mainView.nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
    }
    
    private func bindViewModel() {
        viewModel.onNextButtonStateChanged = { [weak self] isEnabled in
            self?.mainView.updateButtonState(isEnabled: isEnabled)
        }
    }
    
    @objc private func didTapBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapHeart() {
        isHeartSelected.toggle()
        mainView.heartButton.isSelected = isHeartSelected
        mainView.heartButton.tintColor = isHeartSelected ? .color.gomsPrimary.color : .color.sub2.color
    }
    
    @objc private func didTapNext() {
        print("작성 내용: \(viewModel.currentText)")
    }
}

extension MapReviewWriteViewController: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        viewModel.updateText(textView.text)
        mainView.placeholderLabel.isHidden = !textView.text.isEmpty
        mainView.limitLabel.text = viewModel.limitText
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        return updatedText.count <= 100
    }
}
