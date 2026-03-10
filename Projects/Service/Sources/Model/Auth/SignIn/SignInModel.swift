//
//  SignInModel.swift
//  Service
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation

public struct SignInModel: Codable {
    public let data: SignInResponse?
}

public struct SignInResponse: Codable {
    public let accessToken: String
    public let refreshToken: String
    public let accessTokenExp: String
    public let refreshTokenExp: String
    public let authority: String
}
