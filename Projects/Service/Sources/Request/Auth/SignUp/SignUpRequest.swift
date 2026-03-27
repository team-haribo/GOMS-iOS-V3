//
//  SignUpRequest.swift
//  Service
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation

public struct SignUpRequest: Codable {
    let email: String
    let verifiedToken: String
    let password: String
    let name: String
    let grade: Int
    let department: Major
    let gender: Gender

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
