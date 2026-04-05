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
    private let notificationViewModel = NotificationViewModel()

    public override init() {}

    // MARK: - Properties
    private var email: String = ""
    private var password: String = ""
    private var authCode: String = ""
    private var verifiedToken: String = ""
    private var newPassword: String = ""
    private var newServePassword: String = ""
    private var name: String = ""
    private var gender: Gender = .male
    private var major: Major = .sw
    private var grade: Int = 0
    private var emailStatus: String = ""
    private var passwordServe: String = ""

    // MARK: - Setup
    func setupEmail(email: String) {
        if email.contains("@") {
            self.email = email
        } else {
            self.email = "\(email)@gsm.hs.kr"
        }
    }

    func setupPassword(password: String) {
        self.password = password
    }

    func setupAuthCode(authCode: String) {
        self.authCode = authCode
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

    func setupGrade(grade: Int) {
        self.grade = grade
    }

    func setupEmailStatus(status: String) {
        self.emailStatus = status
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
                    print("LOGIN RAW RESPONSE")
                    print(String(data: result.data, encoding: .utf8) ?? "nil")

                    statusCode = result.statusCode

                    do {
                        switch statusCode {

                        case 200:

                            let signInResponse = try result.map(SignInResponse.self)

                            self.keyChain.create(key: Const.KeyChainKey.accessToken, token: signInResponse.accessToken)
                            self.keyChain.create(key: Const.KeyChainKey.refreshToken, token: signInResponse.refreshToken)
                            
                            let accessToken = signInResponse.accessToken

                            if let payload = accessToken.split(separator: ".").dropFirst().first,
                               let data = Data(base64Encoded: String(payload) + "=="),
                               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                               let role = json["role"] as? String {

                                self.keyChain.create(key: Const.KeyChainKey.authority, token: role)
                                authority = role
                            }

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
        
        // 비밀번호 찾기랑 이넘 분기했습니다
        let param = SendAuthCodeRequest(
            email: email,
            purpose: emailStatus.isEmpty ? "SIGNUP" : emailStatus
        )
        
        print("AUTH email:", param.email)
        
        if let jsonData = try? JSONEncoder().encode(param),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("JSON:", jsonString)
        }
        
    
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
                purpose: emailStatus // 민선: 여기도 똑같이 "SIGNUP"으로 수정
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

    // MARK: - 비밀번호 재설정
    func resetPassword(completion: @escaping (Bool, Int) -> Void) {

        guard !verifiedToken.isEmpty else {
            print("verifiedToken 없음")
            completion(false, 0)
            return
        }


        let debugJSON: [String: Any] = [
            "email": email,
            "verifiedToken": verifiedToken,
            "newPassword": password
        ]

        if let jsonData = try? JSONSerialization.data(withJSONObject: debugJSON, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print(jsonString)
        }

        let param = ResetPasswordRequest(
            email: email,
            verifiedToken: verifiedToken,
            newPassword: password
        )

        authProvider.request(.resetPassword(param: param)) { response in
            switch response {

            case .success(let result):
                print("resetPassword statusCode:", result.statusCode)

                if let responseString = String(data: result.data, encoding: .utf8) {
                    print("resetPassword response:", responseString)
                }

                completion((200..<300).contains(result.statusCode), result.statusCode)

            case .failure(let error):
                print("resetPassword error:", error.localizedDescription)

                if let response = error.response {
                    print("error statusCode:", response.statusCode)

                    if let responseString = String(data: response.data, encoding: .utf8) {
                        print("error body:", responseString)
                    }
                }

                completion(false, 0)
            }
        }
    }

    // MARK: - 회원가입
    func signUp(completion: @escaping (Bool) -> Void) {
        
        print("grade:", self.grade)
        print("verifiedToken:", verifiedToken)
        print("SIGNUP email:", email)
        print("FINAL name:", self.name)
        print("FINAL password:", self.password)
        print("FINAL major:", self.major)
        print("FINAL gender:", self.gender)
        
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
            grade: self.grade,
            department: major,
            gender: gender
        )


        authProvider.request(.signUp(param: param)) { response in
            switch response {

            case .success(let result):
                print("statusCode:", result.statusCode)
                if let responseString = String(data: result.data, encoding: .utf8) {
                    print("response:", responseString)
                }
                completion((200..<300).contains(result.statusCode))

            case .failure(let error):
                print("signUp error: \(error.localizedDescription)")
                if let response = error.response {
                    print("error statusCode:", response.statusCode)
                    if let responseString = String(data: response.data, encoding: .utf8) {
                        print("error body:", responseString)
                    }
                }
                completion(false)
            }
        }
    }
}
