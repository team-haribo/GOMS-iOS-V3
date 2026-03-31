//
//  StudentManagementViewModel.swift
//  Feature
//
//  Created by 김민선 on 3/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation
import Moya
import Service

public struct UserData {
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
    
    func setupGrade(grade: Int?) { self.grade = grade }
    func setupGender(gender: String?) { self.gender = gender }
    func setupIsOuting(isOuting: Bool?) { self.isOuting = isOuting }
    func setupIsBlackList(isBlackList: Bool?) { self.isBlackList = isBlackList }
    func setupAuthority(authority: String?) { self.authority = authority }
    func setupMajor(major: String?) { self.major = major }
    
    func resetInfo() {
        self.grade = nil; self.gender = nil; self.isBlackList = nil
        self.authority = nil; self.major = nil; self.isOuting = nil
    }
    
    private func mapToUserData() {
        self.userListDatas = self.userList.map {
            UserData(
                id: $0.accountIdx,
                name: $0.name,
                profileImageURL: $0.profileUrl,
                gender: $0.gender,
                grade: $0.grade,
                major: $0.major,
                authority: $0.authority,
                isBlackList: $0.isBlackList,
                isOuting: $0.isOuting
            )
        }
    }
    
    func getUserList(completion: @escaping () -> Void) {
        studentCouncilProvider.request(.studentList(authorization: accessToken)) { response in
            if case let .success(result) = response, result.statusCode == 200 {
                do {
                    self.userList = try JSONDecoder().decode([StudentListResponse].self, from: result.data)
                    self.mapToUserData()
                    completion()
                } catch { print(error) }
            } else if case let .success(result) = response, result.statusCode == 401 {
                self.gomsRefreshToken.tokenReissuance { _ in }
            }
        }
    }
    
    func changeAuthority(user: UserData, completion: @escaping ([UserData]) -> Void) {
        let newAuthority = user.authority == Authority.student.rawValue ? Authority.admin.rawValue : Authority.student.rawValue
        let param = AuthorityRequest(accountIdx: user.id, authority: newAuthority)
        studentCouncilProvider.request(.editAuthority(authorization: self.accessToken, param: param)) { response in
            if case let .success(result) = response, result.statusCode == 205 {
                self.getUserList { completion(self.userListDatas) }
            }
        }
    }
    
    func blackList(user: UserData, completion: @escaping ([UserData]) -> Void) {
        studentCouncilProvider.request(.changeBlackList(authorization: self.accessToken, accountIdx: user.id)) { response in
            if case let .success(result) = response, result.statusCode == 201 {
                self.getUserList { completion(self.userListDatas) }
            }
        }
    }
    
    func cancelBlackList(user: UserData, completion: @escaping ([UserData]) -> Void) {
        studentCouncilProvider.request(.cancelBlackList(authorization: self.accessToken, accountIdx: user.id)) { response in
            if case let .success(result) = response, result.statusCode == 205 {
                self.getUserList { completion(self.userListDatas) }
            }
        }
    }

    func forceOutingStudent(user: UserData, completion: @escaping ([UserData]) -> Void) {
        studentCouncilProvider.request(.forceOuting(authorization: self.accessToken, accountIdx: user.id)) { response in
            if case let .success(result) = response, result.statusCode == 205 {
                self.getUserList { completion(self.userListDatas) }
            }
        }
    }

    func serachStudent(searchString: String?, completion: @escaping ([UserData]) -> Void) {
        let parm = SearchStudentRequest(grade: self.grade, gender: self.gender, name: searchString, isBlackList: self.isBlackList, authority: self.authority, major: self.major)
        studentCouncilProvider.request(.searchStudent(authorization: self.accessToken, parm: parm)) { response in
            if case let .success(result) = response, result.statusCode == 200 {
                do {
                    self.userList = try JSONDecoder().decode([StudentListResponse].self, from: result.data)
                    self.mapToUserData()
                    completion(self.userListDatas)
                } catch { print(error) }
            }
        }
    }
}
