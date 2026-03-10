//
//  SignInRequest.swift
//  Service
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation

public struct SignInRequest: Codable {
    var email: String
    var password: String
    
    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}
