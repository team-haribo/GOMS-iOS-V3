//
//  MyReviewResponse.swift
//  Service
//
//  Created by 김준표 on 4/20/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

public struct MyReviewResponse: Decodable {
    public let reviews: [MyReview]
}

public struct MyReview: Decodable {
    public let reviewId: Int
    public let placeId: Int
    public let placeName: String
    public let categoryName: String
    public let address: String
    public let content: String
    public let reviewedAt: String
}
