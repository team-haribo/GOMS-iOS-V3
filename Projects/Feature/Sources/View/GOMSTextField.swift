//
//  GOMSTextField.swift
//  Feature
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit

public class GOMSTextField: UITextField {
    
    var placeholderString: String?
    
    let lightBackground = UIColor(red: 0.967, green: 0.97, blue: 0.973, alpha: 1).cgColor
    let darkBackground = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1).cgColor
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextField()
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    convenience init(frame: CGRect, placeholder: String?) {
        self.init(frame: frame)
        self.placeholderString = placeholder
        setupPlaceholder()
    }
    
    private func setupTextField() {
        self.backgroundColor = .color.surface.color
        self.font = .suit(size: 15, weight: .medium)
        self.clipsToBounds = true
        self.layer.cornerRadius = 8
        self.addPadding(paddingFrame: CGRect(x: 0, y: 0, width: 16, height: self.frame.height))
        self.autocapitalizationType = .none
        self.spellCheckingType = .no
    }
    
    private func setupPlaceholder() {
        if let placeholderText = placeholderString {
            self.placeholder = placeholderText
            self.setPlaceholderColor(.color.sub2.color)
        }
    }
    
    public override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.rightViewRect(forBounds: bounds)
        rect.origin.x -= 16
        return rect
    }
}
