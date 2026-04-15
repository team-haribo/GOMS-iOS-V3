//
//  MapReviewWriteViewModel.swift
//  Feature
//
//  Created by 김민선 on 3/15/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation
import Service
import Moya

public final class MapReviewWriteViewModel {
    
    // MARK: - Properties
    private let placeProvider = MoyaProvider<PlaceServices>()
    private let maxTextCount = 100
    private let placeId: Int
    
    private var accessToken: String {
        guard let token = KeyChain.shared.read(key: Const.KeyChainKey.accessToken) else {
            return ""
        }
        return "Bearer \(token)"
    }
    
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
    public var onErrorOccurred: ((String) -> Void)?
    
    // MARK: - Init
    public init(placeId: Int) {
        self.placeId = placeId
    }
    
    // MARK: - Methods
    public func updateText(_ text: String) {
        if text.count <= maxTextCount {
            currentText = text
        }
    }
    
    public func postReview() {
        guard isButtonEnabled else { return }
        
        // MARK: - PlaceServices의 정의에 맞춰 .writeReview로 수정 완료
        placeProvider.request(.writeReview(placeId: placeId, content: currentText, authorization: accessToken)) { [weak self] result in
            switch result {
            case .success(let response):
                if (200...299).contains(response.statusCode) {
                    print("서버로 후기 전송 성공!")
                    self?.onReviewSuccess?()
                } else {
                    print("서버 전송 실패: \(response.statusCode)")
                    self?.onErrorOccurred?("리뷰 등록에 실패했습니다.")
                }
            case .failure(let error):
                print("네트워크 오류: \(error.localizedDescription)")
                self?.onErrorOccurred?("서버와의 연결이 원활하지 않습니다.")
            }
        }
    }
}
