//
//  MapReview.swift
//  Feature
//
//  Created by 김준표 on 4/16/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

struct MapReview: Decodable {
    let reviewId: Int
    let name: String
    let grade: Int
    let department: String
    let profileImageUrl: String
    let content: String
    let reviewedAt: String

    enum CodingKeys: String, CodingKey {
        case reviewId = "review_id"
        case name
        case grade
        case department
        case profileImageUrl
        case content
        case reviewedAt = "reviewed_at"
    }
}
