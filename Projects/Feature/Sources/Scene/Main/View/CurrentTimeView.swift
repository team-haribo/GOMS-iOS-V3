//
//  CurrentTimeView.swift
//  Feature
//
//  Created by 김준표 on 2/25/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit
import Then

final class CurrentTimeView: UIView {
    // MARK: Propertices
    var amPmTime: String = ""
    var hourTime: String = ""
    var minuteTime: String = ""
    var secondTime: String = ""
    
    var amPmLabel = UILabel().then {
        $0.text = ""
        $0.textColor = .color.sub2.color
        $0.font = UIFont.systemFont(ofSize: 18, weight: .bold)
    }
    
    var currentHourLabel = UILabel().then {
        $0.text = ""
        $0.textColor = .color.sub2.color
        $0.font = UIFont.systemFont(ofSize: 24, weight: .bold)
    }
    
    let colonLabel1 = UILabel().then {
        $0.text = ":"
        $0.textColor = .color.sub2.color
        $0.font = UIFont.systemFont(ofSize: 24, weight: .regular)
    }
    
    var currentMinuteLabel = UILabel().then {
        $0.text = ""
        $0.textColor = .color.sub2.color
        $0.font = UIFont.systemFont(ofSize: 24, weight: .bold)
    }
    
    let colonLabel2 = UILabel().then {
        $0.text = ":"
        $0.textColor = .color.sub2.color
        $0.font = UIFont.systemFont(ofSize: 24, weight: .regular)
    }
    
    var currentSecondLabel = UILabel().then {
        $0.text = ""
        $0.textColor = .color.sub2.color
        $0.font = UIFont.systemFont(ofSize: 24, weight: .bold)
    }

    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        addView()
        setLayout()
        setTime()
        startTimer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: AddView
    private func addView() {
        [amPmLabel, currentHourLabel, colonLabel1, currentMinuteLabel, colonLabel2, currentSecondLabel].forEach {
            self.addSubview($0)
        }
    }
    
    // MARK: SetLayout
    private func setLayout() {
        amPmLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(currentHourLabel.snp.leading).offset(-4)
        }
        
        currentHourLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(colonLabel1.snp.leading).offset(-4)
        }
        
        colonLabel1.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(currentMinuteLabel.snp.leading).offset(-4)
        }
        
        currentMinuteLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(colonLabel2.snp.leading).offset(-4)
        }
        
        colonLabel2.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(currentSecondLabel.snp.leading).offset(-4)
        }
        
        currentSecondLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-16)
        }
    }
    
    // MARK: SetTime
    @objc func setTime() {
        let nowDate = Date()
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "a"
        amPmTime = dateFormatter.string(from: nowDate)
        
        dateFormatter.dateFormat = "hh"
        hourTime = dateFormatter.string(from: nowDate)
        
        dateFormatter.dateFormat = "mm"
        minuteTime = dateFormatter.string(from: nowDate)
        
        dateFormatter.dateFormat = "ss"
        secondTime = dateFormatter.string(from: nowDate)
        
        amPmLabel.text = amPmTime
        currentHourLabel.text = hourTime
        currentMinuteLabel.text = minuteTime
        currentSecondLabel.text = secondTime
    }
    
    func startTimer() {
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(setTime), userInfo: nil, repeats: true)
    }
}
