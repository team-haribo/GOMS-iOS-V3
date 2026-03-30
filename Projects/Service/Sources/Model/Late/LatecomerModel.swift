//
//  LatecomerModel.swift
//  Service
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation

public struct LatecomerModel: Codable {
    public let items: [LatecomerResponse]
}

public struct LatecomerResponse: Codable {
    public let name: String
    public let grade: Int
    public let department: Major
}
