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
    private let placeData: MapPlaceDetailData // 데이터를 담을 변수 추가
    private var isHeartSelected = false
    
    // 초기화 시점에 데이터를 주입받습니다.
    public init(placeData: MapPlaceDetailData) {
        self.placeData = placeData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    public override func loadView() {
        self.view = mainView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        setupDelegate()
        setupActions()
        bindViewModel()
        
        // 주입받은 데이터를 뷰에 적용
        mainView.configure(with: placeData)
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
        
        viewModel.onReviewSuccess = { [weak self] in
            guard let self = self else { return }
            ReviewAlert.show(
                in: self,
                title: "후기 등록 완료",
                message: "후기를 성공적으로 등록했습니다!",
                completion: { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                }
            )
        }
    }
    
    @objc private func didTapBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapHeart() {
        isHeartSelected.toggle()
        mainView.heartButton.isSelected = isHeartSelected
        mainView.heartButton.tintColor = isHeartSelected ? UIColor.color.gomsPrimary.color : UIColor.color.sub2.color
    }
    
    @objc private func didTapNext() {
        self.view.endEditing(true)
        ReviewAlert.show(
            in: self,
            title: "후기 등록",
            message: "이 후기를 등록하시겠습니까?",
            completion: { [weak self] in
                self?.viewModel.postReview()
            }
        )
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
