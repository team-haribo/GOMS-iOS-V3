//
//  OutingViewModel.swift
//  Feature
//
//  Created by 김준표 on 2/25/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Moya
import Service
import Foundation

struct OutingListData {
    let id: String
    let profileImageURL: String?
    let name: String
    let grade: Int
    let major: String
    let outingTime: String
}

public final class OutingViewModel: BaseViewModel {
    private let outingProvider = MoyaProvider<OutingServices>()
    private let studentCouncilProvider = MoyaProvider<StudentCouncilServices>()

    var outingList: [OutingListResponse] = []
    var outingListDatas: [OutingListData] = []
    
    var outingSearchList: [OutingSearchResponse] = []
    var outingSearchListDatas: [OutingListData] = []
    
    func getOutingList(completion: @escaping () -> Void) {
        outingProvider.request(.outingList(authorization: accessToken)) { response in
            switch response {
            case .success(let result):
                let responseData = result.data
                let statusCode = result.statusCode
                switch statusCode {
                case 200:
                    do {
                        let responseModel = try JSONDecoder().decode(OutingListModel.self, from: responseData)
                        self.outingList = responseModel.students
                        self.outingListDatas = self.outingList.map {
                            OutingListData(
                                id: "\($0.name)-\($0.outingAt)",
                                profileImageURL: nil,
                                name: $0.name,
                                grade: $0.grade,
                                major: $0.department,
                                outingTime: $0.outingAt
                            )
                        }
                        completion()
                    } catch(let err) {
                        break
                    }
                case 401:
                    self.gomsRefreshToken.tokenReissuance(){ success in}
                case 404:
                    break
                default:
                    break
                }
            case .failure(let err):
                break
            }
        }
    }
    
    func searchStudent(searchString: String, completion: @escaping () -> Void) {
        outingProvider.request(.outingSearch(name: searchString, authorization: accessToken)) { response in
            switch response {
            case .success(let result):
                let responseData = result.data
                do {
                    let responseModel = try JSONDecoder().decode(OutingListModel.self, from: responseData)
                    self.outingSearchListDatas = responseModel.students.map {
                        OutingListData(
                            id: "\($0.name)-\($0.outingAt)",
                            profileImageURL: nil,
                            name: $0.name,
                            grade: $0.grade,
                            major: $0.department,
                            outingTime: $0.outingAt
                        )
                    }
                    completion()
                } catch(let err) {
                    break
                }
                let statusCode = result.statusCode
                switch statusCode {
                case 200:
                    break
                case 401:
                    self.gomsRefreshToken.tokenReissuance(){ success in}
                default:
                    break
                }
            case .failure(let err):
                break
            }
        }
    }
    
    func deleteOutingStudent(user: OutingListData, completion: @escaping () -> Void) {
   
        return
    }

    func forceOutingStudent(user: OutingListData, completion: @escaping () -> Void) {
       
        return
    }
}
