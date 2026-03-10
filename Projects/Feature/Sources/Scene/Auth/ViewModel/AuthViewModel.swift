//
//  AuthViewModel.swift
//  Feature
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Moya
import Service
import Foundation

public final class AuthViewModel: BaseViewModel {

    private let authProvider = MoyaProvider<AuthServices>()
    private let accountProvider = MoyaProvider<AccountServices>()

    public override init() {}

    var userData: SignInModel?

    public let profileModel = ProfileViewModel()
    public let notificationViewModel = NotificationViewModel()

    private var email: String = ""
    private var password: String = ""
    private var authCode: String = ""
    private var newPassword: String = ""
    private var newServePassword: String = ""
    private var name: String = ""
    private var gender: String = ""
    private var major: String = ""
    private var emailStatus: String = ""
    private var passwordServe: String = ""

    func setupEmailStatus(emailStatus: String) {
        self.emailStatus = emailStatus
    }

    func setupEmail(email: String) {
        self.email = "\(email)@gsm.hs.kr"
    }

    func setupPassword(password: String) {
        self.password = password
    }

    func setupAuthCode(authCode: String) {
        self.authCode = authCode
    }

    func setupNewPassword(newPassword: String, checkPassword: String) {
        guard newPassword == checkPassword else { return }
        self.newPassword = newPassword
    }

    func setupNewServePassword(newPassword: String, checkPassword: String) {
        guard newPassword == checkPassword else { return }
        self.newServePassword = newPassword
    }

    func setupName(name: String) {
        self.name = name
    }

    func setupGender(gender: String) {
        self.gender = gender
    }

    func setupMajor(major: String) {
        self.major = major
    }

    func signIn(completion: @escaping (Int, String?) -> Void) {

        let param = SignInRequest(email: email, password: password)

        authProvider.request(.signIn(param: param)) { [weak self] response in
            guard let self = self else { return }

            DispatchQueue.global().async {

                var authority: String? = nil
                var statusCode = 0

                switch response {

                case .success(let result):

                    statusCode = result.statusCode

                    do {
                        switch statusCode {

                        case 200:

                            let signInResponse = try result.map(SignInResponse.self)

                            self.keyChain.create(key: Const.KeyChainKey.accessToken, token: signInResponse.accessToken)
                            self.keyChain.create(key: Const.KeyChainKey.refreshToken, token: signInResponse.refreshToken)
                            self.keyChain.create(key: Const.KeyChainKey.authority, token: signInResponse.authority)

                            authority = signInResponse.authority

                            if let savedToken = UserDefaults.standard.string(forKey: "FCMToken"),
                               let accessToken = KeyChain.shared.read(key: Const.KeyChainKey.accessToken) {

                                self.notificationViewModel.setupFcmToken(fcmToken: savedToken)
                                self.notificationViewModel.setupaccessToken(accessToken: accessToken)

                                self.notificationViewModel.postFcmToken { success in
                                    if success {
                                        print("FCM 토큰 전송 성공")
                                    } else {
                                        print("FCM 토큰 전송 실패")
                                    }
                                }
                            }

                        default:
                            break
                        }

                    } catch {
                        print("Error parsing SignInResponse: \(error)")
                    }

                case .failure(let err):
                    print("Network error: \(err.localizedDescription)")
                }

                DispatchQueue.main.async {
                    completion(statusCode, authority)
                }
            }
        }
    }

    func sendAuthCode(completion: @escaping (Bool, Int) -> Void) {

        let param = SendAuthCodeRequest(email: email, emailStatus: emailStatus)

        authProvider.request(.sendAuthCode(param: param)) { response in

            switch response {

            case .success(let result):

                let statusCode = result.statusCode

                switch statusCode {

                case 204:
                    completion(true, statusCode)

                case 404, 429:
                    completion(false, statusCode)

                default:
                    completion(false, statusCode)
                }

            case .failure(let err):
                print(err.localizedDescription)
                completion(false, 0)
            }
        }
    }

    func verifyAuthCode(completion: @escaping (Bool) -> Void) {

        authProvider.request(.verifyAuthNumber(email: email, authCode: authCode)) { response in

            switch response {

            case .success(let result):

                let statusCode = result.statusCode

                switch statusCode {

                case 200..<300:
                    completion(true)

                case 401, 404, 429, 500:
                    completion(false)

                default:
                    completion(false)
                }

            case .failure(let err):
                print(err.localizedDescription)
                completion(false)
            }
        }
    }

    func newPassword(completion: @escaping (Bool, Int) -> Void) {

        let param = NewPasswordRequest(email: email, newPassword: newServePassword)

        accountProvider.request(.newPassword(param: param)) { response in

            switch response {

            case .success(let result):

                let statusCode = result.statusCode

                switch statusCode {

                case 204:
                    completion(true, statusCode)

                case 400, 404, 500:
                    completion(false, statusCode)

                default:
                    completion(false, statusCode)
                }

            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }

    func changNewPassword(completion: @escaping (Bool, Int) -> Void) {

        let param = ChangPasswordRequest(password: password, newPassword: newPassword)

        accountProvider.request(.changPassword(param: param, authorization: accessToken)) { response in

            switch response {

            case .success(let result):

                let statusCode = result.statusCode

                switch statusCode {

                case 204:
                    completion(true, statusCode)

                case 400, 404, 500:
                    completion(false, statusCode)

                default:
                    completion(false, statusCode)
                }

            case .failure(let err):
                print(err.localizedDescription)
                completion(false, 0)
            }
        }
    }

    func signUp(completion: @escaping (Bool) -> Void) {

        let param = SignUpRequest(
            email: email,
            password: newPassword,
            name: name,
            gender: gender,
            major: major
        )

        authProvider.request(.signUp(param: param)) { response in

            switch response {

            case .success(let result):

                switch result.statusCode {

                case 201:
                    completion(true)

                case 500:
                    completion(false)

                default:
                    completion(false)
                }

            case .failure(let err):
                print(err.localizedDescription)
                completion(false)
            }
        }
    }
}
