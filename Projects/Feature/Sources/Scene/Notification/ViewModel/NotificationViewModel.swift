//
//  NotificationViewModel.swift
//  Feature
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation
import Service
import Moya
import UIKit

public final class NotificationViewModel: ObservableObject {
    public init() {}

    public let providerNotification = MoyaProvider<NotificationServices>(plugins: [NetworkLoggerPlugin()])
    private var fcmToken: String = ""
    private var accessToken: String = ""

    private var deviceId: String {
        if let cached = UserDefaults.standard.string(forKey: "DeviceId") {
            return cached
        }
        let newId = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        UserDefaults.standard.set(newId, forKey: "DeviceId")
        return newId
    }

    public func setupaccessToken(accessToken: String) {
        self.accessToken = accessToken
    }

    public func setupFcmToken(fcmToken: String) {
        self.fcmToken = fcmToken
    }

    public func postFcmToken(completion: @escaping (Bool) -> Void) {
        providerNotification.request(.postFcmToken(fcmToken: fcmToken, deviceId: deviceId, authorization: accessToken)) { result in
            switch result {
            case .success:
                print("SuccessㅣFCM Token 전송")
                completion(true)
            case .failure(let error):
                print("FailureㅣFCM Token 전송 실패")
                print(error.localizedDescription)
                completion(false)
            }
        }
    }

    public func deleteFcmToken(accessToken: String, completion: @escaping (Bool) -> Void) {
        providerNotification.request(.deleteFcmToken(deviceId: deviceId, authorization: accessToken)) { result in
            switch result {
            case .success:
                print("SuccessㅣFCM Token 삭제")
                completion(true)
            case .failure(let error):
                print("FailureㅣFCM Token 삭제 실패")
                print(error.localizedDescription)
                completion(false)
            }
        }
    }
}
