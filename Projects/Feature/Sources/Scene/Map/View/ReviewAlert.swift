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
        $0.backgroundColor = UIColor(named: "GOMS_AlertBackground", in: .module, compatibleWith: nil)
        $0.layer.cornerRadius = 14
        $0.clipsToBounds = true
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = .white
        $0.font = UIFont(name: "SUIT-SemiBold", size: 17) ?? .systemFont(ofSize: 17, weight: .semibold)
        $0.textAlignment = .center
    }
    
    private let messageLabel = UILabel().then {
        $0.textColor = .white
        $0.font = UIFont(name: "SUIT-Medium", size: 13) ?? .systemFont(ofSize: 13)
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    
    let cancelButton = UIButton().then {
        $0.setTitleColor(UIColor(named: "GOMS_Information", in: .module, compatibleWith: nil), for: .normal)
        $0.titleLabel?.font = UIFont(name: "SUIT-Medium", size: 17) ?? .systemFont(ofSize: 17)
    }
    
    let actionButton = UIButton().then {
        $0.setTitleColor(UIColor(named: "GOMS_Negative", in: .module, compatibleWith: nil), for: .normal)
        $0.titleLabel?.font = UIFont(name: "SUIT-Medium", size: 17) ?? .systemFont(ofSize: 17, weight: .semibold)
    }
    
    private let hLine = UIView().then { $0.backgroundColor = .color.sub2.color }
    private let vLine = UIView().then { $0.backgroundColor = .color.sub2.color }

    init(title: String, message: String) {
        super.init(frame: .zero)
        self.backgroundColor = .black.withAlphaComponent(0.4)
        
        titleLabel.text = title
        messageLabel.text = message
        
        // 버튼 텍스트 설정
        if title == "후기 삭제" {
            cancelButton.setTitle("취소", for: .normal)
            actionButton.setTitle("삭제하기", for: .normal)
        } else if title == "후기 신고" {
            cancelButton.setTitle("돌아가기", for: .normal)
            actionButton.setTitle("신고하기", for: .normal)
        } else {
            // "완료" 팝업일 경우 (버튼 하나만 사용하거나 커스텀 가능)
            cancelButton.isHidden = true
            vLine.isHidden = true
            actionButton.setTitle("돌아가기", for: .normal)
            actionButton.setTitleColor(UIColor(named: "GOMS_Information", in: .module, compatibleWith: nil), for: .normal)
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
            $0.top.equalTo(titleLabel.snp.bottom).offset(10) // 간격 더 넓힘
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        hLine.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-44)
            $0.height.equalTo(1)
        }
        
        vLine.snp.makeConstraints {
            $0.top.equalTo(hLine.snp.top)
            $0.bottom.centerX.equalToSuperview()
            $0.width.equalTo(1)
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
