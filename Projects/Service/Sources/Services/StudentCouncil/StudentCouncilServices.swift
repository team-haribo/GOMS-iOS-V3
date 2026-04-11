//
//  StudentCouncilServices.swift
//  Service
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation
import Moya

public enum StudentCouncilServices {
    case makeQRCode(authorization: String)
    case statusOut(authorization: String, memberId: Int)
    case statusIn(authorization: String, memberId: Int)
    case studentList(authorization: String)
    case editAuthority(authorization: String, memberId: Int, param: AuthorityRequest)
    case outingAllowed(authorization: String, memberId: Int, param: OutingAllowedRequest)
    case forceOuting(authorization: String, memberId: Int)
    case searchStudent(authorization: String, param: SearchStudentRequest)
    case lateList(authorization: String, date: String)
}

extension StudentCouncilServices: TargetType {
    public var baseURL: URL {
        guard let urlString = Bundle.main.infoDictionary?["SchoolBaseURL"] as? String,
              let url = URL(string: urlString) else {
            fatalError("StudentCouncilㅣURL을 불러올 수 없습니다.")
        }
        return url
    }

    public var path: String {
        switch self {
        case .makeQRCode:
            return "/api/v3/student-council/qr"
        case .statusOut(_, let memberId):
            return "/api/v3/student-council/status/out/\(memberId)"
        case .statusIn(_, let memberId):
            return "/api/v3/student-council/status/in/\(memberId)"
        case .studentList:
            return "/api/v3/student-council/member"
        case .editAuthority(_, let memberId, _):
            return "/api/v3/student-council/role/\(memberId)"
        case .outingAllowed(_, let memberId, _):
            return "/api/v3/student-council/outing-allowed/\(memberId)"
        case .forceOuting(_, let memberId):
            return "/api/v3/student-council/status/out/\(memberId)"
        case .searchStudent:
            return "/api/v3/student-council/search"
        case .lateList:
            return "/api/v3/student-council/late"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .makeQRCode,
             .statusOut,
             .statusIn,
             .forceOuting:
            return .post

        case .outingAllowed:
            return .patch

        case .studentList,
             .searchStudent,
             .lateList:
            return .get

        case .editAuthority:
            return .patch
        }
    }
    
    public var sampleData: Data {
        return "@@".data(using: .utf8)!
    }
    
    public var task: Task {
        switch self {
        case .makeQRCode,
             .studentList,
             .forceOuting,
             .statusOut,
             .statusIn:
            return .requestPlain
        case .editAuthority(_, _, let param):
            return .requestJSONEncodable(param)
        case .outingAllowed(_, _, let param):
            return .requestJSONEncodable(param)
        case .searchStudent(_, let param):
            var parameters: [String: Any] = [:]
            
            if let name = param.name { parameters["name"] = name }
            if let grade = param.grade { parameters["grade"] = grade }
            if let gender = param.gender { parameters["gender"] = gender }
            if let isBlackList = param.isBlackList { parameters["isBlackList"] = isBlackList }
            if let authority = param.authority { parameters["role"] = authority }
            if let major = param.major { parameters["department"] = major }
            
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case .lateList(_ , let date):
            return .requestParameters(parameters: ["date": date], encoding: URLEncoding.default)
        }
    }
    
    public var headers: [String : String]? {
        switch self {
        case .makeQRCode(let authorization),
             .studentList(let authorization):
            return ["Content-Type" :"application/json", "Authorization" : authorization]
        case .editAuthority(let authorization, _, _),
             .outingAllowed(let authorization, _, _),
             .forceOuting(let authorization, _),
             .searchStudent(let authorization, _),
             .lateList(let authorization, _),
             .statusOut(let authorization, _),
             .statusIn(let authorization, _):
            return ["Content-Type" :"application/json", "Authorization" : authorization]
        }
    }
}
