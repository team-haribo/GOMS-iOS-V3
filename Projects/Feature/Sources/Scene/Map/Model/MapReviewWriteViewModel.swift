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
    
    public var currentText: String = "" {
        didSet {
            onNextButtonStateChanged?(isButtonEnabled)
        }
    }
    
    public var isButtonEnabled: Bool {
        return !currentText.isEmpty && currentText.count <= maxTextCount
    }
    
    public var limitText: String {
        return "\(currentText.count)/\(maxTextCount)"
    }
    
    // MARK: - Closures (VC와 연결용)
    public var onNextButtonStateChanged: ((Bool) -> Void)?
    public var onReviewSuccess: (() -> Void)?
    
    // MARK: - Methods
    public func updateText(_ text: String) {
        if text.count <= maxTextCount {
            currentText = text
        }
    }
    
    public func postReview() {
        
        print("서버로 후기 전송 시도: \(currentText)")
        
        // API 통신이 성공했다는 가정하에 콜백 호출
        // 실제 연동 시에는 네트워크 통신 closure 내부(success 블록)에서 호출
        self.onReviewSuccess?()
    }
}
