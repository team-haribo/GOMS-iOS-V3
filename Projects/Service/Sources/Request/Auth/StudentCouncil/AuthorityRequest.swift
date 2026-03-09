//
//  AuthorityRequest.swift
//  Service
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation

public struct AuthorityRequest: Codable {
    var accountIdx: UUID
    var authority: String
    
    public init(accountIdx: UUID, authority: String) {
        self.accountIdx = accountIdx
        self.authority = authority
    }
}
