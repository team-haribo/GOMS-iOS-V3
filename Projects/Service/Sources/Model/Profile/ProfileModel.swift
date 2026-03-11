//
//  ProfileModel.swift
//  Service
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation

public struct ProfileModel: Decodable {
    let date: ProfileResponse
}

public struct ProfileResponse: Decodable {
    public let name: String
    public let grade: Int
    public let major: String
    public let gender: String
    public let authority: String
    public let profileUrl: String?
    public let lateCount: Int
    public let isOuting: Bool
    public let isBlackList: Bool
}
