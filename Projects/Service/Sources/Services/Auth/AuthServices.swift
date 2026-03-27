//
//  AuthServices.swift
//  Service
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation
import Moya

public enum AuthServices {
    case signUp(param: SignUpRequest)
    case signIn(param: SignInRequest)
    case refreshToken(refreshToken: String)
    case sendAuthCode(param: SendAuthCodeRequest)
    case verifyAuthNumber(email: String, code: String)
    case logoutToken(refreshToken: String)
}

extension AuthServices: TargetType {

    public var baseURL: URL {
        guard
            let urlString = Bundle.main.infoDictionary?["SchoolBaseURL"] as? String,
            let url = URL(string: urlString)
        else {
            fatalError("AuthAPI URL을 불러올 수 없습니다.")
        }
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
        }
    }

    public var method: Moya.Method {
        switch self {
        case .signUp,
             .signIn,
             .sendAuthCode,
             .verifyAuthNumber:
            return .post

        case .refreshToken:
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

        case let .verifyAuthNumber(email, code):
            return .requestJSONEncodable([
                "email": email,
                "code": code,
                "purpose": "SIGNUP"
            ])

        case .logoutToken:
            return .requestPlain
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
