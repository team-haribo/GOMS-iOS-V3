//
//  GOMSAlert.swift
//  Feature
//
//  Created by 김민선 on 3/27/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit
import Then

public class GOMSAlert {
    public static func show(
        in vc: UIViewController,
        title: String,
        message: String,
        actionTitle: String,
        cancelTitle: String = "취소",
        isNegative: Bool = false,
        highlightKeywords: [String] = [],
        action: @escaping () -> Void = {},
        cancelAction: @escaping () -> Void = {}
    ) {
        let alert = GOMSAlertView(
            title: title,
            message: message,
            actionTitle: actionTitle,
            cancelTitle: cancelTitle,
            isNegative: isNegative,
            highlightKeywords: highlightKeywords
        )
        vc.view.addSubview(alert)
        alert.snp.makeConstraints { $0.edges.equalToSuperview() }
        alert.actionHandler = action
        alert.cancelHandler = cancelAction
    }
}

private class GOMSAlertView: UIView {
    var actionHandler: (() -> Void)?
    var cancelHandler: (() -> Void)?
    
    private let containerView = UIView().then {
        $0.backgroundColor = UIColor.color.gomsAlertBackground.color
        $0.layer.cornerRadius = 14
        $0.clipsToBounds = true
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = UIColor.color.mainText.color
        $0.font = .systemFont(ofSize: 18, weight: .semibold)
        $0.textAlignment = .center
    }
    
    private let messageLabel = UILabel().then {
        $0.textColor = UIColor.color.mainText.color
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.minimumScaleFactor = 0.8
        $0.adjustsFontSizeToFitWidth = true
    }
    
    private let hLine = UIView().then {
        $0.backgroundColor = UIColor.color.sub1.color.withAlphaComponent(0.2)
    }
    private let vLine = UIView().then {
        $0.backgroundColor = UIColor.color.sub1.color.withAlphaComponent(0.2)
    }

    let cancelButton = UIButton(type: .system).then {
        $0.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        $0.setTitleColor(UIColor.color.gomsInformation.color, for: .normal)
    }
    
    let actionButton = UIButton(type: .system).then {
        $0.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
    }

    init(
        title: String,
        message: String,
        actionTitle: String,
        cancelTitle: String,
        isNegative: Bool,
        highlightKeywords: [String]
    ) {
        super.init(frame: .zero)
        self.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        titleLabel.text = title
        cancelButton.setTitle(cancelTitle, for: .normal)
        actionButton.setTitle(actionTitle, for: .normal)
        
        actionButton.setTitleColor(
            isNegative ? UIColor.color.gomsNegative.color : UIColor.color.gomsInformation.color,
            for: .normal
        )
        
        setMessageWithHighlight(message, keywords: highlightKeywords)
        
        setupView()
        setupConstraints()
        setupEvents()
    }
    
    private func setMessageWithHighlight(_ message: String, keywords: [String]) {
        let attributedString = NSMutableAttributedString(string: message)
        let highlightColor = UIColor.color.gomsNegative.color
        
        keywords.forEach { keyword in
            var range = (message as NSString).range(of: keyword)
            while range.location != NSNotFound {
                attributedString.addAttribute(.foregroundColor, value: highlightColor, range: range)
                let startLocation = range.location + range.length
                range = (message as NSString).range(of: keyword, options: [], range: NSRange(location: startLocation, length: message.count - startLocation))
            }
        }
        
        messageLabel.attributedText = attributedString
    }
    
    private func setupView() {
        addSubview(containerView)
        [titleLabel, messageLabel, cancelButton, actionButton, hLine, vLine].forEach {
            containerView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(285)
            $0.height.equalTo(145)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
        }
        
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
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
            $0.trailing.equalTo(containerView.snp.centerX)
            $0.height.equalTo(44)
        }
        
        actionButton.snp.makeConstraints {
            $0.trailing.bottom.equalToSuperview()
            $0.leading.equalTo(containerView.snp.centerX)
            $0.height.equalTo(44)
        }
    }
    
    private func setupEvents() {
        cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        actionButton.addTarget(self, action: #selector(didTapAction), for: .touchUpInside)
    }
    
    @objc func didTapCancel() {
        self.removeFromSuperview()
        cancelHandler?()
    }
    
    @objc func didTapAction() {
        self.removeFromSuperview()
        actionHandler?()
    }
    
    required init?(coder: NSCoder) { fatalError() }
}
