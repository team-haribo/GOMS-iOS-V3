//
//  MapMockData.swift
//  Feature
//
//  Created by 김민선 on 3/22/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation

public enum MapMockData {
    public static let recentSearches = [
        "메가MGC커피 광주송정시장점",
        "메가MGC커피 광주송정시장점",
        "메가MGC커피 광주송정시장점",
        "메가MGC커피 광주송정시장점"
    ]
    
    public static let reviews: [MapReview] = []
    
    public static let detailExample = MapPlaceDetailData(
            title: "짬뽕관 광주송정선운점",
            category: "중식당",
            address: "광주 광산구 상무대로 277-1 1층",
            distance: "149m",
            time: "4분",
            reviewCount: reviews.count,
            recommendationCount: 17,
            reviews: reviews
        )
}
