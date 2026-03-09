//
//  SearchStudentRequest.swift
//  Service
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation

public struct SearchStudentRequest: Codable {
    var grade: Int?
    var gender: String?
    var name: String?
    var isBlackList: Bool?
    var authority: String?
    var major: String?
    
    public init(grade: Int?, gender: String?, name: String?, isBlackList: Bool?, authority: String?, major: String?) {
        self.grade = grade
        self.gender = gender
        self.name = name
        self.isBlackList = isBlackList
        self.authority = authority
        self.major = major
    }
}
