//
//  MainProfileView.swift
//  Feature
//
//  Created by 김준표 on 2/25/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit

import SnapKit
import Then

public final class MainProfileView: UIView {
    
    var isClockOn: Bool = UserDefaults.standard.bool(forKey: "isClockOn") {
            didSet {
                setLayout()
            }
        }
    
    // MARK: - Properties
    let nameLabel = UILabel().then {
        $0.textColor = .color.mainText.color
        $0.font = UIFont.suit(size: 19, weight: .semibold)
    }
    
    let studentInformationLabel = UILabel().then {
        $0.textColor = .color.sub2.color
        $0.font = UIFont.suit(size: 14, weight: .regular)
    }

    let profileStatus = UILabel().then {
        $0.text = ""
        $0.textColor = .color.mainText.color
        $0.font = UIFont.suit(size: 16, weight: .bold)
    }
    
    private let currentTime = CurrentTimeView(frame: CGRect(x: 0, y: 0, width: 140, height: 40))
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        addView()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure UI
    private func configureUI() {
        self.clipsToBounds = true
        self.layer.cornerRadius = 12
        self.backgroundColor = .color.gomsCardBackgroundColor.color
    }
    
    // MARK: - Add View
    private func addView() {
        [nameLabel, studentInformationLabel, profileStatus, currentTime].forEach { self.addSubview($0) }
    }
    
    // MARK: - Layout
    private func setLayout() {
        nameLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalToSuperview().inset(16)
            $0.height.equalTo(32)
        }
        
        studentInformationLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().inset(16)
            $0.height.equalTo(24)
        }
        
        profileStatus.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(28)
        }
    
        currentTime.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(12)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
    }
}
