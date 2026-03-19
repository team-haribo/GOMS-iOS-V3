//
//  MapPlaceData.swift
//  Feature
//
//  Created by 김민선 on 3/13/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation

public struct MapReview {
    public let name: String
    public let info: String
    public let content: String
    public let date: String
    
    public init(name: String, info: String, content: String, date: String) {
        self.name = name
        self.info = info
        self.content = content
        self.date = date
    }
}

public struct MapPlaceDetailData {
    public let title: String
    public let category: String
    public let address: String
    public let distance: String
    public let time: String
    public let reviewCount: Int
    public let recommendationCount: Int
    public let reviews: [MapReview]
    
    public init(title: String, category: String, address: String, distance: String, time: String, reviewCount: Int, recommendationCount: Int, reviews: [MapReview]) {
        self.title = title
        self.category = category
        self.address = address
        self.distance = distance
        self.time = time
        self.reviewCount = reviewCount
        self.recommendationCount = recommendationCount
        self.reviews = reviews
    }
}
