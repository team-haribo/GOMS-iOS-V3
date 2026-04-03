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
    let id: Int
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
    
    var userList: [Student] = []
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
                id: $0.memberId,
                name: $0.name,
                profileImageURL: nil,
                gender: "",
                grade: $0.grade,
                major: $0.department,
                authority: "",
                isBlackList: false,
                isOuting: false
            )
        }
    }
    
    func getUserList(completion: @escaping () -> Void) {
        studentCouncilProvider.request(.studentList(authorization: accessToken)) { response in
            if case let .success(result) = response, result.statusCode == 200 {
                do {
                    self.userList = try JSONDecoder().decode(StudentListModel.self, from: result.data).students
                    self.mapToUserData()
                    completion()
                } catch { print(error) }
            } else if case let .success(result) = response, result.statusCode == 401 {
                self.gomsRefreshToken.tokenReissuance { _ in }
            }
        }
    }
    
    // TODO: 임시 로컬 (서버통신 아직X)
    func changeAuthority(user: UserData, completion: @escaping ([UserData]) -> Void) {
        self.userListDatas = self.userListDatas.map {
            guard $0.id == user.id else { return $0 }
            return UserData(
                id: $0.id,
                name: $0.name,
                profileImageURL: $0.profileImageURL,
                gender: $0.gender,
                grade: $0.grade,
                major: $0.major,
                authority: $0.authority == Authority.student.rawValue ? Authority.admin.rawValue : Authority.student.rawValue,
                isBlackList: $0.isBlackList,
                isOuting: $0.isOuting
            )
        }
        completion(self.userListDatas)
    }
    
    func blackList(user: UserData, completion: @escaping ([UserData]) -> Void) {
        self.userListDatas = self.userListDatas.map {
            guard $0.id == user.id else { return $0 }
            return UserData(
                id: $0.id,
                name: $0.name,
                profileImageURL: $0.profileImageURL,
                gender: $0.gender,
                grade: $0.grade,
                major: $0.major,
                authority: $0.authority,
                isBlackList: true,
                isOuting: $0.isOuting
            )
        }
        completion(self.userListDatas)
    }
    
    func cancelBlackList(user: UserData, completion: @escaping ([UserData]) -> Void) {
        self.userListDatas = self.userListDatas.map {
            guard $0.id == user.id else { return $0 }
            return UserData(
                id: $0.id,
                name: $0.name,
                profileImageURL: $0.profileImageURL,
                gender: $0.gender,
                grade: $0.grade,
                major: $0.major,
                authority: $0.authority,
                isBlackList: false,
                isOuting: $0.isOuting
            )
        }
        completion(self.userListDatas)
    }

    func forceOutingStudent(user: UserData, completion: @escaping ([UserData]) -> Void) {
        self.userListDatas = self.userListDatas.map {
            guard $0.id == user.id else { return $0 }
            return UserData(
                id: $0.id,
                name: $0.name,
                profileImageURL: $0.profileImageURL,
                gender: $0.gender,
                grade: $0.grade,
                major: $0.major,
                authority: $0.authority,
                isBlackList: $0.isBlackList,
                isOuting: true
            )
        }
        completion(self.userListDatas)
    }

    func serachStudent(searchString: String?, completion: @escaping ([UserData]) -> Void) {
        let keyword = searchString?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        let filtered = self.userListDatas.filter { user in
            let matchesName = keyword.isEmpty || user.name.localizedCaseInsensitiveContains(keyword)
            let matchesGrade = self.grade == nil || user.grade == self.grade
            let matchesMajor = self.major == nil || self.major?.isEmpty == true || user.major == self.major
            return matchesName && matchesGrade && matchesMajor
        }

        completion(filtered)
    }
}
