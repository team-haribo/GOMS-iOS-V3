//
//  StudentMockData.swift
//  Feature
//
//  Created by 김민선 on 3/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation

struct StudentMockData {
    static let students: [UserData] = [
        UserData(id: 1, name: "김민솔", profileImageURL: nil, gender: "FEMALE", grade: 8, major: "AI", authority: "ROLE_ADMIN", isBlackList: false, isOuting: false),
        UserData(id: 2, name: "이준서", profileImageURL: nil, gender: "MALE", grade: 8, major: "iOS", authority: "ROLE_STUDENT", isBlackList: true, isOuting: false),
        UserData(id: 3, name: "박지민", profileImageURL: nil, gender: "FEMALE", grade: 8, major: "SW", authority: "ROLE_STUDENT", isBlackList: false, isOuting: true),
        UserData(id: 4, name: "최수호", profileImageURL: nil, gender: "MALE", grade: 7, major: "IoT", authority: "ROLE_ADMIN", isBlackList: false, isOuting: false),
        UserData(id: 5, name: "정다은", profileImageURL: nil, gender: "FEMALE", grade: 8, major: "AI", authority: "ROLE_STUDENT", isBlackList: true, isOuting: false),
        UserData(id: 6, name: "강현우", profileImageURL: nil, gender: "MALE", grade: 7, major: "SW", authority: "ROLE_STUDENT", isBlackList: false, isOuting: false),
        UserData(id: 7, name: "윤서연", profileImageURL: nil, gender: "FEMALE", grade: 8, major: "iOS", authority: "ROLE_STUDENT", isBlackList: false, isOuting: false),
        UserData(id: 8, name: "한재희", profileImageURL: nil, gender: "MALE", grade: 7, major: "IoT", authority: "ROLE_STUDENT", isBlackList: true, isOuting: false),
        UserData(id: 9, name: "임지우", profileImageURL: nil, gender: "FEMALE", grade: 8, major: "AI", authority: "ROLE_STUDENT", isBlackList: false, isOuting: false)
    ]
}
