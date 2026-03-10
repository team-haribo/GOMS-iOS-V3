//
//  GOMSTextFieldButton.swift
//  Feature
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit

public class GOMSTextFieldButton: UIButton {

    init(frame: CGRect, title: String) {
        super.init(frame: frame)
        setButton(withTitle: title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setButton(withTitle title: String) {
        setButtonBackgroundColor(lightModeColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0.05), darkModeColor: UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1))
        setTitle(title, for: .normal)
        setTitleColor(.color.sub2.color, for: .normal)
        titleLabel?.font = .suit(size: 16, weight: .regular)
        layer.masksToBounds = true
        layer.cornerRadius = 12
        contentHorizontalAlignment = .leading
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
}
