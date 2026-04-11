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

// MARK: - Place Data
public struct MapPlaceData: Codable {
    public let placeId: Int
    public let placeName: String
    public let address: String
    public let roadAddress: String
    public let latitude: Double
    public let longitude: Double
    public let categoryGroupName: String
    public let categoryName: String
    public let reviewCount: Int
    public let recommendCount: Int
    public let recommended: Bool

    public init(
        placeId: Int,
        placeName: String,
        address: String,
        roadAddress: String,
        latitude: Double,
        longitude: Double,
        categoryGroupName: String,
        categoryName: String,
        reviewCount: Int,
        recommendCount: Int,
        recommended: Bool
    ) {
        self.placeId = placeId
        self.placeName = placeName
        self.address = address
        self.roadAddress = roadAddress
        self.latitude = latitude
        self.longitude = longitude
        self.categoryGroupName = categoryGroupName
        self.categoryName = categoryName
        self.reviewCount = reviewCount
        self.recommendCount = recommendCount
        self.recommended = recommended
    }
}

// MARK: - Review Data
public struct MapReview: Codable {
    public let reviewId: Int // 오류 해결을 위해 추가됨
    public let name: String
    public let info: String
    public let content: String
    public let date: String
    public let isMine: Bool
    
    public init(
        reviewId: Int, // 생성자에도 추가
        name: String,
        info: String,
        content: String,
        date: String,
        isMine: Bool = false
    ) {
        self.reviewId = reviewId
        self.name = name
        self.info = info
        self.content = content
        self.date = date
        self.isMine = isMine
    }
}
