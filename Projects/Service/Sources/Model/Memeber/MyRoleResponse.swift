//
//  MyRoleResponse.swift
//  Service
//
//  Created by 김준표 on 4/3/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation

public struct MyRoleResponse: Decodable {
    public let memberId: Int
    public let email: String
    public let name: String
    public let role: String
}
