//
//  AccountServices.swift
//  Service
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation
import Moya

public enum AccountServices {
    case newPassword(param: NewPasswordRequest)
    case changPassword(param: ChangPasswordRequest, authorization: String)
    case withdraw(password: String, authorization: String)
}

extension AccountServices: TargetType {
    public var baseURL: URL {
        guard let urlString = Bundle.main.infoDictionary?["SchoolBaseURL"] as? String,
              let url = URL(string: urlString) else {
            fatalError("AccountAPIㅣURL을 불러올 수 없습니다.")
        }
        return url
    }

    public var path: String {
        switch self {
        case .newPassword:
            return "/account/new-password"
        case .changPassword:
            return "/account/change-password"
        case .withdraw(let password, _):
            return "/account/withdraw/\(password)"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .newPassword, .changPassword:
            return .patch
        case .withdraw:
            return .delete
        }
    }
    
    public var sampleData: Data {
        return "@@".data(using: .utf8)!
    }
    
    public var task: Task {
        switch self {
        case .newPassword(let param):
            return .requestJSONEncodable(param)
        case .changPassword(let param, _):
            return .requestJSONEncodable(param)
        case .withdraw:
            return .requestPlain
        }
    }
    
    public var headers: [String : String]? {
        switch self {
        case .newPassword:
            return ["Content-Type": "application/json"]
        case .changPassword(_, let authorization),
             .withdraw(_, let authorization):
            return ["Content-Type": "application/json", "Authorization": authorization]
        default:
            return ["Content-Type": "application/json"]
        }
    }
}
