//
//  GOMSSwitch.swift
//  Feature
//
//  Created by 김민선 on 4/17/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit
import Then

public final class GOMSSwitch: UIControl {
    public var onTintColor: UIColor = UIColor.color.admin.color
    
    private let toggleThumb = UIView().then {
        $0.backgroundColor = UIColor.color.gomsLine.color
        $0.layer.cornerRadius = 14
        $0.isUserInteractionEnabled = false
    }
      
    public var isOn: Bool = false {
        didSet { setupState() }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        self.snp.makeConstraints {
            $0.width.equalTo(52)
            $0.height.equalTo(32)
        }
        self.layer.cornerRadius = 16
        self.backgroundColor = UIColor.color.gomsSwitchBg.color
        
        addSubview(toggleThumb)
        toggleThumb.snp.makeConstraints {
            $0.size.equalTo(28)
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(2)
        }
        self.addTarget(self, action: #selector(toggle), for: .touchUpInside)
    }
    
    @objc private func toggle() {
        isOn.toggle()
        sendActions(for: .valueChanged)
    }
    
    private func setupState() {
        let color = isOn ? onTintColor : UIColor.color.gomsSwitchBg.color
        let xPosition = isOn ? 20 : 0
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
            self.backgroundColor = color
            self.toggleThumb.transform = CGAffineTransform(translationX: CGFloat(xPosition), y: 0)
        }
    }
}
