//
//  ReviewAlert.swift
//  Feature
//
//  Created by 김민선 on 3/14/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit
import Then

public struct ReviewReportRequestDTO: Codable {
    let reason: String
}

public class ReviewAlert {
    public static func show(
        in vc: UIViewController,
        title: String,
        message: String,
        completion: @escaping () -> Void = {}
    ) {
        let alert = ReviewAlertView(title: title, message: message, vc: vc)
        vc.view.addSubview(alert)
        alert.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        alert.cancelButton.addTarget(alert, action: #selector(alert.didTapCancel), for: .touchUpInside)
        alert.actionButton.addTarget(alert, action: #selector(alert.didTapAction), for: .touchUpInside)
        alert.completionHandler = completion
    }
}

private class ReviewAlertView: UIView, UITextViewDelegate {
    var completionHandler: (() -> Void)?
    private weak var parentVC: UIViewController?
    private var currentTitle: String = ""
    private let placeholderText = "신고 사유 작성"
    private var isReportFlow: Bool = false
    
    private let containerView = UIView().then {
        $0.backgroundColor = UIColor.color.gomsAlertBackground.color
        $0.layer.cornerRadius = 14
        $0.clipsToBounds = true
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = .label
        $0.font = .systemFont(ofSize: 18, weight: .semibold)
        $0.textAlignment = .center
    }
    
    private let messageLabel = UILabel().then {
        $0.textColor = .label
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }

    private let reasonTextView = UITextView().then {
        $0.backgroundColor = UIColor.color.gomsTextFieldBackground.color
        $0.textColor = UIColor.color.sub2.color
        $0.text = "신고 사유 작성"
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.color.sub2.color.cgColor
        $0.textContainerInset = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
        $0.isHidden = true
    }

    private let countLabel = UILabel().then {
        $0.text = "0/100"
        $0.textColor = UIColor.color.sub2.color
        $0.font = .systemFont(ofSize: 12, weight: .regular)
        $0.textAlignment = .right
        $0.isHidden = true
    }
    
    let cancelButton = UIButton(type: .system).then {
        $0.setTitle("취소", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
    }
    
    let actionButton = UIButton(type: .system).then {
        $0.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
    }
    
    private let hLine = UIView().then { $0.backgroundColor = UIColor.color.sub1.color }
    private let vLine = UIView().then { $0.backgroundColor = UIColor.color.sub1.color }

    init(title: String, message: String, vc: UIViewController?) {
        super.init(frame: .zero)
        self.parentVC = vc
        self.currentTitle = title
        self.isReportFlow = title.contains("신고")
        self.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        if title.contains("신고") && !title.contains("완료") {
            titleLabel.text = "후기 신고"
            messageLabel.text = "이 후기를 신고하시겠습니까?\n신고 내용은 운영팀의 검토 후 처리됩니다."
        } else {
            titleLabel.text = title
            messageLabel.text = message
        }
        
        reasonTextView.delegate = self
        setupLayoutByTitle(title)
        setupView()
        setupConstraints()
    }
    
    private func setupLayoutByTitle(_ title: String) {
        if title.contains("완료") {
            cancelButton.isHidden = true
            vLine.isHidden = true
            reasonTextView.isHidden = true
            countLabel.isHidden = true
            actionButton.setTitle("돌아가기", for: .normal)
            actionButton.setTitleColor(UIColor.color.gomsInformation.color, for: .normal)
        }
        else if title.contains("등록") {
            actionButton.setTitle("등록하기", for: .normal)
            actionButton.setTitleColor(UIColor.color.gomsInformation.color, for: .normal)
            cancelButton.setTitleColor(UIColor.color.gomsNegative.color, for: .normal)
        }
        else if title.contains("삭제") {
            actionButton.setTitle("삭제하기", for: .normal)
            actionButton.setTitleColor(UIColor.color.gomsNegative.color, for: .normal)
            cancelButton.setTitleColor(UIColor.color.gomsInformation.color, for: .normal)
        }
        else if title.contains("신고") {
            actionButton.setTitle("신고하기", for: .normal)
            actionButton.setTitleColor(UIColor.color.gomsNegative.color, for: .normal)
            cancelButton.setTitleColor(UIColor.color.gomsInformation.color, for: .normal)
            reasonTextView.isHidden = false
            countLabel.isHidden = false
        }
    }
    
    private func setupView() {
        addSubview(containerView)
        [titleLabel, messageLabel, reasonTextView, countLabel, cancelButton, actionButton, hLine, vLine].forEach { containerView.addSubview($0) }
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(285)
            $0.height.equalTo(!reasonTextView.isHidden ? 212 : 145)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
        }
        
        messageLabel.snp.makeConstraints {
            // 신고 알럿일 때만 간격을 8로 좁힘
            $0.top.equalTo(titleLabel.snp.bottom).offset(isReportFlow ? 8 : 16)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        if !reasonTextView.isHidden {
            reasonTextView.snp.makeConstraints {
                $0.top.equalTo(messageLabel.snp.bottom).offset(12)
                $0.leading.trailing.equalToSuperview().inset(16)
                $0.height.equalTo(43)
            }
            countLabel.snp.makeConstraints {
                $0.top.equalTo(reasonTextView.snp.bottom).offset(4)
                $0.trailing.equalTo(reasonTextView)
            }
        }
        
        hLine.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-44)
            $0.height.equalTo(0.5)
        }
        
        vLine.snp.makeConstraints {
            $0.top.equalTo(hLine.snp.top)
            $0.bottom.centerX.equalToSuperview()
            $0.width.equalTo(0.5)
        }
        
        cancelButton.snp.makeConstraints {
            $0.leading.bottom.equalToSuperview()
            $0.trailing.equalTo(containerView.snp.centerX)
            $0.height.equalTo(44)
        }
        
        actionButton.snp.makeConstraints {
            $0.trailing.bottom.equalToSuperview()
            $0.leading.equalTo(cancelButton.isHidden ? containerView.snp.leading : containerView.snp.centerX)
            $0.height.equalTo(44)
        }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholderText {
            textView.text = nil
            textView.textColor = .label
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholderText
            textView.textColor = UIColor.color.sub2.color
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let count = textView.text.count
        countLabel.text = "\(count)/100"
        if count > 100 {
            textView.text = String(textView.text.prefix(100))
            countLabel.text = "100/100"
        }
    }
    
    @objc func didTapCancel() {
        self.removeFromSuperview()
    }
    
    @objc func didTapAction() {
        let savedTitle = self.currentTitle
        let savedVC = self.parentVC
        
        self.removeFromSuperview()
        completionHandler?()
        
        if savedTitle.contains("완료") { return }
        
        if let vc = savedVC {
            if savedTitle.contains("삭제") {
                ReviewAlert.show(in: vc, title: "삭제 완료", message: "후기가 성공적으로 삭제되었습니다.")
            } else if savedTitle.contains("신고") {
                ReviewAlert.show(in: vc, title: "신고 완료", message: "신고가 정상적으로 접수되었습니다.\n더 나은 GOMS가 되기 위해 노력하겠습니다!")
            }
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
}
