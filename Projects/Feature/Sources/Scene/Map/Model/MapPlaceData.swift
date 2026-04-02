//
//  MapPlaceData.swift
//  Feature
//
//  Created by 김민선 on 3/13/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation

// MARK: - Search Response
public struct MapPlaceResponse: Codable {
    public let places: [MapPlaceData]
    
    public init(places: [MapPlaceData]) {
        self.places = places
    }
}

// MARK: - Place Data (검색 목록용)
public struct MapPlaceData: Codable {
    public let latitude: Double
    public let longitude: Double
    public let placeId: Int
    public let reviewCount: Int
    public let recommendCount: Int
    public let recommended: Bool

    public init(latitude: Double, longitude: Double, placeId: Int, reviewCount: Int, recommendCount: Int, recommended: Bool) {
        self.latitude = latitude
        self.longitude = longitude
        self.placeId = placeId
        self.reviewCount = reviewCount
        self.recommendCount = recommendCount
        self.recommended = recommended
    }
}

// MARK: - Place Detail Data (상세 페이지용)
public struct MapPlaceDetailData: Codable {
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

// MARK: - Review Data
public struct MapReview: Codable {
    public let name: String
    public let info: String
    public let content: String
    public let date: String
    public let isMine: Bool
    
    public init(name: String, info: String, content: String, date: String, isMine: Bool = false) {
        self.name = name
        self.info = info
        self.content = content
        self.date = date
        self.isMine = isMine
    }
}
