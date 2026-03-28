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
    private var verifiedToken: String = ""
    private var newPassword: String = ""
    private var newServePassword: String = ""
    private var name: String = ""
    private var gender: Gender = .male
    private var major: Major = .sw
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

    func setupGender(gender: Gender) {
        self.gender = gender
    }

    func setupMajor(major: Major) {
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
        
        let param = SendAuthCodeRequest(
            email: email,
            purpose: AuthPurpose.signup.rawValue
        )
        
        if let jsonData = try? JSONEncoder().encode(param),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("JSON:", jsonString)
        }
        
        print("재요청")
        print("URL:", "https://port-0-goms-backend-v3-mmjt7nyl6f7b9e55.sel3.cloudtype.app/api/v3/auth/email-verifications/send")
        print("email:", param.email)
        print("purpose:", param.purpose)
        
        authProvider.request(.sendAuthCode(param: param)) { response in

            switch response {
                
            case .success(let result):
                if let request = result.request {
                    print("Request URL:", request.url?.absoluteString ?? "nil")
                    print("HTTP Method:", request.httpMethod ?? "nil")
                    if let headers = request.allHTTPHeaderFields {
                        print("Headers:", headers)
                    }
                    if let body = request.httpBody,
                       let bodyString = String(data: body, encoding: .utf8) {
                        print("Body:", bodyString)
                    } else {
                        print("Body: nil")
                    }
                }
                print("Final URL:", result.response?.url?.absoluteString ?? "nil")

                print("코드 로킹:", result.statusCode)
                
                if let responseString = String(data: result.data, encoding: .utf8) {
                    print("body 리스폰: ", responseString)
                }
                
                completion((200..<300).contains(result.statusCode), result.statusCode)
                
            case .failure(let error):
                if let request = error.response?.request {
                    print("Request URL(failure):", request.url?.absoluteString ?? "nil")
                    print("HTTP Method(failure):", request.httpMethod ?? "nil")
                    if let headers = request.allHTTPHeaderFields {
                        print("Headers(failure):", headers)
                    }
                    if let body = request.httpBody,
                       let bodyString = String(data: body, encoding: .utf8) {
                        print("Body(failure):", bodyString)
                    } else {
                        print("Body(failure): nil")
                    }
                }
                print("네트워크 에러: ", error.localizedDescription)
                
                if let response = error.response {
                    print("X 코드에러 :", response.statusCode)
                    
                    if let responseString = String(data: response.data, encoding: .utf8) {
                        print("body 에러: ", responseString)
                    }
                }
                
                completion(false, 0)
            }
        }
    }

    // MARK: - 인증번호 검증
    func verifyAuthCode(completion: @escaping (Bool) -> Void) {

        authProvider.request(
            .verifyAuthNumber(
                email: email,
                code: authCode,
                purpose: AuthPurpose.signup.rawValue
            )
        ) { response in

            switch response {

            case .success(let result):

                guard (200..<300).contains(result.statusCode) else {
                    print("verifyAuthCode status error: \(result.statusCode)")
                    completion(false)
                    return
                }

                do {
                    let data = try result.map(VerifyAuthResponse.self)
                    self.verifiedToken = data.verifiedToken
                    completion(true)

                } catch {
                    print("verifyAuthCode decode error: \(error)")
                    completion(false)
                }

            case .failure(let error):
                print("verifyAuthCode network error: \(error.localizedDescription)")
                completion(false)
            }
        }
    }

    // MARK: - 회원가입
    func signUp(grade: Int,
                completion: @escaping (Bool) -> Void) {

        guard !verifiedToken.isEmpty else {
            print("verifiedToken 없음")
            completion(false)
            return
        }

        let param = SignUpRequest(
            email: email,
            verifiedToken: verifiedToken,
            password: password,
            name: name,
            grade: grade,
            department: major,
            gender: gender
        )

        authProvider.request(.signUp(param: param)) { response in
            switch response {

            case .success(let result):
                completion(result.statusCode == 201)

            case .failure(let error):
                print("signUp error: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    // MARK: - 로그인
    func signIn(completion: @escaping (Int) -> Void) {

        let param = SignInRequest(
            email: email,
            password: password
        )

        authProvider.request(.signIn(param: param)) { response in
            switch response {

            case .success(let result):
                completion(result.statusCode)

            case .failure(let error):
                print("signIn error: \(error.localizedDescription)")
                completion(0)
            }
        }
    }
}
