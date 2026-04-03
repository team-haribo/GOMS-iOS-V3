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
    let department: String
}

struct ProfileData {
    let profileUrl: String?
    let name: String
    let grade: Int
    let department: String
    let authority: String
    let status: String
    let lateCount: Int
}

public final class MainViewModel: BaseViewModel {
    private let isTestMode = false
    private let lateProvider = MoyaProvider<LateService>()
    private let outingProvider = MoyaProvider<OutingServices>()
    private let profileProvider = MoyaProvider<ProfileServices>()
    private let providerMember = MoyaProvider<MemberServices>()
    
    var lateList: [LatecomerResponse] = []
    var lateListDatas: [LatecomerData] = []
    
    var outingList: [OutingListResponse] = []
    var outingListDatas: [OutingListData] = []
    
    var profileData: ProfileData?
        
    override init() {
        self.profileData = nil
    }
    
    func getLateList(completion: @escaping () -> Void) {
        lateProvider.request(.lateRank(authorization: accessToken)) { response in
            switch response {
            case .success(let result):
                let responseData = result.data
                let statusCode = result.statusCode
                do {
                    let responseModel = try JSONDecoder().decode(LatecomerModel.self, from: responseData)
                    self.lateList = responseModel.students
                    self.lateListDatas = self.lateList.map {
                        LatecomerData(
                            profileImageURL: nil,
                            name: $0.name,
                            grade: $0.grade,
                            department: $0.department
                        )
                    }
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
        outingProvider.request(.outingList(authorization: accessToken)) { response in
            switch response {
            case .success(let result):
                let responseData = result.data
                do {
                    let responseModel = try JSONDecoder().decode(OutingListModel.self, from: responseData)
                    self.outingList = responseModel.students
                    self.outingListDatas = self.outingList.map {
                        OutingListData(
                            id: $0.memberId,
                            profileImageURL: nil,
                            name: $0.name,
                            grade: $0.grade,
                            department: $0.department,
                            outingTime: $0.outingAt
                        )
                    }
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
        let group = DispatchGroup()

        var name: String = ""
        var grade: Int = 0
        var department: String = ""
        var authority: String = ""
        var status: String = ""
        var lateCount: Int = 0

        
        group.enter()
        self.providerMember.request(.myRole(authorization: accessToken)) { result in
            switch result {
            case .success(let response):
                switch response.statusCode {
                case 200:
                    if let data = try? JSONDecoder().decode(MyRoleResponse.self, from: response.data) {
                        name = data.name
                        authority = data.role
                    }
                case 401:
                    self.gomsRefreshToken.tokenReissuance() { _ in }
                default:
                    print(response)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
            group.leave()
        }

      
        group.enter()
        self.outingProvider.request(.outingStatus(authorization: accessToken)) { result in
            switch result {
            case .success(let response):
                switch response.statusCode {
                case 200:
                    if let data = try? JSONDecoder().decode(OutingStatusResponse.self, from: response.data) {
                        status = data.status
                        grade = data.grade
                        department = data.department
                        lateCount = data.lateCount
                    }
                case 401:
                    self.gomsRefreshToken.tokenReissuance() { _ in }
                case 500:
                    print("SERVER ERROR")
                default:
                    print(response)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
            group.leave()
        }

        group.notify(queue: .main) {
            self.profileData = ProfileData(
                profileUrl: nil,
                name: name,
                grade: grade,
                department: department,
                authority: authority,
                status: status,
                lateCount: lateCount
            )
            completion(authority)
        }
    }
}
