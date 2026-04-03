//
//  OutingStatusResponse.swift
//  Service
//
//  Created by 김준표 on 4/3/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation

public struct OutingStatusResponse: Codable {
    public let memberId: Int
    public let status: String
    public let name: String
    public let grade: Int
    public let department: String
    public let lateCount: Int
}
