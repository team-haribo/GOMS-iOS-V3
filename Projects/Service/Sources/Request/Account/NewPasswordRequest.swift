//
//  NewPasswordRequest.swift
//  Service
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation

public struct ChangPasswordRequest: Codable {
    var password: String
    var newPassword: String
    
    public init(password: String, newPassword: String) {
        self.password = password
        self.newPassword = newPassword
    }
}
