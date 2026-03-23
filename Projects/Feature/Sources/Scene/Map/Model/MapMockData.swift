//
//  MapMockData.swift
//  Feature
//
//  Created by 김민선 on 3/22/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation

public enum MapMockData {
    // 최근 검색어 더미 데이터
    public static let recentSearches = [
        "메가MGC커피 광주송정시장점",
        "메가MGC커피 광주송정시장점",
        "메가MGC커피 광주송정시장점",
        "메가MGC커피 광주송정시장점"
    ]
    
    // 리뷰 더미 데이터
    public static let reviews: [MapReview] = [
        MapReview(name: "김민솔", info: "8기 | AI", content: "굳굳", date: "26.02.12", isMine: true),
        MapReview(name: "권재현", info: "8기 | AI", content: "매워요", date: "26.02.12", isMine: false),
        MapReview(name: "김태은", info: "8기 | AI", content: "맛있어요", date: "26.02.12", isMine: false),
        MapReview(name: "이주언", info: "8기 | AI", content: "가성비 좋음", date: "26.02.12", isMine: false)
    ]
    
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
