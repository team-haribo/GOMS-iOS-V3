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

    // MARK: - Properties
    private var email: String = ""
    private var password: String = ""
    private var authCode: String = ""
    private var verifiedToken: String = ""
    private var name: String = ""

    private var gender: Gender = .male
    private var major: Major = .sw

    // MARK: - Setup
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

    // MARK: - 인증번호 발송
    func sendAuthCode(completion: @escaping (Bool, Int) -> Void) {

        let param = SendAuthCodeRequest(
            email: email,
            purpose: "SIGNUP"
        )

        authProvider.request(.sendAuthCode(param: param)) { response in
            switch response {

            case .success(let result):
                completion((200..<300).contains(result.statusCode), result.statusCode)

            case .failure(let error):
                print("인증번호 발송 실패: \(error.localizedDescription)")
                completion(false, 0)
            }
        }
    }

    // MARK: - 인증번호 확인
    func verifyAuthCode(completion: @escaping (Bool) -> Void) {

        authProvider.request(.verifyAuthNumber(email: email, code: authCode)) { response in
            switch response {

            case .success(let result):

                guard (200..<300).contains(result.statusCode) else {
                    print("인증번호 검증 실패: statusCode = \(result.statusCode)")
                    completion(false)
                    return
                }

                do {
                    let data = try result.map(VerifyAuthResponse.self)

                    self.verifiedToken = data.verifiedToken

                    completion(true)

                } catch {
                    print("VerifyAuthResponse 디코딩 실패: \(error.localizedDescription)")
                    completion(false)
                }

            case .failure(let error):
                print("인증번호 검증 네트워크 실패: \(error.localizedDescription)")
                completion(false)
            }
        }
    }

    // MARK: - 회원가입
    func signUp(completion: @escaping (Bool) -> Void) {

        guard !verifiedToken.isEmpty else {
            print("회원가입 실패: 인증 토큰 없음 (verifyAuthCode 먼저 수행 필요)")
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

            case .failure(let error):
                print("회원가입 네트워크 실패: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
}
