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
                            profileImageURL: $0.profileImageUrl,
                            name: $0.name,
                            grade: $0.grade,
                            department: $0.department
                        )
                    }
                    DispatchQueue.main.async { completion() }
                } catch(let err) {
                    DispatchQueue.main.async { completion() }
                }
                switch statusCode {
                case 200:
                    break
                case 401:
                    self.gomsRefreshToken.tokenReissuance(){ [weak self] success in
                        guard let self = self else { return }
                        if success {
                            self.getLateList(completion: completion)
                        } else {
                            DispatchQueue.main.async { completion() }
                        }
                    }
                case 404:
                    break
                case 500:
                    break
                default:
                    DispatchQueue.main.async { completion() }
                }
                if statusCode != 200 {
                    DispatchQueue.main.async { completion() }
                }
            case .failure(let err):
                DispatchQueue.main.async { completion() }
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
                            profileImageURL: $0.profileImageUrl,
                            name: $0.name,
                            grade: $0.grade,
                            department: $0.department,
                            outingTime: $0.outingAt
                        )
                    }
                    DispatchQueue.main.async { completion() }
                } catch(let err) {
                    DispatchQueue.main.async { completion() }
                }
                let statusCode = result.statusCode
                switch statusCode {
                case 200:
                    break
                case 401:
                    self.gomsRefreshToken.tokenReissuance(){ [weak self] success in
                        guard let self = self else { return }
                        if success {
                            self.getOutingList(completion: completion)
                        } else {
                            DispatchQueue.main.async { completion() }
                        }
                    }
                case 404:
                    break
                case 500:
                    break
                default:
                    DispatchQueue.main.async { completion() }
                }
                if statusCode != 200 {
                    DispatchQueue.main.async { completion() }
                }
            case .failure(let err):
                DispatchQueue.main.async { completion() }
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
                    break
                }
            case .failure(let error):
                break
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
                    break
                default:
                    break
                }
            case .failure(let error):
                break
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
            DispatchQueue.main.async {
                completion(authority)
            }
        }
    }
}
