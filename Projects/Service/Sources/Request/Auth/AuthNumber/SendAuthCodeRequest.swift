//
//  SendAuthCodeRequest.swift
//  Service
//
//  Created by 김준표 on 3/27/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation

public struct SendAuthCodeRequest: Codable {
    let email: String
    let purpose: String

    public init(email: String, purpose: String) {
        self.email = email
        self.purpose = purpose
    }
}
