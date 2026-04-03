//
//  OutingServices.swift
//  Service
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation
import Moya

public enum OutingServices {
    case outingStatus(authorization: String)
    case outingList(authorization: String)
    case outingSearch(name: String, authorization: String)
    case outingCount(authorization: String)
    case outingOut(uuid: String, exp: Int, authorization: String)
    case outingIn(uuid: String, exp: Int, authorization: String)
}

extension OutingServices: TargetType {
    public var baseURL: URL {
        guard let urlString = Bundle.main.infoDictionary?["SchoolBaseURL"] as? String,
              let url = URL(string: urlString) else {
            fatalError("OutingAPIㅣURL을 불러올 수 없습니다.")
        }
        return url
    }

    public var path: String {
        switch self {
        case .outingStatus:
            return "/api/v3/outing/status"
        case .outingList:
            return "/api/v3/outing/list"
        case .outingSearch:
            return "/api/v3/outing/search"
        case .outingCount:
            return "/api/v3/outing/count"
        case .outingOut:
            return "/api/v3/outing/out"
        case .outingIn:
            return "/api/v3/outing/in"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .outingStatus,
             .outingList,
             .outingSearch,
             .outingCount:
            return .get
        case .outingOut,
             .outingIn:
            return .post
        }
    }
    
    public var sampleData: Data {
        return "@@".data(using: .utf8)!
    }
    
    public var task: Task {
        switch self {
        case .outingStatus,
             .outingList,
             .outingCount:
            return .requestPlain

        case .outingSearch(let name, _):
            return .requestParameters(
                parameters: ["name": name],
                encoding: URLEncoding.queryString
            )

        case .outingOut(let uuid, let exp, _),
             .outingIn(let uuid, let exp, _):
            return .requestParameters(
                parameters: [
                    "uuid": uuid,
                    "exp": exp
                ],
                encoding: JSONEncoding.default
            )
        }
    }
    
    public var headers: [String : String]? {
        switch self {
        case .outingStatus(let authorization),
             .outingList(let authorization),
             .outingSearch(_, let authorization),
             .outingCount(let authorization):
            return [
                "Authorization": authorization
            ]

        case .outingOut(_, _, let authorization),
             .outingIn(_, _, let authorization):
            return [
                "Content-Type": "application/json",
                "Authorization": authorization
            ]
        }
    }
}
