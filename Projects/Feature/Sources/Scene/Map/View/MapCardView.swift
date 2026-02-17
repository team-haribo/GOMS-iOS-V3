//
//  MapCardView.swift
//  Feature
//
//  Created by 김민선 on 2/17/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit
import Then

final class MapCardView: UIView {
    
    init(type: CardType) {
        super.init(frame: .zero)
        setupCard(type: type)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupCard(type: CardType) {
        self.backgroundColor = UIColor(red: 31/255, green: 31/255, blue: 31/255, alpha: 1)
        self.layer.cornerRadius = 8
        
        let actionButton = UIButton().then {
            let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
            let primaryColor = UIColor(red: 255/255, green: 165/255, blue: 0/255, alpha: 1)
            
            if type == .reviewed {
                $0.setImage(UIImage(systemName: "trash", withConfiguration: config), for: .normal)
                $0.tintColor = .systemRed
            } else {
                $0.setImage(UIImage(systemName: "heart", withConfiguration: config), for: .normal)
                $0.setImage(UIImage(systemName: "heart.fill", withConfiguration: config), for: .selected)
                $0.tintColor = (type == .recommended) ? primaryColor : .lightGray
                if type == .recommended { $0.isSelected = true }
                
                $0.addAction(UIAction { action in
                    guard let button = action.sender as? UIButton else { return }
                    button.isSelected.toggle()
                    button.tintColor = button.isSelected ? primaryColor : .lightGray
                }, for: .touchUpInside)
            }
        }
        
        addSubview(actionButton)
        actionButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-16)
            $0.size.equalTo(24)
        }
    }
}
