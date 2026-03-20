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

public class ReviewAlert {
    public static func show(
        in vc: UIViewController,
        title: String,
        message: String,
        completion: @escaping () -> Void = {}
    ) {
        let alert = ReviewAlertView(title: title, message: message)
        vc.view.addSubview(alert)
        alert.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        alert.cancelButton.addTarget(alert, action: #selector(alert.didTapCancel), for: .touchUpInside)
        alert.actionButton.addTarget(alert, action: #selector(alert.didTapAction), for: .touchUpInside)
        alert.completionHandler = completion
    }
}

private class ReviewAlertView: UIView {
    var completionHandler: (() -> Void)?
    
    private let containerView = UIView().then {
        $0.backgroundColor = UIColor.color.gomsAlertBackground.color
        $0.layer.cornerRadius = 14
        $0.clipsToBounds = true
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = UIColor.color.mainText.color
        $0.font = .systemFont(ofSize: 17, weight: .bold)
        $0.textAlignment = .center
    }
    
    private let messageLabel = UILabel().then {
        $0.textColor = UIColor.color.mainText.color
        $0.font = .systemFont(ofSize: 13, weight: .medium)
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    
    let cancelButton = UIButton(type: .system).then {
        $0.setTitle("취소", for: .normal)
        $0.setTitleColor(UIColor.color.gomsNegative.color, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
    }
    
    let actionButton = UIButton(type: .system).then {
        $0.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
    }
    
    // 화이트 모드에서도 잘 보이도록 sub1 색상 적용
    private let hLine = UIView().then { $0.backgroundColor = UIColor.color.sub1.color }
    private let vLine = UIView().then { $0.backgroundColor = UIColor.color.sub1.color }

    init(title: String, message: String) {
        super.init(frame: .zero)
        self.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        titleLabel.text = title
        messageLabel.text = message
        
        setupLayoutByTitle(title)
        setupView()
        setupConstraints()
    }
    
    private func setupLayoutByTitle(_ title: String) {
        if title.contains("등록") && !title.contains("완료") {
            actionButton.setTitle("등록하기", for: .normal)
            actionButton.setTitleColor(UIColor.color.gomsInformation.color, for: .normal)
            cancelButton.isHidden = false
            vLine.isHidden = false
        } else if title.contains("완료") {
            cancelButton.isHidden = true
            vLine.isHidden = true
            actionButton.setTitle("돌아가기", for: .normal)
            actionButton.setTitleColor(UIColor.color.gomsInformation.color, for: .normal)
        }
    }
    
    private func setupView() {
        addSubview(containerView)
        [titleLabel, messageLabel, hLine, vLine, cancelButton, actionButton].forEach { containerView.addSubview($0) }
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(270)
            $0.height.equalTo(142) // 간격 확보를 위해 전체 높이 소폭 조정
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
        }
        
        messageLabel.snp.makeConstraints {
            // 타이틀과 메시지 사이의 간격을 8로 넓힘
            $0.top.equalTo(titleLabel.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview().inset(16)
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
            $0.trailing.equalTo(vLine.snp.leading)
            $0.height.equalTo(44)
        }
        
        actionButton.snp.makeConstraints {
            $0.trailing.bottom.equalToSuperview()
            $0.leading.equalTo(cancelButton.isHidden ? containerView.snp.leading : vLine.snp.trailing)
            $0.height.equalTo(44)
        }
    }
    
    @objc func didTapCancel() {
        self.removeFromSuperview()
    }
    
    @objc func didTapAction() {
        self.removeFromSuperview()
        completionHandler?()
    }
    
    required init?(coder: NSCoder) { fatalError() }
}
