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
    case deleteOuting(authorization: String, accountIdx: UUID)
    case forceOuting(authorization: String, accountIdx: UUID)
    case studentList(authorization: String)
    case editAuthority(authorization: String, param: AuthorityRequest)
    case changeBlackList(authorization: String, accountIdx: UUID)
    case cancelBlackList(authorization: String, accountIdx: UUID)
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
        case .deleteOuting(_ , let accountIdx), .forceOuting(_ , let accountIdx):
            return "/student-council/outing/\(accountIdx)"
        case .studentList:
            return "/student-council/accounts"
        case .editAuthority:
            return "/student-council/authority"
        case .changeBlackList(_, let accountIdx):
            return "/student-council/black-list/\(accountIdx)"
        case .cancelBlackList(_ , let accountIdx):
            return "/student-council/black-list/\(accountIdx)"
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
             .forceOuting:
            return .post
        case .deleteOuting,
             .cancelBlackList:
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
             .deleteOuting,
             .studentList,
             .changeBlackList,
             .cancelBlackList,
             .forceOuting:
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
        case .deleteOuting(let authorization, _),
             .editAuthority(let authorization, _),
             .changeBlackList(let authorization, _),
             .cancelBlackList(let authorization, _),
             .searchStudent(let authorization, _),
             .lateList(let authorization, _),
             .forceOuting(let authorization, _):
            return ["Content-Type" :"application/json", "Authorization" : authorization]
        }
    }
}
