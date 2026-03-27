//
//  SignUpRequest.swift
//  Service
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation

public struct SignUpRequest: Codable {
    var email: String
    var verifiedToken: String
    var password: String
    var name: String
    var grade: Int
    var department: Major
    var gender: Gender
    
    public init(
        email: String,
        verifiedToken: String,
        password: String,
        name: String,
        grade: Int,
        department: Major,
        gender: Gender
    ) {
        self.email = email
        self.verifiedToken = verifiedToken
        self.password = password
        self.name = name
        self.grade = grade
        self.department = department
        self.gender = gender
    }
}
