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
    var authority: String?
    var major: String?
    var status: String?
    
    public init(grade: Int?, gender: String?, name: String?, authority: String?, major: String?, status: String?) {
        self.grade = grade
        self.gender = gender
        self.name = name
        self.authority = authority
        self.major = major
        self.status = status
    }
}
