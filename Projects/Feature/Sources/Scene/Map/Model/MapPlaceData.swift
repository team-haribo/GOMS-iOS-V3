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
    public let reviewId: Int
    public let name: String
    public let grade: Int
    public let department: String
    public let profileImageUrl: String
    public let content: String
    public let reviewedAt: String
    public let isMine: Bool?

    public init(
        reviewId: Int,
        name: String,
        grade: Int,
        department: String,
        profileImageUrl: String,
        content: String,
        reviewedAt: String,
        isMine: Bool
    ) {
        self.reviewId = reviewId
        self.name = name
        self.grade = grade
        self.department = department
        self.profileImageUrl = profileImageUrl
        self.content = content
        self.reviewedAt = reviewedAt
        self.isMine = isMine
    }

    private enum CodingKeys: String, CodingKey {
        case reviewId = "review_id"
        case name
        case grade
        case department
        case profileImageUrl
        case content
        case reviewedAt = "reviewed_at"
        case isMine = "is_mine"
    }
}
