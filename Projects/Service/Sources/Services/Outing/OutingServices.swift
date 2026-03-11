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
    case outing(outingUUID: UUID, authorization: String)
    case outingList(authorization: String)
    case outingSearch(name: String?, authorization: String)
    case outingValidation(authorization: String)
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
        case .outing(let outingUUID, _):
            return "/outing/\(outingUUID)"
        case .outingList:
            return "/outing/"
        case .outingSearch:
            return "/outing/search"
        case .outingValidation:
            return "/outing/validation"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .outingList,
             .outingSearch,
             .outingValidation:
            return .get
        case .outing:
            return .post
        }
    }
    
    public var sampleData: Data {
        return "@@".data(using: .utf8)!
    }
    
    public var task: Task {
        switch self {
        case .outing:
            return .requestPlain
        case .outingList:
            return .requestPlain
        case .outingSearch(let name, _):
            return .requestParameters(parameters: ["name": name ?? ""], encoding: URLEncoding.queryString)
        case .outingValidation:
            return .requestPlain
        }
    }
    
    public var headers: [String : String]? {
        switch self {
        case .outingList(let authorization),
             .outing(_, let authorization),
             .outingValidation(let authorization):
            return ["Content-Type": "application/json", "Authorization": authorization]
        default:
            return ["Content-Type": "application/json"]
        }
    }
}


