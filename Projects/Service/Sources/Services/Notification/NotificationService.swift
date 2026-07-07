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
    case postFcmToken(fcmToken: String, deviceId: String, authorization: String)
    case deleteFcmToken(deviceId: String, authorization: String)
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
        case .postFcmToken:
            return "/api/v3/notification/token"
        case .deleteFcmToken(let deviceId, _):
            return "/api/v3/notification/token/\(deviceId)"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .postFcmToken:
            return .post
        case .deleteFcmToken:
            return .delete
        }
    }

    public var task: Task {
        switch self {
        case .postFcmToken(let fcmToken, let deviceId, _):
            return .requestParameters(
                parameters: [
                    "fcmToken": fcmToken,
                    "platform": "IOS",
                    "deviceId": deviceId
                ],
                encoding: JSONEncoding.default
            )
        case .deleteFcmToken:
            return .requestPlain
        }
    }

    public var headers: [String : String]? {
        switch self {
        case .postFcmToken(_, _, let authorization):
            return ["Content-Type": "application/json", "Authorization": authorization]
        case .deleteFcmToken(_, let authorization):
            return ["Content-Type": "application/json", "Authorization": authorization]
        }
    }
}
