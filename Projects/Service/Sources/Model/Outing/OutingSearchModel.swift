//
//  OutingSearchModel.swift
//  Service
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation

public struct OutingSearchModel: Codable {
    let data: OutingSearchResponse
}

public struct OutingSearchResponse: Codable {
    public let accountIdx: UUID
    public let name: String
    public let major: String
    public let grade: Int
    public let gender: String
    public let profileUrl: String?
    public let createdTime: String
}
