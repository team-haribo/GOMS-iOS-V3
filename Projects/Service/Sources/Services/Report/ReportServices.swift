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
    case reportList(authorization: String)
    case reportDetail(reportId: Int, authorization: String)
    case reportDelete(reviewId: Int, authorization: String) // 리뷰 삭제 처리
    case reportReject(reportId: Int, authorization: String) // 신고 기각 처리
}

extension ReportServices: TargetType {
    public var baseURL: URL {
        guard let urlString = Bundle.main.infoDictionary?["SchoolBaseURL"] as? String,
              let url = URL(string: urlString) else {
            fatalError("ReportAPIㅣURL을 불러올 수 없습니다.")
        }
        return url
    }

    public var path: String {
        switch self {
        case .reportList:
            
            return "/api/v3/student-council/report/pending"
        case .reportDetail(let reportId, _):
            return "/api/v3/student-council/report/\(reportId)"
        case .reportDelete(let reviewId, _):
            return "/api/v3/student-council/report/\(reviewId)"
        case .reportReject(let reportId, _):
            return "/api/v3/student-council/report/reject/\(reportId)"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .reportList, .reportDetail:
            return .get
        case .reportDelete, .reportReject:
            return .patch
        }
    }

    public var sampleData: Data {
        return "@@".data(using: .utf8)!
    }

    public var task: Task {
        return .requestPlain
    }

    public var headers: [String : String]? {
        switch self {
        case .reportList(let authorization),
             .reportDetail(_, let authorization),
             .reportDelete(_, let authorization),
             .reportReject(_, let authorization):
            return [
                "Authorization": authorization,
                "Content-Type": "application/json"
            ]
        }
    }
}
