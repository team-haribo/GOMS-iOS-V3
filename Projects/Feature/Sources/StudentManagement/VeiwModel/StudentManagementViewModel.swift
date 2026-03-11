//
//  StudentManagementViewModel.swift
//  Feature
//
//  Created by 김준표 on 2/25/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation
import Moya
import Service

struct UserData {
    let id: UUID
    let name: String
    let profileImageURL: String?
    let gender: String
    let grade: Int
    let major: String
    let authority: String
    let isBlackList: Bool
    let isOuting: Bool
}

public final class StudentManagementViewModel: BaseViewModel {
    private let studentCouncilProvider = MoyaProvider<StudentCouncilServices>()
    
    var userList: [StudentListResponse] = []
    var userListDatas: [UserData] = []
    
    private var grade: Int?
    private var gender: String?
    private var isBlackList: Bool?
    private var isOuting: Bool?
    private var authority: String?
    private var major: String?
    
    // MARK: - Setting
    func setupGrade(grade: Int?) {
        self.grade = grade!
    }
    
    func setupGender(gender: String?) {
        self.gender = gender!
    }

    func setupIsOuting(gender: Bool?) {
        self.isOuting = isOuting!
    }

    func setupIsBlackList(isBlackList: Bool?) {
        self.isBlackList = isBlackList!
    }
    
    func setupAuthority(authority: String?) {
        self.authority = authority!
    }
    
    func setupMajor(major: String?) {
        self.major = major!
    }
    
    func resetInfo() {
        self.grade = nil
        self.gender = nil
        self.isBlackList = nil
        self.authority = nil
        self.major = nil
        self.isOuting = nil
    }
    
    // MARK: - Get User List
    func getUserList(completion: @escaping () -> Void) {
        studentCouncilProvider.request(.studentList(authorization: accessToken)) { response in
            switch response {
            case .success(let result):
                let responseData = result.data
                let statusCode = result.statusCode
                switch statusCode {
                case 200:
                    do {
                        self.userList = try JSONDecoder().decode([StudentListResponse].self, from: responseData)
                        self.userListDatas = self.userList.map { UserData(id: $0.accountIdx, name: $0.name, profileImageURL: $0.profileUrl, gender: $0.gender, grade: $0.grade, major: $0.major, authority: $0.authority, isBlackList: $0.isBlackList, isOuting: $0.isOuting) }
                        completion()
                    } catch(let err) {
                        print(String(describing: err))
                    }
                case 401:
                    self.gomsRefreshToken.tokenReissuance(){ success in}
                case 403:
                    print("학생회 계정이 아닐 경우")
                default:
                    print(result)
                }
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
    // MARK: - Change Student Council Authority
    func changeAuthority(user: UserData, completion: @escaping ([UserData]) -> Void) {
        self.getUserList {
            let accountIdx = user.id
            let currentAuthority = user.authority
            var newAuthority: String = ""
            
            if currentAuthority == Authority.student.rawValue {
                newAuthority = Authority.admin.rawValue
            } else {
                newAuthority = Authority.student.rawValue
            }
            
            let param = AuthorityRequest(accountIdx: accountIdx, authority: newAuthority)
            
            self.studentCouncilProvider.request(.editAuthority(authorization: self.accessToken, param: param)) { response in
                switch response {
                case .success(let result):
                    let statusCode = result.statusCode
                    switch statusCode {
                    case 205:
                        print(result)
                        completion(self.userListDatas)
                    case 401:
                        self.gomsRefreshToken.tokenReissuance(){ success in}
                    case 403:
                        print("학생회 계정이 아닌데 요청할 경우")
                    case 404:
                        print("계정을 찾을 수 없을 경우")
                    default:
                        print(result)
                    }
                    
                case .failure(let err):
                    print(err.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Black List
    func blackList(user: UserData, completion: @escaping ([UserData]) -> Void) {
        self.getUserList {
            let accountIdx = user.id
            
            self.studentCouncilProvider.request(.changeBlackList(authorization: self.accessToken, accountIdx: accountIdx)) { response in
                switch response {
                case .success(let result):
                    let statusCode = result.statusCode
                    switch statusCode {
                    case 201:
                        completion(self.userListDatas)
                    case 401:
                        self.gomsRefreshToken.tokenReissuance(){ success in}
                    case 403:
                        print("학생회 계정이 아닌데 요청할 경우")
                    case 404:
                        print("계정을 찾을 수 없을 경우")
                    default:
                        print(result)
                    }
                case .failure(let err):
                    print(err.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Delete Black List
    func cancelBlackList(user: UserData, completion: @escaping ([UserData]) -> Void) {
        self.getUserList {
            let accountIdx = user.id
            self.studentCouncilProvider.request(.cancelBlackList(authorization: self.accessToken, accountIdx: accountIdx)) { response in
                switch response {
                case .success(let result):
                    let statusCode = result.statusCode
                    switch statusCode {
                    case 205:
                        completion(self.userListDatas)
                    case 401:
                        self.gomsRefreshToken.tokenReissuance(){ success in}
                    case 403:
                        print("학생회 계정이 아닌데 요청할 경우")
                    case 404:
                        print("계정을 찾을 수 없을 경우")
                    default:
                        print(result)
                    }
                case .failure(let err):
                    print(err.localizedDescription)
                }
            }
        }
    }

    func forceOutingStudent(user: UserData, completion: @escaping ([UserData]) -> Void) {
        self.getUserList {
            let forceOutingStudent = user.id

            self.studentCouncilProvider.request(.forceOuting(authorization: self.accessToken, accountIdx: forceOutingStudent)) { response in
                switch response {
                case .success(let result):
                    let statusCode = result.statusCode
                    switch statusCode {
                    case 205:
                        completion(self.userListDatas)
                    case 401:
                        self.gomsRefreshToken.tokenReissuance { success in }
                    case 403:
                        print("학생회 계정이 아닌데 요청할 경우")
                    default:
                        print(result)
                    }
                case .failure(let err):
                    print("강제 외출 중 오류 발생: \(err.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Search User
    func serachStudent(searchString: String?, completion: @escaping ([UserData]) -> Void) {
        let gradeToSend = self.grade
        let gender = self.gender
        let isBlackList = self.isBlackList
        let authority = self.authority
        let major = self.major
        
        let parm = SearchStudentRequest(grade: gradeToSend, gender: gender, name: searchString, isBlackList: isBlackList, authority: authority, major: major)
        
        studentCouncilProvider.request(.searchStudent(authorization: self.accessToken, parm: parm)) { response in
            switch response {
            case .success(let result):
                let responseData = result.data
                do {
                    self.userList = try JSONDecoder().decode([StudentListResponse].self, from: responseData)
                    self.userListDatas = self.userList.map { UserData(id: $0.accountIdx, name: $0.name, profileImageURL: $0.profileUrl, gender: $0.gender, grade: $0.grade, major: $0.major, authority: $0.authority, isBlackList: $0.isBlackList, isOuting: $0.isOuting) }
                    completion(self.userListDatas)
                } catch(let err) {
                    print(String(describing: err))
                }
                let statusCode = result.statusCode
                switch statusCode {
                case 200:
                    print("ok")
                case 401:
                    self.gomsRefreshToken.tokenReissuance(){ success in}
                case 403:
                    print("학생회 계정이 아닌데 요청할 경우")
                default:
                    print(result)
                }
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
}

