//
//  StudentListModel.swift
//  Service
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation

public struct StudentListModel: Codable {
    public let data: StudentListResponse
}

public struct StudentListResponse: Codable {
    public let accountIdx: UUID
    public let name: String
    public let major: String
    public let grade: Int
    public let gender: String
    public let profileUrl: String?
    public let authority: String
    public let isBlackList: Bool
    public let isOuting: Bool
}
