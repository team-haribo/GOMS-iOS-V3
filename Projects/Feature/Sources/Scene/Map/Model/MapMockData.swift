//
//  MapMockData.swift
//  Feature
//
//  Created by 김민선 on 3/22/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation

// MARK: - Map Mock Data
public enum MapMockData {
    public static let recentSearches = [
        "메가MGC커피 광주송정시장점",
        "메가MGC커피 광주송정시장점",
        "메가MGC커피 광주송정시장점",
        "메가MGC커피 광주송정시장점"
    ]
    
    public static let reviews: [MapReview] = []
    
    public static let detailExample = MapPlaceDetailModel(
        placeId: 1,
        placeName: "짬뽕관 광주송정선운점",
        address: "광주 광산구 상무대로 277-1 1층",
        roadAddress: "광주 광산구 상무대로 277-1",
        latitude: 35.137,
        longitude: 126.791,
        categoryGroupName: "음식점",
        categoryName: "중식당",
        phone: "062-123-4567",
        placeUrl: "http://place.com/1",
        reviewCount: 0,
        recommendCount: 17,
        recommended: true
    )
}
