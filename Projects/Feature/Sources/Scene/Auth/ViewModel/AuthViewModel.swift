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

    public override init() {}

    private var email: String = ""
    private var password: String = ""
    private var authCode: String = ""
    private var verifiedToken: String = ""
    private var name: String = ""

    private var gender: Gender = .male
    private var major: Major = .sw

    func setupEmail(email: String) {
        self.email = email
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

    func sendAuthCode(completion: @escaping (Bool, Int) -> Void) {
        let param = SendAuthCodeRequest(
            email: email,
            purpose: "SIGNUP"
        )

        authProvider.request(.sendAuthCode(param: param)) { response in
            switch response {
            case .success(let result):
                completion((200..<300).contains(result.statusCode), result.statusCode)

            case .failure:
                completion(false, 0)
            }
        }
    }

    func verifyAuthCode(completion: @escaping (Bool) -> Void) {
        authProvider.request(.verifyAuthNumber(email: email, code: authCode)) { response in
            switch response {
            case .success(let result):
                guard (200..<300).contains(result.statusCode) else {
                    completion(false)
                    return
                }

                do {
                    let data = try result.map(VerifyAuthResponse.self)
                    self.verifiedToken = data.verifiedToken
                    completion(true)
                } catch {
                    completion(false)
                }

            case .failure:
                completion(false)
            }
        }
    }

    func signUp(completion: @escaping (Bool) -> Void) {
        guard !verifiedToken.isEmpty else {
            completion(false)
            return
        }

        let param = SignUpRequest(
            email: email,
            verifiedToken: verifiedToken,
            password: password,
            name: name,
            grade: 1,
            department: major,
            gender: gender
        )

        authProvider.request(.signUp(param: param)) { response in
            switch response {
            case .success(let result):
                completion(result.statusCode == 201)

            case .failure:
                completion(false)
            }
        }
    }
}
