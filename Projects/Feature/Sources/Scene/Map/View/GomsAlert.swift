//
//  GomsAlert.swift
//  Feature
//
//  Created by 김민선 on 2/21/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit
import Then

// MARK: - 디자인 전용 클래스
private class GomsAlertView: UIView {
    let containerView = UIView().then {
        $0.backgroundColor = UIColor(red: 37/255, green: 37/255, blue: 37/255, alpha: 0.82)
        $0.layer.cornerRadius = 14
        $0.clipsToBounds = true
    }
    
    let titleLabel = UILabel().then {
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 17, weight: .bold)
        $0.textAlignment = .center
    }
    
    let messageLabel = UILabel().then {
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 13, weight: .regular)
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    let horizontalLine = UIView().then { $0.backgroundColor = .white.withAlphaComponent(0.1) }
    let verticalLine = UIView().then { $0.backgroundColor = .white.withAlphaComponent(0.1) }
    
    let leftButton = UIButton().then {
        $0.setTitleColor(UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1), for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 17)
    }
    
    let rightButton = UIButton().then {
        $0.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
    }
    
    init(title: String, message: String, leftTitle: String?, rightTitle: String, rightColor: UIColor) {
        super.init(frame: .zero)
        self.backgroundColor = .black.withAlphaComponent(0.4)
        
        titleLabel.text = title
        messageLabel.text = message
        rightButton.setTitle(rightTitle, for: .normal)
        rightButton.setTitleColor(rightColor, for: .normal)
        
        addSubview(containerView)
        [titleLabel, messageLabel, horizontalLine, leftButton, rightButton, verticalLine].forEach { containerView.addSubview($0) }
        
        containerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(270)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        horizontalLine.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(0.5)
        }
        
        if let left = leftTitle {
            leftButton.setTitle(left, for: .normal)
            leftButton.snp.makeConstraints {
                $0.top.equalTo(horizontalLine.snp.bottom)
                $0.leading.bottom.equalToSuperview()
                $0.width.equalTo(135)
                $0.height.equalTo(44)
            }
            verticalLine.snp.makeConstraints {
                $0.top.equalTo(horizontalLine.snp.bottom)
                $0.bottom.centerX.equalToSuperview()
                $0.width.equalTo(0.5)
            }
            rightButton.snp.makeConstraints {
                $0.top.equalTo(horizontalLine.snp.bottom)
                $0.trailing.bottom.equalToSuperview()
                $0.width.equalTo(135)
                $0.height.equalTo(44)
            }
        } else {
            leftButton.isHidden = true
            verticalLine.isHidden = true
            rightButton.snp.makeConstraints {
                $0.top.equalTo(horizontalLine.snp.bottom)
                $0.leading.trailing.bottom.equalToSuperview()
                $0.height.equalTo(44)
            }
        }
    }
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - 실제로 사용할 인터페이스
public class GomsAlert {
    public static func show(
        in vc: UIViewController,
        title: String,
        message: String,
        leftTitle: String? = nil,
        rightTitle: String,
        rightColor: UIColor = .systemBlue,
        completion: @escaping () -> Void = {}
    ) {
        let alert = GomsAlertView(title: title, message: message, leftTitle: leftTitle, rightTitle: rightTitle, rightColor: rightColor)
        vc.view.addSubview(alert)
        alert.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        // 오류 해결 지점: (action: UIAction) 타입을 명시적으로 적어줌
        alert.leftButton.addAction(UIAction { (action: UIAction) in
            alert.removeFromSuperview()
        }, for: .touchUpInside)
        
        alert.rightButton.addAction(UIAction { (action: UIAction) in
            alert.removeFromSuperview()
            completion()
        }, for: .touchUpInside)
    }
}
