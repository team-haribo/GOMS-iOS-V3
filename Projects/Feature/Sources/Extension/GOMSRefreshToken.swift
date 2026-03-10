//
//  GOMSRefreshToken.swift
//  Feature
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Moya
import Service

public final class GOMSRefreshToken {

    public static let shared = GOMSRefreshToken()

    private let authProvider = MoyaProvider<AuthServices>()
    private let keychain = KeyChain()

    private var statusCode: Int = 0
    private var reissuanceData: SignInResponse?

    private lazy var refreshToken: String = {
        "Bearer " + (keychain.read(key: Const.KeyChainKey.refreshToken) ?? "")
    }()

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

        let accessTokenUpdated = keychain.updateItem(
            token: reissuanceData?.accessToken ?? "",
            key: Const.KeyChainKey.accessToken
        )

        let refreshTokenUpdated = keychain.updateItem(
            token: reissuanceData?.refreshToken ?? "",
            key: Const.KeyChainKey.refreshToken
        )

        let authorityUpdated = keychain.updateItem(
            token: reissuanceData?.authority ?? "",
            key: Const.KeyChainKey.authority
        )

        if accessTokenUpdated && refreshTokenUpdated && authorityUpdated {
            print("keychain update success")
        } else {
            print("keychain update failed")
        }
    }
}
