//
//  AuthServices.swift
//  Service
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation
import Moya

public struct ResetPasswordRequest: Encodable {
    public let email: String
    public let verifiedToken: String
    public let newPassword: String

    public init(email: String, verifiedToken: String, newPassword: String) {
        self.email = email
        self.verifiedToken = verifiedToken
        self.newPassword = newPassword
    }
}

public enum AuthServices {
    case signUp(param: SignUpRequest)
    case signIn(param: SignInRequest)
    case refreshToken(refreshToken: String)
    case sendAuthCode(param: SendAuthCodeRequest)
    case verifyAuthNumber(email: String, code: String, purpose: String)
    case logoutToken(refreshToken: String)
    case resetPassword(param: ResetPasswordRequest)
}

extension AuthServices: TargetType {

    public var baseURL: URL {
        guard let urlString = Bundle.main.infoDictionary?["SchoolBaseURL"] as? String else {
            fatalError("SchoolBaseURL 찾을 수 없습니다")
        }

        print("atuh baseURL string:", urlString)

        guard let url = URL(string: urlString) else {
            fatalError("auth Invalid baseURL string: \(urlString)")
        }

        print(" auth baseURL URL:", url)

        return url
    }

    public var path: String {
        switch self {
        case .signUp:
            return "/api/v3/auth/signup"

        case .signIn:
            return "/api/v3/auth/signin"

        case .refreshToken:
            return "/api/v3/auth/reissue"

        case .sendAuthCode:
            return "/api/v3/auth/email-verifications/send"

        case .verifyAuthNumber:
            return "/api/v3/auth/email-verifications/confirm"

        case .logoutToken:
            return "/api/v3/auth/signout"

        case .resetPassword:
            return "/api/v3/auth/password"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .signUp,
             .signIn,
             .sendAuthCode,
             .verifyAuthNumber:
            return .post

        case .refreshToken,
             .resetPassword:
            return .patch

        case .logoutToken:
            return .delete
        }
    }

    public var sampleData: Data {
        Data()
    }

    public var task: Task {
        switch self {

        case let .signUp(param):
            return .requestJSONEncodable(param)

        case let .signIn(param):
            return .requestJSONEncodable(param)

        case let .sendAuthCode(param):
            return .requestJSONEncodable(param)

        case .refreshToken:
            return .requestPlain

        case let .verifyAuthNumber(email, code, purpose):
            return .requestJSONEncodable([
                "email": email,
                "code": code,
                "purpose": purpose
            ])

        case .logoutToken:
            return .requestPlain

        case let .resetPassword(param):
            return .requestJSONEncodable(param)
        }
    }

    public var headers: [String: String]? {
        switch self {

        case let .refreshToken(refreshToken),
             let .logoutToken(refreshToken):
            return [
                "Content-Type": "application/json",
                "RefreshToken": "Bearer \(refreshToken)"
            ]

        default:
            return [
                "Content-Type": "application/json"
            ]
        }
    }
}
