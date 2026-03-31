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
                        self.outingList = responseModel.items
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
                        print(String(describing: err))
                    }
                case 401:
                    self.gomsRefreshToken.tokenReissuance(){ success in}
                case 404:
                    print("외출한 사람이 없을 경우")
                default:
                    print(result)
                }
            case .failure(let err):
                print(err.localizedDescription)
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
                    self.outingSearchListDatas = responseModel.items.map {
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
                    print(String(describing: err))
                }
                let statusCode = result.statusCode
                switch statusCode {
                case 200:
                    print("success")
                case 401:
                    self.gomsRefreshToken.tokenReissuance(){ success in}
                default:
                    print(result)
                }
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
    func deleteOutingStudent(user: OutingListData, completion: @escaping () -> Void) {
        guard let deleteStudent = Int(user.id) else { return }

        studentCouncilProvider.request(.deleteOuting(authorization: accessToken, memberId: deleteStudent)) { response in
            switch response {
            case .success(let result):
                let statusCode = result.statusCode
                switch statusCode {
                case 205:
                    completion()
                case 401:
                    self.gomsRefreshToken.tokenReissuance(){ success in}
                case 403:
                    print("학생회 계정이 아닌데 요청할 경우")
                default:
                    print(result)
                }
            case .failure(let err):
                print("외출자 삭제 중 오류 발생: \(err.localizedDescription)")
            }
        }
    }

    func forceOutingStudent(user: OutingListData, completion: @escaping () -> Void) {
        guard let forceOutingStudent = Int(user.id) else { return }

        studentCouncilProvider.request(.forceOuting(authorization: accessToken, memberId: forceOutingStudent)) { response in
            switch response {
            case .success(let result):
                let statusCode = result.statusCode
                switch statusCode {
                case 205:
                    completion()
                case 401:
                    self.gomsRefreshToken.tokenReissuance(){ success in}
                case 403:
                    print("학생회 계정이 아닌데 요청할 경우")
                default:
                    print(result)
                }
            case .failure(let err):
                print("외출자 외출 중 오류 발생: \(err.localizedDescription)")
            }
        }
    }
}
