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
                timeLabel.isHidden = !isClockOn
                timeLabel.alpha = 0.6

                updateStudentInfoLayout()
                setNeedsLayout()
                layoutIfNeeded()
             
            }
        }
    var isAdmin: Bool = false {
        didSet {
            updateStyle()
        }
    }
    
    // MARK: - Properties
    let profileImageView = UIImageView().then {
        $0.image = .image.gomsBasicProfile.image
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
    }
    
    let lateCountLabel = UILabel().then {
        $0.textColor = .color.sub1.color
        $0.font = UIFont.suit(size: 15, weight: .medium)
    }
    
    let nameLabel = UILabel().then {
        $0.textColor = .color.mainText.color
        $0.font = UIFont.suit(size: 20, weight: .bold)
    }
    
    let studentInformationLabel = UILabel().then {
        $0.textColor = .color.sub2.color
        $0.font = UIFont.suit(size: 14, weight: .medium)
    }

    private func updateStyle() {
        if isAdmin {
            studentInformationLabel.font = UIFont.suit(size: 15, weight: .medium)
        } else {
            studentInformationLabel.font = UIFont.suit(size: 15, weight: .medium)
        }
    }

    let profileStatus = UILabel().then {
        $0.text = ""
        $0.textColor = .color.sub1.color
        $0.font = UIFont.suit(size: 16, weight: .semibold)
    }
    
    let timeLabel = UILabel().then {
        $0.textColor = .color.sub2.color
        $0.font = UIFont.suit(size: 24, weight: .heavy)
        $0.isHidden = true
    }

    private var timer: Timer?
    
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        addView()
        setLayout()
        updateStyle()
        startClock()
    
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure UI
    private func configureUI() {
        self.clipsToBounds = true
        self.layer.cornerRadius = 12
        self.backgroundColor = .color.surface.color
    }
    
    // MARK: - Add View
    private func addView() {
        [nameLabel, studentInformationLabel, lateCountLabel, profileStatus, timeLabel].forEach { self.addSubview($0) }
    }
    
    // MARK: - Layout
    private func setLayout() {
        

        nameLabel.snp.remakeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalToSuperview().inset(16)
        }

        updateStudentInfoLayout()

        lateCountLabel.snp.remakeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.lessThanOrEqualToSuperview().inset(16)
            $0.top.equalTo(nameLabel.snp.bottom).offset(4)
        }

        profileStatus.snp.remakeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.trailing.equalToSuperview().inset(16)
        }

        timeLabel.snp.remakeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(profileStatus.snp.bottom).offset(2)
        }

    
        timeLabel.isHidden = !isClockOn
        
    }

    private func updateStudentInfoLayout() {
        studentInformationLabel.snp.remakeConstraints {

            if isAdmin {
               
                $0.leading.equalTo(nameLabel)
                $0.top.equalTo(nameLabel.snp.bottom).offset(4)
                $0.trailing.lessThanOrEqualTo(profileStatus.snp.leading).offset(-8)

            } else {
                if isClockOn {
                    
                    $0.leading.equalTo(nameLabel.snp.trailing).offset(8)
                    $0.centerY.equalTo(nameLabel)
                    $0.trailing.lessThanOrEqualTo(profileStatus.snp.leading).offset(-8)
                } else {
                  
                    $0.leading.equalTo(nameLabel)
                    $0.top.equalTo(nameLabel.snp.bottom).offset(4)
                    $0.trailing.lessThanOrEqualTo(profileStatus.snp.leading).offset(-8)
                }
            }
        }
    }

    private func startClock() {
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            let formatter = DateFormatter()
            formatter.dateFormat = "a h : mm : ss"
            formatter.locale = Locale(identifier: "en_US")
            self?.timeLabel.text = formatter.string(from: Date())
        }
    }

    deinit {
        timer?.invalidate()
    }
}
