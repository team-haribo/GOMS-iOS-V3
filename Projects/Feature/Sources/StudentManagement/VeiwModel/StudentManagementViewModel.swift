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
    let grade: Int
    let major: String
    let authority: String
    let isBlackList: Bool
    let isOuting: Bool
}

public final class StudentManagementViewModel: BaseViewModel {
    private let studentCouncilProvider = MoyaProvider<StudentCouncilServices>()
    
    var userList: [Service.Student] = []
    var userListDatas: [UserData] = []
    
    private var grade: Int?
    private var gender: String?
    private var isBlackList: Bool?
    private var isOuting: Bool?
    private var status: String?
    private var authority: String?
    private var major: String?
    
    func setupGrade(grade: Int?) {
        guard let grade = grade else {
            self.grade = nil
            return
        }

        switch grade {
        case 1: self.grade = 10
        case 2: self.grade = 9
        case 3: self.grade = 8
        default: self.grade = grade
        }
    }
    
    func setupGender(gender: String?) { self.gender = gender }
    func setupIsOuting(isOuting: Bool?) { self.isOuting = isOuting }
    func setupStatus(status: String?) { self.status = status }
    func setupIsBlackList(isBlackList: Bool?) { self.isBlackList = isBlackList }
    func setupAuthority(authority: String?) { self.authority = authority }
    func setupMajor(major: String?) { self.major = major }
    
    func resetInfo() {
        self.grade = nil; self.gender = nil; self.isBlackList = nil
        self.authority = nil; self.major = nil; self.isOuting = nil; self.status = nil
    }
    
    private func mapToUserData() {
        self.userListDatas = self.userList.map {
            UserData(
                id: $0.memberId,
                name: $0.name,
                profileImageURL: $0.profileImageUrl,
                grade: $0.grade,
                major: $0.department,
                authority: $0.role,
                isBlackList: $0.status == OutingStatus.cannotOuting.rawValue,
                isOuting: $0.status == OutingStatus.outing.rawValue
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
        let isStudent = user.authority == "ROLE_STUDENT"
        let newRole: Authority = isStudent ? .admin : .student
        let body = AuthorityRequest(role: newRole.rawValue)

        studentCouncilProvider.request(.editAuthority(authorization: accessToken, memberId: user.id, param: body)) { response in
            switch response {
            case .success(let result):
                if result.statusCode == 200 {
                    self.getUserList {
                        completion()
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
    
    func blackList(user: UserData, completion: @escaping () -> Void) {
        let body = OutingAllowedRequest(status: .cannotOuting)

        studentCouncilProvider.request(.outingAllowed(authorization: accessToken, memberId: user.id, param: body)) { response in
            switch response {
            case .success(let result):
                if result.statusCode == 200 {
                    self.getUserList {
                        completion()
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
    
    func cancelBlackList(user: UserData, completion: @escaping () -> Void) {
        let body = OutingAllowedRequest(status: .coming)

        studentCouncilProvider.request(.outingAllowed(authorization: accessToken, memberId: user.id, param: body)) { response in
            switch response {
            case .success(let result):
                if result.statusCode == 200 {
                    self.getUserList {
                        completion()
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

    func forceOutingStudent(user: UserData, completion: @escaping () -> Void) {
        studentCouncilProvider.request(.forceOuting(authorization: accessToken, memberId: user.id)) { response in
            switch response {
            case .success(let result):
                if result.statusCode == 200 {
                    self.getUserList {
                        completion()
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

    func searchStudent(searchString: String?, completion: @escaping () -> Void) {

        let param = SearchStudentRequest(
            grade: self.grade,
            gender: self.gender,
            name: searchString,
            authority: self.authority,
            major: self.major,
            status: self.status
        )

        studentCouncilProvider.request(.searchStudent(authorization: accessToken, param: param)) { response in
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
    
    func filterStudent(completion: @escaping () -> Void) {


        let param = SearchStudentRequest(
            grade: self.grade,
            gender: self.gender,
            name: nil,
            authority: self.authority,
            major: self.major,
            status: self.status
        )

        studentCouncilProvider.request(.filterStudent(authorization: accessToken, param: param)) { response in
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
