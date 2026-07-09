//
//  GOMSRefreshToken.swift
//  Feature
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import Foundation
import Moya
import Service

public final class GOMSRefreshToken {

    public static let shared = GOMSRefreshToken()

    private let authProvider = MoyaProvider<AuthServices>()
    private let keychain = KeyChain()

    private var statusCode: Int = 0
    private var reissuanceData: SignInResponse?

    private var refreshToken: String {
        return keychain.read(key: Const.KeyChainKey.refreshToken) ?? ""
    }

    public func tokenReissuance(completion: @escaping (Bool) -> Void) {
        authProvider.request(.refreshToken(refreshToken: refreshToken)) { [weak self] response in
            guard let self else {
                completion(false)
                return
            }

            switch response {

            case .success(let result):
                self.handleSuccess(result, completion: completion)

            case .failure(let error):
                print(String(describing: error))
                completion(false)
            }
        }
    }

    private func handleSuccess(_ result: Response, completion: @escaping (Bool) -> Void) {
        statusCode = result.statusCode

        switch statusCode {

        case 200:
            do {
                reissuanceData = try result.map(SignInResponse.self)
                updateKeychainToken()
                completion(true)
            } catch {
                print(String(describing: error))
                completion(false)
            }

        case 400, 401, 404:
            print("token error")
            completion(false)

        default:
            print("token error")
            completion(false)
        }
    }

    private func updateKeychainToken() {
        let newAccessToken = reissuanceData?.accessToken ?? ""
        let newRefreshToken = reissuanceData?.refreshToken ?? ""

        let accessTokenUpdated = keychain.updateItem(
            token: newAccessToken,
            key: Const.KeyChainKey.accessToken
        )

        let refreshTokenUpdated = keychain.updateItem(
            token: newRefreshToken,
            key: Const.KeyChainKey.refreshToken
        )

        // 새 accessToken의 JWT payload에서 role을 파싱해 authority 키체인도 갱신한다.
        // 서버가 DB에서 role을 변경한 경우, 새로 발급된 토큰에는 변경된 role이 담기므로
        // 이 시점에 authority를 덮어써야 앱이 최신 권한을 반영할 수 있다.
        if let payload = newAccessToken.split(separator: ".").dropFirst().first {
            let base64url = String(payload)
            let base64 = base64url
                .replacingOccurrences(of: "-", with: "+")
                .replacingOccurrences(of: "_", with: "/")
            let paddedPayload = base64 + String(repeating: "=", count: (4 - base64.count % 4) % 4)
            if let data = Data(base64Encoded: paddedPayload),
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let role = json["role"] as? String {
                keychain.create(key: Const.KeyChainKey.authority, token: role)
            }
        }

        if accessTokenUpdated && refreshTokenUpdated {
            print("keychain update success")
        } else {
            print("keychain update failed")
        }
    }
}
