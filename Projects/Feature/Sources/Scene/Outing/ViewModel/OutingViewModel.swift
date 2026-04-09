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
    let id: Int
    let profileImageURL: String?
    let name: String
    let grade: Int
    let department: String
    let outingTime: String
}

public final class OutingViewModel: BaseViewModel {
    private let outingProvider = MoyaProvider<OutingServices>()
    private let studentCouncilProvider = MoyaProvider<StudentCouncilServices>()

    var outingList: [OutingListResponse] = []
    var outingListDatas: [OutingListData] = []
    
    var outingSearchList: [OutingSearchResponse] = []
    var outingSearchListDatas: [OutingListData] = []
    
    func getOutingList(isRetry: Bool = false, completion: @escaping () -> Void) {
        outingProvider.request(.outingList(authorization: accessToken)) { response in
            switch response {
            case .success(let result):
                let responseData = result.data
                let statusCode = result.statusCode
                switch statusCode {
                case 200:
                    do {
                        let decoded = try JSONDecoder().decode(OutingListModel.self, from: responseData)
                        self.outingList = decoded.students
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
                        completion()
                    } catch(let err) {
                        print(String(describing: err))
                    }
                case 401:
                    if isRetry {
                        print("재시도 실패 (getOutingList)")
                        return
                    }
                    self.gomsRefreshToken.tokenReissuance() { success in
                        if success {
                            self.getOutingList(isRetry: true, completion: completion)
                        }
                    }
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
    
    func searchStudent(searchString: String, isRetry: Bool = false, completion: @escaping () -> Void) {
        outingProvider.request(.outingSearch(name: searchString, authorization: accessToken)) { response in
            switch response {
            case .success(let result):
                let responseData = result.data
                do {
                    let decoded = try JSONDecoder().decode(OutingSearchModel.self, from: responseData)
                    self.outingSearchList = decoded.students
                    self.outingSearchListDatas = self.outingSearchList.map {
                        OutingListData(
                            id: $0.memberId,
                            profileImageURL: $0.profileImageUrl,
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
                    print("success")
                case 401:
                    if isRetry {
                        print("재시도 실패 (searchStudent)")
                        return
                    }
                    self.gomsRefreshToken.tokenReissuance() { success in
                        if success {
                            self.searchStudent(searchString: searchString, isRetry: true, completion: completion)
                        }
                    }
                default:
                    print(result)
                }
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
    func deleteOutingStudent(user: OutingListData, isRetry: Bool = false, completion: @escaping () -> Void) {
        let deleteStudent = user.id

        studentCouncilProvider.request(
            .statusIn(authorization: accessToken, memberId: deleteStudent)
        ) { response in
            switch response {
            case .success(let result):
                let statusCode = result.statusCode
                switch statusCode {
                case 200, 205:
                    completion()

                case 400:
                    print("잘못된 요청")

                case 401:
                    if isRetry {
                        print("재시도 실패 (deleteOutingStudent)")
                        return
                    }
                    self.gomsRefreshToken.tokenReissuance() { success in
                        if success {
                            self.deleteOutingStudent(user: user, isRetry: true, completion: completion)
                        }
                    }

                case 403:
                    print("권한 없음 / 외출 불가 상태")

                case 409:
                    print("이미 외출 중이 아님")

                case 500:
                    print("서버 내부 에러")

                default:
                    print("알 수 없는 응답: \(statusCode)")
                }
            case .failure(let err):
                print("외출자 삭제 중 오류 발생: \(err.localizedDescription)")
            }
        }
    }

    func forceOutingStudent(user: OutingListData, isRetry: Bool = false, completion: @escaping () -> Void) {
        let forceOutingStudent = user.id

        studentCouncilProvider.request(
            .statusIn(authorization: accessToken, memberId: forceOutingStudent)
        ) { response in
            switch response {
            case .success(let result):
                let statusCode = result.statusCode
                switch statusCode {
                case 200, 205:
                    completion()

                case 400:
                    print("QR 만료 또는 요청 값 오류")

                case 401:
                    if isRetry {
                        print("재시도 실패 (forceOutingStudent)")
                        return
                    }
                    self.gomsRefreshToken.tokenReissuance() { success in
                        if success {
                            self.forceOutingStudent(user: user, isRetry: true, completion: completion)
                        }
                    }

                case 403:
                    print("외출 불가 상태 (CANNOT_OUTING)")

                case 409:
                    print("이미 외출 중")

                case 500:
                    print("서버 내부 에러")

                default:
                    print("알 수 없는 응답: \(statusCode)")
                }
            case .failure(let err):
                print("외출자 외출 중 오류 발생: \(err.localizedDescription)")
            }
        }
    }
}
