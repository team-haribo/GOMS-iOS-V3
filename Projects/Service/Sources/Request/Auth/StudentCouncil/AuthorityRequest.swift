//
//  AuthorityRequest.swift
//  Service
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation

public struct AuthorityRequest: Encodable {
    public let role: String
    
    public init(role: String) {
        self.role = role
    }
}
