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
        
        alert.cancelButton.addAction(UIAction { _ in
            alert.removeFromSuperview()
        }, for: .touchUpInside)
        
        alert.actionButton.addAction(UIAction { _ in
            alert.removeFromSuperview()
            completion()
        }, for: .touchUpInside)
    }
}

private class ReviewAlertView: UIView {
    private let containerView = UIView().then {
        // 배경색을 시스템 다크 그레이나 명확한 어두운색으로 고정
        $0.backgroundColor = UIColor(red: 44/255, green: 44/255, blue: 46/255, alpha: 1.0)
        $0.layer.cornerRadius = 14
        $0.clipsToBounds = true
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = .white // 글자색 흰색 고정
        $0.font = .suit(size: 17, weight: .semibold)
        $0.textAlignment = .center
    }
    
    private let messageLabel = UILabel().then {
        $0.textColor = .white // 글자색 흰색 고정
        $0.font = .suit(size: 13, weight: .medium)
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    
    let cancelButton = UIButton().then {
        $0.setTitle("취소", for: .normal)
        $0.setTitleColor(UIColor(red: 10/255, green: 132/255, blue: 255/255, alpha: 1.0), for: .normal)
        $0.titleLabel?.font = .suit(size: 17, weight: .medium)
    }
    
    let actionButton = UIButton().then {
        $0.titleLabel?.font = .suit(size: 17, weight: .semibold)
    }
    
    private let hLine = UIView().then { $0.backgroundColor = UIColor.white.withAlphaComponent(0.2) }
    private let vLine = UIView().then { $0.backgroundColor = UIColor.white.withAlphaComponent(0.2) }

    init(title: String, message: String) {
        super.init(frame: .zero)
        self.backgroundColor = .black.withAlphaComponent(0.5)
        
        titleLabel.text = title
        messageLabel.text = message
        
        // 버튼 텍스트 및 레이아웃 분기
        if title.contains("삭제") && !title.contains("완료") {
            actionButton.setTitle("삭제하기", for: .normal)
            actionButton.setTitleColor(.systemRed, for: .normal)
        } else if title.contains("신고") && !title.contains("완료") {
            actionButton.setTitle("신고하기", for: .normal)
            actionButton.setTitleColor(.systemRed, for: .normal)
        } else {
            // 완료 팝업 혹은 단순 알림 (버튼 하나만)
            cancelButton.isHidden = true
            vLine.isHidden = true
            actionButton.setTitle("돌아가기", for: .normal)
            actionButton.setTitleColor(UIColor(red: 10/255, green: 132/255, blue: 255/255, alpha: 1.0), for: .normal)
        }
        
        addSubview(containerView)
        [titleLabel, messageLabel, hLine, vLine, cancelButton, actionButton].forEach { containerView.addSubview($0) }
        
        containerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(270)
            $0.height.equalTo(138)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
        }
        
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
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
    required init?(coder: NSCoder) { fatalError() }
}
