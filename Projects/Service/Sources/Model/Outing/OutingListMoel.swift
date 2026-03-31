//
//  OutingListMoel.swift
//  Service
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation

public struct OutingListModel: Codable {
    public let items: [OutingListResponse]
}
public struct OutingListResponse: Codable {
    public let name: String
    public let grade: Int
    public let department: String
    public let outingAt: String
}
