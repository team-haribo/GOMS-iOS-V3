//
//  LatecomerListModel.swift
//  Service
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation

public struct LatecomerListModel: Codable {
    let data: LatecomerListResponse
}

public struct LatecomerListResponse: Codable {
    public let accountIdx: UUID
    public let name: String
    public let grade: Int
    public let gender: String
    public let major: String
    public let profileUrl: String?
}
