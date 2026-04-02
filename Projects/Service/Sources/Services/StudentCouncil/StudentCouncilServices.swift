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
    case editAuthority(authorization: String, param: AuthorityRequest)
    case changeBlackList(authorization: String, memberId: Int)
    case cancelBlackList(authorization: String, memberId: Int)
    case searchStudent(authorization: String, parm: SearchStudentRequest)
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
            return "/student-council/outing"
        case .statusOut(_, let memberId):
            return "/student-council/status/out/\(memberId)"
        case .statusIn(_, let memberId):
            return "/student-council/status/in/\(memberId)"
        case .studentList:
            return "/student-council/accounts"
        case .editAuthority:
            return "/student-council/authority"
        case .changeBlackList(_, let memberId):
            return "/student-council/black-list/\(memberId)"
        case .cancelBlackList(_, let memberId):
            return "/student-council/black-list/\(memberId)"
        case .searchStudent:
            return "/student-council/search"
        case .lateList:
            return "/student-council/late"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .makeQRCode,
             .changeBlackList,
             .statusOut,
             .statusIn:
            return .post
        case .cancelBlackList:
            return .delete
        case .studentList,
             .searchStudent:
            return .get
        case .editAuthority:
            return .patch
        case .lateList:
            return .get
        }
    }
    
    public var sampleData: Data {
        return "@@".data(using: .utf8)!
    }
    
    public var task: Task {
        switch self {
        case .makeQRCode,
             .studentList,
             .changeBlackList,
             .cancelBlackList,
             .statusOut,
             .statusIn:
            return .requestPlain
        case .editAuthority(_, let param):
            return .requestJSONEncodable(param)
        case .searchStudent(_, let param):
            var parameters: [String: Any] = [:]
            if let grade = param.grade { parameters["grade"] = grade }
            if let gender = param.gender { parameters["gender"] = gender }
            if let name = param.name { parameters["name"] = name }
            if let isBlackList = param.isBlackList { parameters["isBlackList"] = isBlackList }
            if let authority = param.authority { parameters["authority"] = authority }
            if let major = param.major { parameters["major"] = major }
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
        case .editAuthority(let authorization, _),
             .changeBlackList(let authorization, _),
             .cancelBlackList(let authorization, _),
             .searchStudent(let authorization, _),
             .lateList(let authorization, _),
             .statusOut(let authorization, _),
             .statusIn(let authorization, _):
            return ["Content-Type" :"application/json", "Authorization" : authorization]
        }
    }
}
