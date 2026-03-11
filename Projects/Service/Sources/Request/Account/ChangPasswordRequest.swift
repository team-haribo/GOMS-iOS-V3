//
//  ChangPasswordRequest.swift
//  Service
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation

public struct NewPasswordRequest: Codable {
    var email: String
    var newPassword: String
    
    public init(email: String, newPassword: String) {
        self.email = email
        self.newPassword = newPassword
    }
}
