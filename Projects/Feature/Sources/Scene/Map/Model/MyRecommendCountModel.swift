//
//  MyRecommendCountModel.swift
//  Feature
//
//  Created by 김민선 on 4/10/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation

// MARK: - 장소 동기화 Response (POST /api/v3/place/sync)
public struct PlaceSyncResponse: Codable {
    public let createdCount: Int
    public let updatedCount: Int
    public let deactivatedCount: Int
    public let totalFetchedCount: Int
}

// MARK: - 장소 추천 상태 Response (POST/DELETE 추천 및 추천 취소용)
public struct PlaceRecommendResponse: Codable {
    public let recommended: Bool
}
