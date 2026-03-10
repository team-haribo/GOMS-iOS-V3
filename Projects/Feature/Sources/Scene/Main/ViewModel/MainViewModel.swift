//
//  MainViewModel.swift
//  Feature
//
//  Created by 김준표 on 2/25/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Moya
import Service
import Foundation

struct LatecomerData {
    let profileImageURL: String?
    let name: String
    let grade: Int
    let major: String
}

struct ProfileData {
    let profileUrl: String?
    let name: String
    let grade: Int
    let major: String
    let authority: String
    let isOuting: Bool
    let isBlackList: Bool
}

public final class MainViewModel: BaseViewModel {
    private let isTestMode = true
    private let lateProvider = MoyaProvider<LateService>()
    private let outingProvider = MoyaProvider<OutingServices>()
    private let profileProvider = MoyaProvider<ProfileServices>()
    
    var lateList: [LatecomerResponse] = []
    var lateListDatas: [LatecomerData] = []
    
    var outingList: [OutingListResponse] = []
    var outingListDatas: [OutingListData] = []
    
    var profile: ProfileResponse?
    var profileData: ProfileData?
        
    override init() {
        self.profile = nil
        self.profileData = nil
    }
    
    func getLateList(completion: @escaping () -> Void) {
        if isTestMode {
            self.lateListDatas = []
            completion()
            return
        }
        lateProvider.request(.lateRank(authorization: accessToken)) { response in
            switch response {
            case .success(let result):
                let responseData = result.data
                let statusCode = result.statusCode
                do {
                    self.lateList = try JSONDecoder().decode([LatecomerResponse].self, from: responseData)
                    self.lateListDatas = self.lateList.map { LatecomerData(profileImageURL: $0.profileUrl, name: $0.name, grade: $0.grade, major: $0.major) }
                    completion()
                } catch(let err) {
                    print(String(describing: err))
                }
                switch statusCode {
                case 200:
                    print("OK")
                case 401:
                    self.gomsRefreshToken.tokenReissuance(){ success in}
                case 404:
                    print("지각자 없음")
                case 500:
                    print("SERVER ERROR")
                default:
                    print(result)
                }
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
    func getOutingList(completion: @escaping () -> Void) {
        if isTestMode {
            self.outingListDatas = []
            completion()
            return
        }
        outingProvider.request(.outingList(authorization: accessToken)) { response in
            switch response {
            case .success(let result):
                let responseData = result.data
                do {
                    self.outingList = try JSONDecoder().decode([OutingListResponse].self, from: responseData)
                    self.outingListDatas = self.outingList.map { OutingListData(id: $0.accountIdx, profileImageURL: $0.profileUrl, name: $0.name, grade: $0.grade, major: $0.major, outingTime: $0.createdTime) }
                    completion()
                } catch(let err) {
                    print(String(describing: err))
                }
                let statusCode = result.statusCode
                switch statusCode {
                case 200:
                    print("OK")
                case 401:
                    self.gomsRefreshToken.tokenReissuance(){ success in}
                case 404:
                    print("외출한 사람이 없을 경우")
                case 500:
                    print("SERVER ERROR")
                default:
                    print(result)
                }
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
    func getProfile(completion: @escaping (String?) -> Void) {
        if isTestMode {
            self.profileData = ProfileData(profileUrl: nil,
                                           name: "테스트 사용자",
                                           grade: 3,
                                           major: "SW",
                                           authority: "ROLE_STUDENT",
                                           isOuting: false,
                                           isBlackList: false)
            completion("ROLE_STUDENT")
            return
        }
        profileProvider.request(.getProfile(authorization: accessToken)) { response in
            switch response {
            case .success(let result):
                let statusCode = result.statusCode
                let responseData = result.data
                switch statusCode {
                case 200:
                    do {
                        self.profile = try JSONDecoder().decode(ProfileResponse.self, from: responseData)
                        self.profileData = ProfileData(profileUrl: self.profile?.profileUrl,
                                                       name: self.profile?.name ?? "",
                                                       grade: self.profile?.grade ?? 0,
                                                       major: self.profile?.major ?? "",
                                                       authority: self.profile?.authority ?? "",
                                                       isOuting: self.profile?.isOuting ?? false,
                                                       isBlackList: self.profile?.isBlackList ?? false)
                        completion(self.profileData?.authority)
                    } catch {
                        print(error.localizedDescription)
                        completion(nil)
                    }
                case 401:
                    self.gomsRefreshToken.tokenReissuance(){ success in}
                    completion(nil)
                default:
                    print(result)
                    completion(nil)
                }
            case .failure(let err):
                print(err.localizedDescription)
                completion(nil)
            }
        }
    }
}
