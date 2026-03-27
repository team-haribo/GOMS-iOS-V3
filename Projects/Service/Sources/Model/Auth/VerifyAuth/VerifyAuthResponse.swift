//
//  VerifyAuthResponse.swift
//  Service
//
//  Created by 김준표 on 3/27/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation

public struct VerifyAuthResponse: Codable {
    public let verifiedToken: String
    public let verifiedTokenExpiresIn: String

    public init(
        verifiedToken: String,
        verifiedTokenExpiresIn: String
    ) {
        self.verifiedToken = verifiedToken
        self.verifiedTokenExpiresIn = verifiedTokenExpiresIn
    }
}
