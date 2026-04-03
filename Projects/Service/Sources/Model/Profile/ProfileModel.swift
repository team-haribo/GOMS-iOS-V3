//
//  ProfileModel.swift
//  Service
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation

public struct ProfileResponse {
    public let name: String
    public let grade: Int
    public let department: String
    public let authority: String
    public let lateCount: Int
    public let isOuting: Bool

    public init(
        name: String,
        grade: Int,
        department: String,
        authority: String,
        lateCount: Int,
        isOuting: Bool
    ) {
        self.name = name
        self.grade = grade
        self.department = department
        self.authority = authority
        self.lateCount = lateCount
        self.isOuting = isOuting
    }
}
