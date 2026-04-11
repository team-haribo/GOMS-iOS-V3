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
    
    func changeAuthority(user: UserData, completion: @escaping () -> Void) {
        let newRole = user.authority == Authority.student.rawValue ? Authority.admin.rawValue : Authority.student.rawValue
        let body = ["role": newRole]

        studentCouncilProvider.request(.changeRole(memberId: user.id, body: body, authorization: accessToken)) { response in
            switch response {
            case .success(let result):
                if result.statusCode == 200 {
                    completion()
                } else if result.statusCode == 401 {
                    self.gomsRefreshToken.tokenReissuance { _ in }
                } else {
                    print(result)
                }
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
    func blackList(user: UserData, completion: @escaping () -> Void) {
        let body = ["status": "CANNOT_OUTING"]

        studentCouncilProvider.request(.outingAllowed(memberId: user.id, body: body, authorization: accessToken)) { response in
            switch response {
            case .success(let result):
                if result.statusCode == 200 {
                    completion()
                } else if result.statusCode == 401 {
                    self.gomsRefreshToken.tokenReissuance { _ in }
                } else {
                    print(result)
                }
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
    func cancelBlackList(user: UserData, completion: @escaping () -> Void) {
        let body = ["status": "COMING"]

        studentCouncilProvider.request(.outingAllowed(memberId: user.id, body: body, authorization: accessToken)) { response in
            switch response {
            case .success(let result):
                if result.statusCode == 200 {
                    completion()
                } else if result.statusCode == 401 {
                    self.gomsRefreshToken.tokenReissuance { _ in }
                } else {
                    print(result)
                }
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }

    func forceOutingStudent(user: UserData, completion: @escaping () -> Void) {
        studentCouncilProvider.request(.forceOuting(memberId: user.id, authorization: accessToken)) { response in
            switch response {
            case .success(let result):
                if result.statusCode == 200 {
                    completion()
                } else if result.statusCode == 401 {
                    self.gomsRefreshToken.tokenReissuance { _ in }
                } else {
                    print(result)
                }
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }

    func serachStudent(searchString: String?, completion: @escaping () -> Void) {
        guard let name = searchString, !name.isEmpty else {
            getUserList(completion: completion)
            return
        }

        studentCouncilProvider.request(.searchStudent(name: name, authorization: accessToken)) { response in
            switch response {
            case .success(let result):
                if result.statusCode == 200 {
                    do {
                        self.userList = try JSONDecoder().decode(StudentListModel.self, from: result.data).students
                        self.mapToUserData()
                        completion()
                    } catch {
                        print(error)
                    }
                } else if result.statusCode == 401 {
                    self.gomsRefreshToken.tokenReissuance { _ in }
                } else {
                    print(result)
                }
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
}
