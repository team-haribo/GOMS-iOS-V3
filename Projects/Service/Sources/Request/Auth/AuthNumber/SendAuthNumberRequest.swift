//
//  SendAuthNumberRequest.swift
//  Service
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation

public struct SendAuthCodeRequest: Codable {
    var email: String
    var emailStatus: String
    
    public init(email: String, emailStatus: String) {
        self.email = email
        self.emailStatus = emailStatus
    }
}
