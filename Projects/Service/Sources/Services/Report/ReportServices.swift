//
//  ReportServices.swift
//  Service
//
//  Created by 김민선 on 4/14/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation
import Moya

public enum ReportServices {
    case reportPending(authorization: String)
    case reportResolved(authorization: String)
    case reportDetail(reportId: Int, authorization: String)
    case reportDelete(reviewId: Int, authorization: String)
    case reportReject(reportId: Int, authorization: String)
    case reportResolve(reportId: Int, authorization: String)
}

extension ReportServices: TargetType {
    public var baseURL: URL {
        if let urlString = Bundle.main.infoDictionary?["SchoolBaseURL"] as? String,
           let url = URL(string: urlString) {
            return url
        }
        return URL(string: "")!
    }

    public var path: String {
        switch self {
        case .reportPending:
            return "/api/v3/student-council/report/pending"
        case .reportResolved:
            return "/api/v3/student-council/report/resolved"
        case .reportDetail(let reportId, _):
            return "/api/v3/student-council/report/\(reportId)"
        case .reportDelete(let reviewId, _):
            return "/api/v3/review/\(reviewId)"
        case .reportReject(let reportId, _):
            return "/api/v3/student-council/report/\(reportId)"
        case .reportResolve(let reportId, _):
            return "/api/v3/student-council/report/\(reportId)"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .reportPending, .reportResolved, .reportDetail:
            return .get
        case .reportDelete:
            return .delete
        case .reportReject, .reportResolve:
            return .patch
        }
    }

    public var sampleData: Data {
        return "@@".data(using: .utf8)!
    }

    public var task: Task {
        switch self {
        case .reportReject:
            return .requestParameters(
                parameters: ["reportStatus": "REJECTED"],
                encoding: JSONEncoding.default
            )

        case .reportResolve:
            return .requestParameters(
                parameters: ["reportStatus": "APPROVED"],
                encoding: JSONEncoding.default
            )
        default:
            return .requestPlain
        }
    }

    public var headers: [String : String]? {
        switch self {
        case .reportPending(let authorization),
             .reportResolved(let authorization),
             .reportDetail(_, let authorization),
             .reportDelete(_, let authorization),
             .reportReject(_, let authorization),
             .reportResolve(_, let authorization):
            return [
                "Authorization": authorization,
                "Content-Type": "application/json"
            ]
        }
    }
}
