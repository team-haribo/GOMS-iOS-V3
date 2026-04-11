//
//  StudentListModel.swift
//  Service
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation

public struct StudentListModel: Decodable {
    public let students: [Student]
}

public struct Student: Decodable {
    public let memberId: Int
    public let name: String
    public let grade: Int
    public let department: String
    public let role: String
    public let status: String
    public let profileImageUrl: String?
}
