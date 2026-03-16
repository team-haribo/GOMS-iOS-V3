//
//  MapReviewWriteViewModel.swift
//  Feature
//
//  Created by 김민선 on 3/15/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation

public final class MapReviewWriteViewModel {
    
    // MARK: - Properties
    
    private let maxTextCount = 100
    
    // 현재 입력된 텍스트
    public var currentText: String = "" {
        didSet {
            // 버튼 활성화 여부 업데이트 (1글자 이상일 때 true)
            onNextButtonStateChanged?(isButtonEnabled)
        }
    }
    
    // 버튼 활성화 상태 계산
    public var isButtonEnabled: Bool {
        return !currentText.isEmpty && currentText.count <= maxTextCount
    }
    
    // 글자 수 레이블에 표시할 텍스트
    public var limitText: String {
        return "\(currentText.count)/\(maxTextCount)"
    }
    
    // MARK: - Closures (VC와 연결용)
    
    public var onNextButtonStateChanged: ((Bool) -> Void)?
    
    // MARK: - Methods
    
    public func updateText(_ text: String) {
        // 최대 글자수 100자로 제한
        if text.count <= maxTextCount {
            currentText = text
        }
    }
}
