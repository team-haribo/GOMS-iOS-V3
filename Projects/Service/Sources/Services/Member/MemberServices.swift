//
//  MemberServices.swift
//  Service
//
//  Created by 김준표 on 4/3/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation
import Moya

public enum MemberServices {
    case myRole(authorization: String)
    case withdraw(password: String, authorization: String)
}

extension MemberServices: TargetType {
    public var baseURL: URL {
        guard let urlString = Bundle.main.infoDictionary?["SchoolBaseURL"] as? String,
              let url = URL(string: urlString) else {
            fatalError("MemberAPI URL을 불러올 수 없습니다.")
        }
        return url
    }

    public var path: String {
        switch self {
        case .myRole:
            return "/api/v3/member/myrole"
        case .withdraw:
            return "/api/v3/member/withdraw"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .myRole:
            return .get
        case .withdraw:
            return .delete
        }
    }

    public var task: Task {
        switch self {
        case .myRole:
            return .requestPlain

        case let .withdraw(password, _):
            return .requestParameters(
                parameters: ["password": password],
                encoding: JSONEncoding.default
            )
        }
    }

    public var headers: [String: String]? {
        switch self {
        case .myRole(let authorization),
             .withdraw(_, let authorization):
            return [
                "Content-Type": "application/json",
                "Authorization": authorization
            ]
        }
    }

    public var sampleData: Data {
        return Data()
    }
}
