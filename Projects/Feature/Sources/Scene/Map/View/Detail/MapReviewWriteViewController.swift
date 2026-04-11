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
    // 뷰모델을 생성자에서 초기화하도록 수정했습니다.
    private let viewModel: MapReviewWriteViewModel
    private let placeData: MapPlaceDetailModel
    private var isHeartSelected = false
    
    // MARK: - Life Cycle
    public init(placeData: MapPlaceDetailModel) {
        self.placeData = placeData
        // 뷰모델 생성 시 placeData의 placeId를 넘겨주어 서버 통신 준비를 마칩니다.
        self.viewModel = MapReviewWriteViewModel(placeId: placeData.placeId)
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
        
        mainView.configure(with: placeData)
        
        isHeartSelected = placeData.recommended
        mainView.heartButton.isSelected = isHeartSelected
        mainView.heartButton.tintColor = isHeartSelected ? UIColor.color.gomsPrimary.color : UIColor.color.sub2.color
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
        // 버튼 활성화 상태 업데이트
        viewModel.onNextButtonStateChanged = { [weak self] isEnabled in
            self?.mainView.updateButtonState(isEnabled: isEnabled)
        }
        
        // 서버 등록 성공 시 처리
        viewModel.onReviewSuccess = { [weak self] in
            guard let self = self else { return }
            ReviewAlert.show(
                in: self,
                title: "후기 등록 완료",
                message: "후기를 성공적으로 등록했습니다!",
                completion: { [weak self] in
                    // 이전 화면(상세보기)으로 돌아가기
                    self?.navigationController?.popViewController(animated: true)
                }
            )
        }
        
        // 에러 발생 시 알림 처리 (선택 사항)
        viewModel.onErrorOccurred = { [weak self] errorMessage in
            guard let self = self else { return }
            print("에러 발생: \(errorMessage)")
            // 필요시 에러 알럿을 띄울 수 있습니다.
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
                // 뷰모델의 서버 등록 함수 호출 (writeReview 실행)
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
