//
//  MapPlaceDetailModel.swift
//  Feature
//
//  Created by 김민선 on 4/9/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation

// MARK: - Place Detail Data
public struct MapPlaceDetailModel: Codable {
    public let placeId: Int
    public let placeName: String
    public let address: String
    public let roadAddress: String
    public let latitude: Double
    public let longitude: Double
    public let categoryGroupName: String
    public let categoryName: String
    public let phone: String
    public let placeUrl: String
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
        phone: String,
        placeUrl: String,
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
        self.phone = phone
        self.placeUrl = placeUrl
        self.reviewCount = reviewCount
        self.recommendCount = recommendCount
        self.recommended = recommended
    }
}
