//
//  ProfileViewModel.swift
//  Feature
//
//  Created by 김준표 on 2/25/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation
import Service
import Moya
import Combine
import UIKit

public struct MyRoleResponse: Decodable {
    public let memberId: Int
    public let email: String
    public let name: String
    public let role: String
}

struct ProfileImageResponse: Decodable {
    let imageUrl: String
}

public final class ProfileViewModel: BaseViewModel, ObservableObject {
    @Published public var errorMessage = ""
    @Published public var isDataLoaded = false
    @Published public var profileInfo: ProfileResponse?

    public override init() {
        super.init()
    }


    let providerMember = MoyaProvider<MemberServices>(plugins: [NetworkLoggerPlugin()])
    let providerAuth = MoyaProvider<AuthServices>(plugins: [NetworkLoggerPlugin()])
    let providerOuting = MoyaProvider<OutingServices>(plugins: [NetworkLoggerPlugin()])
    let providerProfile = MoyaProvider<ProfileServices>(plugins: [NetworkLoggerPlugin()])

    private var password: String = ""
    private var rePassword: String = ""

    public func setupPassword(password: String) {
        self.password = password
    }

    public func setupRePassword(rePassword: String) {
        self.rePassword = rePassword
    }

    public func loadProfileInfo(completion: @escaping (Bool, String?) -> Void) {
        let group = DispatchGroup()

        var name: String = ""
        var authority: String = ""
        var isOuting: Bool = false
        var grade: Int = 0
        var department: String = ""
        var lateCount: Int = 0

        
        group.enter()
        providerMember.request(.myRole(authorization: accessToken)) { result in
            switch result {
            case .success(let response):
                do {
                    let data = try JSONDecoder().decode(MyRoleResponse.self, from: response.data)
                    name = data.name
                    authority = data.role
                } catch {
                    print("myRole decode error: \(error)")
                }
            case .failure(let err):
                print("myRole error: \(err.localizedDescription)")
            }
            group.leave()
        }

        // 2. outing status
        group.enter()
        providerOuting.request(.outingStatus(authorization: accessToken)) { result in
            switch result {
            case .success(let response):
                do {
                    let data = try JSONDecoder().decode(OutingStatusResponse.self, from: response.data)
                    isOuting = data.status == "OUTING"
                    grade = data.grade
                    department = data.department
                    lateCount = data.lateCount
                } catch {
                    print("outingStatus decode error: \(error)")
                }
            case .failure(let err):
                print("outingStatus error: \(err.localizedDescription)")
            }
            group.leave()
        }

        group.notify(queue: .main, execute: {
            self.isDataLoaded = true

           
            self.profileInfo = ProfileResponse(
                name: name,
                grade: grade,
                department: department,
                authority: authority,
                lateCount: lateCount,
                isOuting: isOuting,
                profileImageUrl: nil
            )

            completion(true, authority)
        })
    }
    


    func updateProfileImage(imageData: Data) -> Future<Void, Error> {
        return Future<Void, Error> { promise in
            self.providerProfile.request(.update(authorization: self.accessToken, imageData: imageData)) { result in
                switch result {
                case .success(let response):
                    switch response.statusCode {
                    case 200:
                        do {
                            let data = try JSONDecoder().decode(ProfileImageResponse.self, from: response.data)
                            self.profileInfo = ProfileResponse(
                                name: self.profileInfo?.name ?? "",
                                grade: self.profileInfo?.grade ?? 0,
                                department: self.profileInfo?.department ?? "",
                                authority: self.profileInfo?.authority ?? "",
                                lateCount: self.profileInfo?.lateCount ?? 0,
                                isOuting: self.profileInfo?.isOuting ?? false,
                                profileImageUrl: data.imageUrl
                            )
                            promise(.success(()))
                        } catch {
                            promise(.failure(error))
                        }
                    case 400:
                        promise(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "잘못된 요청입니다."])))
                    case 401:
                        promise(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "인증이 필요합니다."])))
                    case 404:
                        promise(.failure(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "사용자를 찾을 수 없습니다."])))
                    case 409:
                        promise(.failure(NSError(domain: "", code: 409, userInfo: [NSLocalizedDescriptionKey: "프로필 이미지가 없습니다."])))
                    case 413:
                        promise(.failure(NSError(domain: "", code: 413, userInfo: [NSLocalizedDescriptionKey: "파일 크기가 너무 큽니다."])))
                    case 415:
                        promise(.failure(NSError(domain: "", code: 415, userInfo: [NSLocalizedDescriptionKey: "지원하지 않는 이미지 형식입니다."])))
                    case 500:
                        promise(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "서버 오류입니다."])))
                    default:
                        promise(.failure(NSError(domain: "", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: "알 수 없는 오류"])))
                    }
                case let .failure(err):
                    promise(.failure(err))
                }
            }
        }
    }

    func deleteProfileImage() -> Future<Void, Error> {
        return Future<Void, Error> { promise in
            self.providerProfile.request(.delete(authorization: self.accessToken)) { result in
                switch result {
                case .success(let response):
                    switch response.statusCode {
                    case 204:
                        self.profileInfo = ProfileResponse(
                            name: self.profileInfo?.name ?? "",
                            grade: self.profileInfo?.grade ?? 0,
                            department: self.profileInfo?.department ?? "",
                            authority: self.profileInfo?.authority ?? "",
                            lateCount: self.profileInfo?.lateCount ?? 0,
                            isOuting: self.profileInfo?.isOuting ?? false,
                            profileImageUrl: nil
                        )
                        promise(.success(()))
                    case 401:
                        promise(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "인증이 필요합니다."])))
                    case 404:
                        promise(.failure(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "사용자를 찾을 수 없습니다."])))
                    case 409:
                        promise(.failure(NSError(domain: "", code: 409, userInfo: [NSLocalizedDescriptionKey: "삭제할 이미지가 없습니다."])))
                    case 500:
                        promise(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "서버 오류입니다."])))
                    default:
                        promise(.failure(NSError(domain: "", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: "알 수 없는 오류"])))
                    }
                case let .failure(err):
                    promise(.failure(err))
                }
            }
        }
    }

    private var refreshToken: String {
        keyChain.read(key: Const.KeyChainKey.refreshToken) ?? ""
    }
    
    func profileLogout(completion: @escaping (Bool) -> Void) {
        providerAuth.request(.logoutToken(refreshToken: refreshToken)) { [weak self] result in
            switch result {
            case .success:
                self?.keyChain.delete(key: Const.KeyChainKey.accessToken)
                print("Logout successfully")
                completion(true)
            case let .failure(err):
                self?.errorMessage = "Network request failed: \(err.localizedDescription)"
                print("Network request failed: \(err)")
                completion(false)
            }
        }
    }

    public func withdraw(completion: @escaping (Bool) -> Void) {
        providerMember.request(.withdraw(password: self.password, authorization: accessToken)) { [weak self] response in
            guard let self = self else { return }
            
            switch response {
            case .success(let result):
                let statusCode = result.statusCode
                
                switch statusCode {
                case 200:
                   
                    self.keyChain.delete(key: Const.KeyChainKey.accessToken)
                    self.keyChain.delete(key: Const.KeyChainKey.refreshToken)
                    
                    print("회원탈퇴 성공")
                    completion(true)
                    
                case 400:
                    self.errorMessage = "요청 형식이 잘못되었습니다."
                    completion(false)
                    
                case 401:
                    self.errorMessage = "인증이 만료되었습니다. 다시 로그인해주세요."
                    completion(false)
                    
                case 403:
                    self.errorMessage = "비밀번호가 올바르지 않습니다."
                    completion(false)
                    
                case 500:
                    self.errorMessage = "서버 오류가 발생했습니다."
                    completion(false)
                    
                default:
                    self.errorMessage = "알 수 없는 오류"
                    completion(false)
                }
                
            case .failure(let err):
                self.errorMessage = err.localizedDescription
                print("withdraw error: \(err.localizedDescription)")
                completion(false)
            }
        }
    }
}
