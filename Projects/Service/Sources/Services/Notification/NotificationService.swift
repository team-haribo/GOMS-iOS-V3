//
//  NotificationService.swift
//  Service
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation
import Moya

public enum NotificationServices {
    case postFcmToken(fcmToken: String, authorization: String)
}

extension NotificationServices: TargetType {
    public var baseURL: URL {
        guard let urlString = Bundle.main.infoDictionary?["SchoolBaseURL"] as? String,
              let url = URL(string: urlString) else {
            fatalError("NotificationAPIㅣURL을 불러올 수 없습니다.")
        }
        return url
    }

    public var path: String {
        switch self {
        case .postFcmToken(let fcmToken, _):
            return "/\(fcmToken)"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .postFcmToken:
            return .post
        }
    }

    public var task: Task {
        switch self {
        case .postFcmToken:
            return .requestPlain
        }
    }

    public var headers: [String : String]? {
        switch self {
        case .postFcmToken(_, let authorization):
            return ["Content-Type": "application/json", "Authorization": authorization]
        }
    }
}
