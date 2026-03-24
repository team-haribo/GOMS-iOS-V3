//
//  GOMSSearchBar.swift
//  Feature
//
//  Created by 김민선 on 3/23/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit
import Then

public final class GOMSSearchBar: UIView {
    
    public let textField = UITextField().then {
        $0.backgroundColor = UIColor.color.surface.color
        $0.layer.cornerRadius = 12
        $0.textColor = UIColor.color.mainText.color
        $0.font = .suit(size: 16, weight: .medium)
        
        $0.attributedPlaceholder = NSAttributedString(
            string: "학교 검색",
            attributes: [
                .foregroundColor: UIColor.color.sub1.color,
                .font: UIFont.suit(size: 16, weight: .medium)
            ]
        )
    
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        $0.leftView = paddingView
        $0.leftViewMode = .always
        
        $0.autocapitalizationType = .none
        $0.spellCheckingType = .no
        $0.returnKeyType = .search
    }
    
    private let searchIcon = UIImageView().then {
        // 알려주신 Bundle.module 방식으로 수정
        $0.image = UIImage(named: "Search", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        $0.tintColor = UIColor.color.sub1.color
        $0.contentMode = .scaleAspectFit
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addView()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addView() {
        addSubview(textField)
        textField.addSubview(searchIcon)
    }
    
    private func setLayout() {
        textField.snp.makeConstraints {
            $0.edges.equalToSuperview() // 여기서 height 44 삭제 -> 밖에서 정해주는 52를 따르도록 수정
        }
        
        searchIcon.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(16)
            $0.width.height.equalTo(20)
        }
    }
}
